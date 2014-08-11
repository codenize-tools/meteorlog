class Meteorlog::DSL::Context::MetricFilter
  include Meteorlog::DSL::Validator

  attr_reader :result

  def initialize(name, log_group_name, &block)
    @error_identifier = "LogGroup `#{log_group_name}` > MetricFilter `#{name}`"
    @result = OpenStruct.new(
      :filter_name => name,
      :metric_transformations => [],
    )
    instance_eval(&block)
  end

  def filter_pattern(pattern)
    _call_once(:filter_pattern)
    _required(:filter_pattern, pattern)
    @result.filter_pattern = filter_pattern.to_s
  end

  def metric(attrs)
    metric_attrs = {}
    _expected_type(attrs, Hash)
    {
      :name => :metric_name,
      :namespace => :metric_namespace,
      :value => :metric_value
    }.each do |attr_name, metric_name|
      _required("metric[#{attr_name}]", attrs[attr_name])
      metric_attrs[metric_name] = attrs[attr_name].to_s
    end
    _expected_length(metric_attrs, 3)

    @result.metric_transformations << metric_attrs
  end
end
