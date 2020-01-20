module RedisDb
  class << self
    def client
      @client ||= Redis.new url: "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
    end
  end
end
