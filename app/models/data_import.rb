class DataImport
  def self.last_imported_at
    redis = Redis.new
    ts = redis.get("last_imported_at")
    return if ts.blank?

    Time.at(ts.to_i)
  end

  def self.set_imported_at
    redis = Redis.new
    redis.set("last_imported_at", Time.now.utc.to_i.to_s)
  end
end
