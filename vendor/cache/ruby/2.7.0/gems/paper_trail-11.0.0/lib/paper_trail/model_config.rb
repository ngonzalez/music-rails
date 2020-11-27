# frozen_string_literal: true

module PaperTrail
  # Configures an ActiveRecord model, mostly at application boot time, but also
  # sometimes mid-request, with methods like enable/disable.
  class ModelConfig
    E_CANNOT_RECORD_AFTER_DESTROY = <<-STR.strip_heredoc.freeze
      paper_trail.on_destroy(:after) is incompatible with ActiveRecord's
      belongs_to_required_by_default. Use on_destroy(:before)
      or disable belongs_to_required_by_default.
    STR
    E_HPT_ABSTRACT_CLASS = <<~STR.squish.freeze
      An application model (%s) has been configured to use PaperTrail (via
      `has_paper_trail`), but the version model it has been told to use (%s) is
      an `abstract_class`. This could happen when an advanced feature called
      Custom Version Classes (http://bit.ly/2G4ch0G) is misconfigured. When all
      version classes are custom, PaperTrail::Version is configured to be an
      `abstract_class`. This is fine, but all application models must be
      configured to use concrete (not abstract) version models.
    STR
    E_MODEL_LIMIT_REQUIRES_ITEM_SUBTYPE = <<~STR.squish.freeze
      To use PaperTrail's per-model limit in your %s model, you must have an
      item_subtype column in your versions table. See documentation sections
      2.e.1 Per-model limit, and 4.b.1 The optional item_subtype column.
    STR
    DPR_PASSING_ASSOC_NAME_DIRECTLY_TO_VERSIONS_OPTION = <<~STR.squish
      Passing versions association name as `has_paper_trail versions: %{versions_name}`
      is deprecated. Use `has_paper_trail versions: {name: %{versions_name}}` instead.
      The hash you pass to `versions:` is now passed directly to `has_many`.
    STR
    DPR_CLASS_NAME_OPTION = <<~STR.squish
      Passing Version class name as `has_paper_trail class_name: %{class_name}`
      is deprecated. Use `has_paper_trail versions: {class_name: %{class_name}}`
      instead. The hash you pass to `versions:` is now passed directly to `has_many`.
    STR

    def initialize(model_class)
      @model_class = model_class
    end

    # Adds a callback that records a version after a "create" event.
    #
    # @api public
    def on_create
      @model_class.after_create { |r|
        r.paper_trail.record_create if r.paper_trail.save_version?
      }
      return if @model_class.paper_trail_options[:on].include?(:create)
      @model_class.paper_trail_options[:on] << :create
    end

    # Adds a callback that records a version before or after a "destroy" event.
    #
    # @api public
    def on_destroy(recording_order = "before")
      unless %w[after before].include?(recording_order.to_s)
        raise ArgumentError, 'recording order can only be "after" or "before"'
      end

      if recording_order.to_s == "after" && cannot_record_after_destroy?
        raise E_CANNOT_RECORD_AFTER_DESTROY
      end

      @model_class.send(
        "#{recording_order}_destroy",
        lambda do |r|
          return unless r.paper_trail.save_version?
          r.paper_trail.record_destroy(recording_order)
        end
      )

      return if @model_class.paper_trail_options[:on].include?(:destroy)
      @model_class.paper_trail_options[:on] << :destroy
    end

    # Adds a callback that records a version after an "update" event.
    #
    # @api public
    def on_update
      @model_class.before_save { |r|
        r.paper_trail.reset_timestamp_attrs_for_update_if_needed
      }
      @model_class.after_update { |r|
        if r.paper_trail.save_version?
          r.paper_trail.record_update(
            force: false,
            in_after_callback: true,
            is_touch: false
          )
        end
      }
      @model_class.after_update { |r|
        r.paper_trail.clear_version_instance
      }
      return if @model_class.paper_trail_options[:on].include?(:update)
      @model_class.paper_trail_options[:on] << :update
    end

    # Adds a callback that records a version after a "touch" event.
    # @api public
    def on_touch
      @model_class.after_touch { |r|
        r.paper_trail.record_update(
          force: true,
          in_after_callback: true,
          is_touch: true
        )
      }
    end

    # Set up `@model_class` for PaperTrail. Installs callbacks, associations,
    # "class attributes", instance methods, and more.
    # @api private
    def setup(options = {})
      options[:on] ||= %i[create update destroy touch]
      options[:on] = Array(options[:on]) # Support single symbol
      @model_class.send :include, ::PaperTrail::Model::InstanceMethods
      setup_options(options)
      setup_associations(options)
      check_presence_of_item_subtype_column(options)
      @model_class.after_rollback { paper_trail.clear_rolled_back_versions }
      setup_callbacks_from_options options[:on]
    end

    def version_class
      @_version_class ||= @model_class.version_class_name.constantize
    end

    private

    # Raises an error if the provided class is an `abstract_class`.
    # @api private
    def assert_concrete_activerecord_class(class_name)
      if class_name.constantize.abstract_class?
        raise format(E_HPT_ABSTRACT_CLASS, @model_class, class_name)
      end
    end

    def cannot_record_after_destroy?
      ::ActiveRecord::Base.belongs_to_required_by_default
    end

    # Some options require the presence of the `item_subtype` column. Currently
    # only `limit`, but in the future there may be others.
    #
    # @api private
    def check_presence_of_item_subtype_column(options)
      return unless options.key?(:limit)
      return if version_class.item_subtype_column_present?
      raise format(E_MODEL_LIMIT_REQUIRES_ITEM_SUBTYPE, @model_class.name)
    end

    def check_version_class_name(options)
      # @api private - `version_class_name`
      @model_class.class_attribute :version_class_name
      if options[:class_name]
        ::ActiveSupport::Deprecation.warn(
          format(
            DPR_CLASS_NAME_OPTION,
            class_name: options[:class_name].inspect
          ),
          caller(1)
        )
        options[:versions][:class_name] = options[:class_name]
      end
      @model_class.version_class_name = options[:versions][:class_name] || "PaperTrail::Version"
      assert_concrete_activerecord_class(@model_class.version_class_name)
    end

    def check_versions_association_name(options)
      # @api private - versions_association_name
      @model_class.class_attribute :versions_association_name
      @model_class.versions_association_name = options[:versions][:name] || :versions
    end

    def define_has_many_versions(options)
      options = ensure_versions_option_is_hash(options)
      check_version_class_name(options)
      check_versions_association_name(options)
      scope = get_versions_scope(options)
      @model_class.has_many(
        @model_class.versions_association_name,
        scope,
        class_name: @model_class.version_class_name,
        as: :item,
        **options[:versions].except(:name, :scope)
      )
    end

    def ensure_versions_option_is_hash(options)
      unless options[:versions].is_a?(Hash)
        if options[:versions]
          ::ActiveSupport::Deprecation.warn(
            format(
              DPR_PASSING_ASSOC_NAME_DIRECTLY_TO_VERSIONS_OPTION,
              versions_name: options[:versions].inspect
            ),
            caller(1)
          )
        end
        options[:versions] = {
          name: options[:versions]
        }
      end
      options
    end

    def get_versions_scope(options)
      options[:versions][:scope] || -> { order(model.timestamp_sort_order) }
    end

    def setup_associations(options)
      # @api private - version_association_name
      @model_class.class_attribute :version_association_name
      @model_class.version_association_name = options[:version] || :version

      # The version this instance was reified from.
      # @api public
      @model_class.send :attr_accessor, @model_class.version_association_name

      # @api public - paper_trail_event
      @model_class.send :attr_accessor, :paper_trail_event

      define_has_many_versions(options)
    end

    def setup_callbacks_from_options(options_on = [])
      options_on.each do |event|
        public_send("on_#{event}")
      end
    end

    def setup_options(options)
      # @api public - paper_trail_options - Let's encourage plugins to use eg.
      # `paper_trail_options[:versions][:class_name]` rather than
      # `version_class_name` because the former is documented and the latter is
      # not.
      @model_class.class_attribute :paper_trail_options
      @model_class.paper_trail_options = options.dup

      %i[ignore skip only].each do |k|
        @model_class.paper_trail_options[k] = [@model_class.paper_trail_options[k]].
          flatten.
          compact.
          map { |attr| attr.is_a?(Hash) ? attr.stringify_keys : attr.to_s }
      end

      @model_class.paper_trail_options[:meta] ||= {}
    end
  end
end
