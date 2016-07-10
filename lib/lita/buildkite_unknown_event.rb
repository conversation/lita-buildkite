class BuildkiteUnknownEvent
  def initialize(data)
    @data = data
  end

  def name
    @data.fetch("event", "")
  end

end
