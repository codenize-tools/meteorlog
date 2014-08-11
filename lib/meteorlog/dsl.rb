class Meteorlog::DSL
  class << self
    def convert(exported, opts = {})
      Meteorlog::DSL::Converter.convert(exported, opts)
    end
  end # of class methods
end
