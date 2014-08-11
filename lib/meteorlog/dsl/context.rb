class Meteorlog::DSL::Context
  include Meteorlog::DSL::Validator

  class << self
    def eval(dsl, path, opts = {})
      self.new(path, opts) {
        eval(dsl, binding, path)
      }
    end
  end # of class methods

  attr_reader :result

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = OpenStruct.new(:log_groups => [])
    @log_group_names = []
    instance_eval(&block)
  end

  private

  def require(file)
    logsfile = File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(logsfile)
      instance_eval(File.read(logsfile), logsfile)
    elsif File.exist?(logsfile + '.rb')
      instance_eval(File.read(logsfile + '.rb'), logsfile + '.rb')
    else
      Kernel.require(file)
    end
  end

  def log_group(name, &block)
    _required(:log_group_name, name)
    _validate("LogGroup `#{name}` is already defined") do
      not @log_group_names.include?(name)
    end

    @result.log_groups << Meteorlog::DSL::Context::LogGroup.new(name, &block).result
    @log_group_names << name
  end
end
