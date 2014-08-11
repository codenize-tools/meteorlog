class Meteorlog::DSL
  class << self
    def convert(exported, opts = {})
      Meteorlog::DSL::Converter.convert(exported, opts)
    end

    def parse(dsl, path, opts = {})
      Meteorlog::DSL::Context.eval(dsl, path, opts).result
    end
  end # of class methods
end
