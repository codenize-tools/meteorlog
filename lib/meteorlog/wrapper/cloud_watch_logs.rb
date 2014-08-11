class Meteorlog::Wrapper::CloudWatchLogs
  def initialize(cloud_watch_logs, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @options = options.dup
  end

  def log_groups
    Meteorlog::Wrapper::LogGroupCollection.new(
      @cloud_watch_logs, @cloud_watch_logs.describe_log_groups.each.inject([]) {|r, i| r + i.log_groups }, @options)
  end

  def modified?
    !!@options[:modified]
  end
end
