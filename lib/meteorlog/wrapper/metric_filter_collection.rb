class Meteorlog::Wrapper::MetricFilterCollection
  extend Forwardable
  include Meteorlog::Logger::Helper

  def_delegator :@log_group, :log_group_name

  def initialize(cloud_watch_logs, metric_filters, log_group, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @metric_filters = metric_filters
    @log_group = log_group
    @options = options
  end

  def each
    @metric_filters.each do |metric_filter|
      yield(Meteorlog::Wrapper::MetricFilter.new(
        @cloud_watch_logs, metric_filter, @log_group, @options))
    end
  end

  def create(name, opts = {})
    log(:info, 'Create MetricFilter', :cyan, "#{self.log_group_name} > #{name}")

    unless @options[:dry_run]
      @cloud_watch_logs.put_metric_filter(
        :log_group_name => self.log_group_name,
        :filter_name => name,
        :filter_pattern => opts[:filter_pattern] || '',
        :metric_transformations => opts[:metric_transformations])
      @options[:modified] = true
    end

    metric_filter = OpenStruct.new(
      :filter_name => name,
      :filter_pattern => opts[:filter_pattern],
      :metric_transformations => opts[:metric_transformations])

    Meteorlog::Wrapper::MetricFilter.new(metric_filter, @log_group, @options)
  end
end
