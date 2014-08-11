class Meteorlog::Wrapper::MetricFilterCollection
  include Meteorlog::Logger::Helper

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
    log(:info, 'Create MetricFilter', :cyan, "#{@log_group.log_group_name} > #{name}")

    params = {
      :log_group_name => @log_group.log_group_name,
      :filter_name => name,
      :filter_pattern => opts[:filter_pattern] || '',
      :metric_transformations => opts[:metric_transformations],
    }

    unless @options[:dry_run]
      @cloud_watch_logs.put_metric_filter(params)
      @options[:modified] = true
    end

    metric_filter = OpenStruct.new(params)

    Meteorlog::Wrapper::MetricFilter.new(metric_filter, @log_group, @options)
  end
end
