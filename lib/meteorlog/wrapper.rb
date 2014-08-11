class Meteorlog::Wrapper
  class << self
    def wrap(cwl, opts = {})
      Meteorlog::Wrapper::CloudWatchLogs.new(cwl, opts)
    end
  end # of class methods
end
