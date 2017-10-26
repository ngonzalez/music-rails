class StatsController < ApplicationController
  def index
    set_stats_params
    @metrics1 = get_values @m1
    @metrics2 = get_values @m2
    @stats = get_stats
    respond_to do |format|
      format.html do
        @data = format_data.sort_by &:first
      end
      format.json do
        render json: @stats.to_json
      end
    end
  end

  private

  def set_stats_params
    @m1 = params[:m1] && ALLOWED_METRICS.include?(params[:m1]) ? params[:m1] : ALLOWED_METRICS[0]
    @m2 = params[:m2] && ALLOWED_METRICS.include?(params[:m2]) ? params[:m2] : ALLOWED_METRICS[0]
  end

  def format_data
    @metrics2.each_with_object([]) do |metric2, data_array|
      stats = @metrics1.each_with_object([]) do |name, array|
        stat_infos = @stats[metric2].detect { |item| item[@m1] == name }
        array << (stat_infos ? stat_infos["count"].to_i : 0)
      end
      data_array << [metric2.to_s] + stats
    end
  end

  def get_stats
    @metrics2.each_with_object({}) do |value, hash|
      hash[value] = find_tracks(value).to_hash
    end
  end

  def get_values metric
    Track.pluck(metric).uniq.map &:to_s
  end

  def find_tracks value
    sql_base = <<-SQL
      SELECT t1.#{@m1}, (
        SELECT COUNT(t2.id)
        FROM #{Track.table_name} t2
        WHERE t1.#{@m1} = t2.#{@m1}
        AND t2.#{tracks_condition(@m2, value)}
      ) AS count
      FROM #{Track.table_name} t1
      WHERE t1.#{tracks_condition(@m2, value)}
      GROUP BY t1.#{@m1}
      ORDER BY 1;
    SQL
    ActiveRecord::Base.connection.select_all sql_base
  end

  def releases_condition metric, value
    if %w(created_at_year).include? metric
      "to_char('folder_created_at', 'YYYY')::numeric = %s" % [value.to_i]
    end
  end

  def tracks_condition metric, value
    if %w(year).include? metric
      "%s::numeric = %s" % [metric, value.to_i]
    elsif %w(format_name genre).include? metric
      "%s = '%s'" % [metric, value.gsub("'", "")]
    end
  end

end