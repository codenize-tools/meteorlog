class Meteorlog::Wrapper::LogGroupCollection
  include Meteorlog::Logger::Helper

  def initialize(cloud_watch_logs, log_groups, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @log_groups = log_groups
    @options = options
  end

  def each
    @log_groups.each do |log_group|
      yield(Meteorlog::Wrapper::LogGroup.new(@cloud_watch_logs, log_group, @options))
    end
  end
end
