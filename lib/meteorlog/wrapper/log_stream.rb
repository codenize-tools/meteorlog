class Meteorlog::Wrapper::MetricFilter
  extend Forwardable
  include Meteorlog::Logger::Helper

  def_delegator :@metric_filter, :metric_filter_name

  def initialize(cloud_watch_logs, metric_filter, log_group, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @metric_filter = metric_filter
    @log_group = log_group
    @options = options
  end

  def eql?(dsl)
    # XXX:
  end

  def update
    # XXX:
  end

  def delete
    log(:info, 'Delete MetricFilter', :red, "#{@log_group.log_group_name} > #{self.filter_name}")

    unless @options[:dry_run]
      @cloud_watch_logs.delete_metric_filter(
        :log_group_name => @log_group.log_group_name,
        :filter_name => self.filter_name
      )
      @options[:modified] = true
    end
  end
end
