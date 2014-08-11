class Meteorlog::Wrapper::LogGroupCollection
  include Meteorlog::Logger::Helper

  def initialize(cloud_watch_logs, log_groups, options = {})
    @cloud_watch_logs = cloud_watch_logs
    @log_groups = log_groups
    @options = options
  end

  def each
    @log_groups.each do |log_group|
      yield(Meteorlog::Wrapper::LogGroup.new(
        @cloud_watch_logs, log_group, @options))
    end
  end

  def create(name, opts = {})
    log(:info, 'Create LogGroup', :cyan, name)

    unless @options[:dry_run]
      @cloud_watch_logs.create_log_group(:log_group_name => name)
      @options[:modified] = true
    end

    log_group = OpenStruct.new(
      :log_group_name => name, :log_streams => [], :metric_filters => [])

    Meteorlog::Wrapper::LogGroup.new(
      @cloud_watch_logs, log_group, @options)
  end
end
