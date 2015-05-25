Sunspot::Search::Hit.class_eval do
  def initialize(raw_hit, highlights, search)
    @class_name, @primary_key = *raw_hit['id'].match(/([^ ]+) (.+)/)[1..2]
    @score = raw_hit['score']
    @search = search
    @stored_values = raw_hit
    @stored_cache = {}
    @highlights = highlights
  rescue
    #
  end
end