class Meteorlog::Client
  include Meteorlog::Logger::Helper
  include Meteorlog::Utils

  def initialize(options = {})
    @options = options
    @cloud_watch_logs = Aws::CloudWatchLogs::Client.new
  end

  def export(opts = {})
    exported = Meteorlog::Exporter.export(@cloud_watch_logs, @options.merge(opts))
    Meteorlog::DSL.convert(exported, @options.merge(opts))
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    dsl = load_file(file)
    dsl_log_groups = collect_to_hash(dsl.log_groups, :log_group_name)
    aws = Meteorlog::Wrapper.wrap(@cloud_watch_logs, @options)
    aws_log_groups = collect_to_hash(aws.log_groups, :log_group_name)

    dsl_log_groups.each do |log_group_name, dsl_log_group|
      next unless Meteorlog::Utils.matched?(log_group_name, @options[:include], @options[:exclude])
      aws_log_group = aws_log_groups[log_group_name]

      unless aws_log_group
        aws_log_group = aws.log_groups.create(log_group_name)
        aws_log_groups[log_group_name] = aws_log_group
      end
    end

    dsl_log_groups.each do |log_group_name, dsl_log_group|
      next unless Meteorlog::Utils.matched?(log_group_name, @options[:include], @options[:exclude])
      aws_log_group = aws_log_groups.delete(log_group_name)
      walk_log_group(dsl_log_group, aws_log_group)
    end

    unless @options[:skip_delete_group]
      aws_log_groups.each do |log_group_name, aws_log_group|
        next unless Meteorlog::Utils.matched?(log_group_name, @options[:include], @options[:exclude])
        aws_log_group.delete
      end
    end

    aws.modified?
  end

  def walk_log_group(dsl_log_group, aws_log_group)
    unless dsl_log_group.any_log_streams
      walk_log_streams(dsl_log_group.log_streams, aws_log_group.log_streams)
    end

    walk_metric_filters(dsl_log_group.metric_filters, aws_log_group.metric_filters)
  end

  def walk_log_streams(dsl_log_streams, aws_log_streams)
    collection_api = aws_log_streams
    dsl_log_streams = collect_to_hash(dsl_log_streams, :log_stream_name)
    aws_log_streams = collect_to_hash(aws_log_streams, :log_stream_name)

    dsl_log_streams.each do |log_stream_name, dsl_log_stream|
      aws_log_stream = aws_log_streams.delete(log_stream_name)

      unless aws_log_stream
        collection_api.create(log_stream_name)
      end
    end

    aws_log_streams.each do |log_stream_name, aws_log_stream|
      aws_log_stream.delete
    end
  end

  def walk_metric_filters(dsl_metric_filters, aws_metric_filters)
    collection_api = aws_metric_filters
    dsl_metric_filters = collect_to_hash(dsl_metric_filters, :filter_name)
    aws_metric_filters = collect_to_hash(aws_metric_filters, :filter_name)

    dsl_metric_filters.each do |filter_name, dsl_metric_filter|
      aws_metric_filter = aws_metric_filters.delete(filter_name)

      if aws_metric_filter
        unless aws_metric_filter.eql?(dsl_metric_filter)
          aws_metric_filter.update(dsl_metric_filter)
        end
      else
        collection_api.create(filter_name, dsl_metric_filter)
      end
    end

    aws_metric_filters.each do |filter_name, aws_metric_filter|
      aws_metric_filter.delete
    end
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Meteorlog::DSL.parse(f.read, file)
      end
    elsif file.respond_to?(:read)
      Meteorlog::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
