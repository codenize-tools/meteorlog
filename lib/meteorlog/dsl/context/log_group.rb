class Meteorlog::DSL::Context::LogGroup
  include Meteorlog::DSL::Validator

  attr_reader :result

  def initialize(name, &block)
    @error_identifier = "LogGroup `#{name}`"
    @result = OpenStruct.new(
      :log_group_name => name,
      :log_streams => [],
      :metric_filters => [],
    )
    instance_eval(&block)
  end

  def any_log_streams
    _call_once(:any_log_streams)
    @result.any_log_streams = true
  end

  def log_stream(name)
    _required(:log_stream_name, name)
    _validate("LogStream `#{name}` is already defined") do
      @result.log_streams.all? {|i| i.log_stream_name != name }
    end

    @result.log_streams << OpenStruct.new(:log_stream_name => name)
  end

  def metric_filter(name, &block)
    _required(:filter_name, name)
    _validate("MetricFilter `#{name}` is already defined") do
      @result.metric_filters.all? {|i| i.filter_name != name }
    end

    @result.metric_filters << Meteorlog::DSL::Context::MetricFilter.new(name, @result.log_group_name, &block).result
  end
end
