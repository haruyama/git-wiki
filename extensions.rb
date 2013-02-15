class Time
  def to_json
    (to_i * 1000).to_s
  end
end

