class Meteorlog::Wrapper::MetricFilter
  extend Forwardable
  include Meteorlog::Logger::Helper

  DEFAULT_VALUES = {}

  def_delegators :@metric_filter,
    :filter_name, :filter_pattern, :metric_transformations
  def_delegator :@log_group, :log_group_name

  def initialize(cloud_watch_logs, metric_filter, log_group, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @metric_filter = metric_filter
    @log_group = log_group
    @options = options
  end

  def eql?(dsl)
    diff(dsl).empty?
  end

  def update(dsl)
    delta = diff(dsl)
    log(:info, 'Update MetricFilter', :green, "#{self.log_group_name} > #{self.filter_name}: #{format_delta(delta)}")

    unless @options[:dry_run]
      @cloud_watch_logs.put_metric_filter(
        :log_group_name => self.log_group_name,
        :filter_name => self.filter_name,
        :filter_pattern => dsl[:filter_pattern] || '',
        :metric_transformations => dsl[:metric_transformations])
      @options[:modified] = true
    end
  end

  def delete
    log(:info, 'Delete MetricFilter', :red, "#{self.log_group_name} > #{self.filter_name}")

    unless @options[:dry_run]
      @cloud_watch_logs.delete_metric_filter(
        :log_group_name => self.log_group_name,
        :filter_name => self.filter_name)
      @options[:modified] = true
    end
  end

  private

  def diff(dsl)
    delta = {}

    [
      [:filter_pattern, self.filter_pattern, dsl[:filter_pattern]],
      [:metric_transformations,
        self.metric_transformations.map {|i| i.to_h }, dsl[:metric_transformations]],
    ].each do |name, self_value, dsl_value|
      if normalize(name, self_value) != normalize(name, dsl_value)
        delta[name] = {:old => self_value, :new => dsl_value}
      end
    end

    return delta
  end

  def format_delta(delta)
    delta.map {|name, values|
      "#{name}(#{values[:old].inspect} --> #{values[:new].inspect})"
    }.join(', ')
  end

  def normalize(name, value)
    if [Array, Hash].any? {|c| value.kind_of?(c) }
      value.sort
    elsif DEFAULT_VALUES.has_key?(name) and value.nil?
      DEFAULT_VALUES[name]
    else
      value
    end
  end
end
