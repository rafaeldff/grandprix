class Grandprix::Elements
  def self.build array
    elements = array.map do |element|
      if element =~ /([^=]*)=(.*)$/
        [$1, $2]
      else
        [element]
      end
    end
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
      @array.find {|e| e.first == name}
    end

    self.class.new(new_array)
  end

  # extra is a hash from names to array of names
  def alongside(extra)
    extra_elements = self.class.build extra.values.flatten.uniq
    self + extra_elements
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

end
