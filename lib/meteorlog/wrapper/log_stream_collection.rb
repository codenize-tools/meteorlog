class Meteorlog::Wrapper::LogStreamCollection
  include Meteorlog::Logger::Helper

  def initialize(cloud_watch_logs, log_streams, log_group, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @log_streams = log_streams
    @log_group = log_group
    @options = options
  end

  def each
    @log_streams.each do |log_stream|
      yield(Meteorlog::Wrapper::LogStream.new(
        @cloud_watch_logs, log_stream, @log_group, @options))
    end
  end

  def create(name, opts = {})
    log(:info, 'Create LogStream', :cyan, name)

    unless @options[:dry_run]
      @cloud_watch_logs.create_log_stream(
        :log_group_name => @log_group.log_group_name,
        :log_stream_name => name
      )
      @options[:modified] = true
    end

    log_stream = OpenStruct.new(
      :log_stream_name => name
    )

    Meteorlog::Wrapper::LogStream.new(log_stream, @log_group, @options)
  end
end
