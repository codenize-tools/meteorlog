class Meteorlog::Wrapper::LogGroup
  extend Forwardable
  include Meteorlog::Logger::Helper

  def_delegator :@log_group, :log_group_name

  def initialize(cloud_watch_logs, log_group, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @log_group = log_group
    @options = options
  end

  def log_streams
    @cloud_watch_logs.describe_log_streams(
      :log_group_name => log_group_name).log_streams
  end

  def metric_filters
    @cloud_watch_logs.describe_metric_filters(
      :log_group_name => log_group_name).metric_filters
  end
end
