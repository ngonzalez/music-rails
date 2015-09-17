class MusicController < ApplicationController

  def index
    @releases = get_releases
    respond_to do |format|
      # format.html
      format.json do
        render json: @releases.to_json
      end
    end
  end

  def show
    @release = get_release
    @images = get_images
    @nfo = get_nfo
    respond_to do |format|
      format.html
      format.json do
        render json: @release.to_json
      end
    end
  end

  def search
    @t1 = Time.now
    @tracks = find_tracks
    respond_to do |format|
      format.html
      format.json do
        render json: @tracks.to_json
      end
    end
  end

  def stats
    set_stats_params
    @metrics1 = get_values @metric1
    @metrics2 = get_values @metric2 
    @stats = get_stats
    respond_to do |format|
      format.html do
        @data = format_data
      end
      format.json do
        render json: @stats.to_json
      end
    end
  end

  private

  def get_releases
    Release.order("LOWER(#{Release.table_name}.name)").map do |release|
      {
        id: release.id,
        name: release.name,
        url: music_url(release.id, format: :json)
      }
    end
  end

  def get_release
    Release.find(params[:id]).tracks.map do |track|
      track.attributes.merge(path: track.file_url)
    end
  end

  def get_images
    Image.where(release_id: params[:id]).reject{|image| image.file_type == "nfo" }
  end

  def get_nfo
    Image.where(release_id: params[:id]).where(file_type: "nfo")
  end

  def find_tracks
    return [] if params[:q].blank?
    search = Track.search(include: [:release]) {
      fulltext params[:q]
      paginate :page => params[:page], :per_page => params[:rows]
    }
    hash = {}
    search.hits.each do |hit|
      begin
        hash[hit.result.release_id] = {
          name: hit.result.release.name,
          url: music_url(hit.result.release, format: params.slice("format"))
        }
      rescue
        next
      end
    end
    return hash.sort_by{|k, v| v[:name] }
  end

  def set_stats_params
    @metric1 = params[:m1] && ALLOWED_METRICS.include?(params[:m1]) ? params[:m1] : ALLOWED_METRICS[0]
    @metric2 = params[:m2] && ALLOWED_METRICS.include?(params[:m2]) ? params[:m2] : ALLOWED_METRICS[0]
  end

  def format_data
    @metrics2.each_with_object([]) do |metric2, data_array|
      stats = @metrics1.each_with_object([]) do |name, array|
        stat_infos = @stats[metric2].detect{|item| item[@metric1] == name }
        array << (stat_infos ? stat_infos["count"].to_i : 0)
      end
      data_array << [metric2.to_s] + stats
    end
  end

  def get_stats
    @metrics2.each_with_object({}) do |metric, hash|
      hash[metric] = find_releases(metric).to_hash
    end
  end

  def get_values metric
    Track.select(metric).group(metric).order(metric).map{|item| item.send(metric) }.reject(&:blank?).map(&:to_s)
  end

  def find_releases m2_value
    if m2_value.to_i > 0
      m2_condition = "#{@metric2}::numeric = #{m2_value.to_i}"
    else
      m2_condition = "#{@metric2} = '#{m2_value.gsub("'", "")}'"
    end
    sql_base = <<-SQL
      SELECT t1.#{@metric1}, (
        SELECT COUNT(t2.id)
        FROM tracks t2
        WHERE t1.#{@metric1} = t2.#{@metric1}
        AND t2.#{m2_condition}
      ) AS count
      FROM tracks t1
      WHERE t1.#{m2_condition}
      GROUP BY t1.#{@metric1}
      ORDER BY 1;
    SQL
    ActiveRecord::Base.connection.select_all sql_base
  end

end