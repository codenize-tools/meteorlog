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
