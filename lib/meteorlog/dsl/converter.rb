class Meteorlog::DSL::Converter
  class << self
    def convert(exported, opts = {})
      self.new(exported, opts).convert
    end
  end # of class methods

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    @exported.each.map {|log_group_name, log_group_attrs|
      output_log_group(log_group_name, log_group_attrs)
    }.join("\n")
  end

  private

  def output_log_group(log_group_name, log_group_attrs)
    log_group_name = log_group_name.inspect
    buf = []
    streams = log_group_attrs[:log_streams]
    buf << output_streams(streams, :prefix => '  ') if streams
    metric_filters = (log_group_attrs[:metric_filters] || [])
    buf << output_metric_filters(metric_filters, :prefix => '  ') unless metric_filters.empty?

    <<-EOS
log_group #{log_group_name} do
  #{buf.join("\n\n  ")}
end
    EOS
  end

  def output_streams(streams, opts = {})
    prefix = opts[:prefix]

    streams.map {|stream|
      "log_stream #{stream.inspect}"
    }.join("\n#{prefix}")
  end

  def output_metric_filters(metric_filters, opts = {})
    prefix = opts[:prefix]

    metric_filters.map {|metric_filter_name, metric_filter_attrs|
      metric_filter_name = metric_filter_name.inspect
      filter_pattern = metric_filter_attrs[:filter_pattern]
      metrics = metric_filter_attrs[:metric_transformations] || []

      buf = []
      buf << "metric_filter #{metric_filter_name} do"
      buf << "  filter_pattern #{filter_pattern.inspect}" if filter_pattern
      buf << "  " + output_metrics(metrics, :prefix => prefix + '  ') unless metrics.empty?
      buf << "end"
      buf.join("\n#{prefix}")
    }.join("\n\n#{prefix}")
  end

  def output_metrics(metrics, opts = {})
    prefix = opts[:prefix]

    metrics.map {|metric|
      name = metric[:metric_name].inspect
      metric_namespace = metric[:metric_namespace].inspect
      metric_value = metric[:metric_value].inspect

      [
        "metric #{name} do",
        "  metric_namespace #{metric_namespace}",
        "  metric_value #{metric_value}",
        "end",
      ].join("\n#{prefix}")
    }.join("\n#{prefix}")
  end
end
__END__
{"/var/log/messages"=>
  {:log_streams=>["i-c8a53ed1"],
   :metric_filters=>
    {"MyAppAccessCount"=>
      {:metric_transformations=>
        [{:metric_name=>"EventCount",
          :metric_namespace=>"YourNamespace",
          :metric_value=>"1"}]}}}}

log_group "/var/log/messages" do
  stream "i-c8a53ed1"

  filter "MyAppAccessCount" do
    pattern "FilterPattern"

    metric "EventCount" do
      namespace "YourNamespace"
      value "1"
    end
  end
end
