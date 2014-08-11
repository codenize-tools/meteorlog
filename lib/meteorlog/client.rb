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
      aws_log_group = aws_log_groups[log_group_name]

      unless aws_log_group
        # XXX:
        puts :create
        #aws_log_groups[:log_group_name] = aws_log_group
      end
    end

    dsl_log_groups.each do |log_group_name, dsl_log_group|
      aws_log_group = aws_log_groups.delete(log_group_name)
      walk_log_group(dsl_log_group, aws_log_group)
    end

    aws_log_groups.each do |log_group_name, aws_log_group|
      # XXX:
      puts :delete
      #aws_log_group.delete
    end

    aws.modified?
  end

  def walk_log_group(dsl_log_group, aws_log_group)
    # XXX:
    puts :update
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
