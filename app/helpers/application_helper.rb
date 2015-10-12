module ApplicationHelper

  def search_terms_array
    params[:q].split(/ and | or /)
  end

  def search_rows
    100_000
  end

  def track_files
    @release.each_with_object({}) do |track, hash|
      hash[track.id] = {
        id: track.id,
        media_url: track.file.try(:url),
        url: track_path(track, format: :json)
      }
    end
  end

  def thumbs_scss
    @images.each_with_object("") do |image, string|
      thumb = image.file.thumb("300x250>") ; thumb_high = image.file.thumb("600x500>")
      string << "#img-#{image.id} { @include image-set('%s', '%s') { width: %spx; height: %spx; } }" % [
        thumb.url, thumb_high.url, thumb.width, thumb.height
      ]
    end
  end

end