class Meteorlog::Wrapper::LogStream
  extend Forwardable
  include Meteorlog::Logger::Helper

  def_delegator :@log_stream, :log_stream_name
  def_delegator :@log_group, :log_group_name

  def initialize(cloud_watch_logs, log_stream, log_group, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @log_stream = log_stream
    @log_group = log_group
    @options = options
  end

  def delete
    log(:info, 'Delete LogStream', :red, "#{self.log_group_name} > #{self.log_stream_name}")

    unless @options[:dry_run]
      @cloud_watch_logs.delete_log_stream(
        :log_group_name => self.log_group_name,
        :log_stream_name => self.log_stream_name)
      @options[:modified] = true
    end
  end
end
