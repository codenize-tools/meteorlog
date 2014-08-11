class Meteorlog::Client
  include Meteorlog::Logger::Helper
  include Meteorlog::Utils

  def initialize(options = {})
    @options = options
    @cloud_watch_logs = Aws::CloudWatchLogs::Client.new
  end

  def export(opts = {})
    exported = Meteorlog::Exporter.export(@cloud_watch_logs, @options.merge(opts))
    Meteorlog::DSL.convert(exported, @options.merge(opts))
  end
end
