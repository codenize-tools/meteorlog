class Meteorlog::Exporter
  class << self
    def export(cloud_watch_logs, opts = {})
      self.new(cloud_watch_logs, opts).export
    end
  end # of class methods

  def initialize(cloud_watch_logs, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @options = options
  end

  def export
    result = {}

    log_groups = @cloud_watch_logs.describe_log_groups.each.inject([]) {|r, i| r + i.log_groups }

    log_groups.each do |log_group|
      export_log_graoup(log_group, result)
    end

    return result
  end

  private

  def export_log_graoup(log_group, result)
    log_group_name = log_group.log_group_name

    return unless Meteorlog::Utils.matched?(log_group_name, @options[:include], @options[:exclude])

    log_streams = @cloud_watch_logs.describe_log_streams(
      :log_group_name => log_group_name).log_streams
    metric_filters = @cloud_watch_logs.describe_metric_filters(
      :log_group_name => log_group_name).metric_filters

    result[log_group_name] = {
      :log_streams => export_log_streams(log_streams),
      :metric_filters => export_metric_filters(metric_filters)
    }
  end

  def export_log_streams(log_streams)
    log_streams.map {|log_stream| log_stream.log_stream_name }
  end

  def export_metric_filters(metric_filters)
    result = {}

    metric_filters.each do |metric_filter|
      filter_name = metric_filter.filter_name
      metric_transformations = metric_filter.metric_transformations.map do |metric_transformation|
        {
          :metric_namespace => metric_transformation.metric_namespace,
          :metric_name => metric_transformation.metric_name,
          :metric_value => metric_transformation.metric_value,
        }
      end

      result[filter_name] = {
        :metric_transformations => metric_transformations
      }

      if metric_filter.filter_pattern
        result[filter_name][:filter_pattern] = metric_filter.filter_pattern
      end
    end

    return result
  end
end
