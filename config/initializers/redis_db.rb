module RedisDb
  class << self
    def client
      @client ||= Redis.new url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}"
    end
  end
end
