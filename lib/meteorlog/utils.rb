module Meteorlog::Utils
  def matched?(name, include_r, exclude_r)
    result = true

    if exclude_r
      result &&= name !~ exclude_r
    end

    if include_r
      result &&= name =~ include_r
    end

    result
  end
  module_function :matched?

  def collect_to_hash(collection, *key_attrs)
    opts = key_attrs.last.kind_of?(Hash) ? key_attrs.pop : {}
    hash = {}

    collection.each do |item|
      if block_given?
        key = yield(item)
      else
        key = key_attrs.map {|k| item.send(k) }
        key = key.first if key_attrs.length == 1
      end

      if opts[:has_many]
        hash[key] ||= []
        hash[key] << item
      else
        hash[key] = item
      end
    end

    return hash
  end
  module_function :collect_to_hash
end
