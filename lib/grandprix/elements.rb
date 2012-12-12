class Grandprix::Elements
  def self.build array
    elements = array.map {|element| element.split '=' }
    self.new(elements)
  end

  def initialize(array)
    @array = array
  end

  #other is also an Elements object
  def +(other)
    self.class.new(@array + other.underlying)
  end

  #except is an array of names
  def except(other)
    self.class.new(@array.reject {|e| other.include? e.first})
  end

  # ordering is an array of names
  def reorder(ordering)
    names_in_order = ordering & names
    new_array = names_in_order.map do |name| 
      find(name)
    end

    self.class.new(new_array)
  end

  # extra is a hash from names to array of names
  def alongside(extra)
    extra_pairs = extra.flat_map do |origin_name, destination_names|
      local_pair = find(origin_name)
      if local_pair and local_pair.size == 2
        extra = local_pair[1]
        destination_names.map {|d| [d, extra] }
      else
        destination_names.map {|d| [d] }
      end
    end
    
    #self + extra_elements
    self.class.new(@array + extra_pairs)
  end

  # annotations is a hash of names to metadata
  def annotate(annotations)
    def value_component(value)
      return nil if value.nil?
      return value if value.is_a? String
      return JSON.dump(value)
    end

    new_elements = underlying.map do |element|
      name = element.first
      find(name).clone.tap do |row|
        annotation = value_component annotations[name]
        row[2] = annotation unless annotation.nil?
      end
    end

    self.class.new new_elements
  end

  def strings
    underlying.map {|e| e.join("=") }
  end

  def names
    @array.map &:first
  end

  def to_a
    names
  end

  def underlying
    @array
  end

  def ==(other)
    return false unless other.respond_to?(:underlying)
    self.underlying == other.underlying
  end

  private
  def find(name)
    @array.find {|e| e.first == name}
  end

end
