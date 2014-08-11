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
    if @log_group.respond_to?(:log_streams)
      @log_group.log_streams
    else
      @cloud_watch_logs.describe_log_streams(
        :log_group_name => log_group_name
      ).each.inject([]) {|r, i| r + i.log_streams }
    end
  end

  def metric_filters
    if @log_group.respond_to?(:metric_filters)
      @log_group.metric_filters
    else
      @cloud_watch_logs.describe_metric_filters(
        :log_group_name => log_group_name
      ).each.inject([]) {|r, i| r + i.metric_filters }
    end
  end

  def eql?(dsl)
    # XXX:
  end

  def update
    # XXX:
  end

  def delete
    log(:info, 'Delete LogGroup', :red, self.log_group_name)

    unless @options[:dry_run]
      @cloud_watch_logs.delete_log_group(:log_group_name => self.log_group_name)
      @options[:modified] = true
    end
  end
end
