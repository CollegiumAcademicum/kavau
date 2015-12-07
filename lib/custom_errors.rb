class MissingInformationError < StandardError
  def initialize(object)
    @address = object 
  end

  def address
    @address
  end
end

class MissingTemplateError < StandardError
  attr_reader :klass, :year
  def initialize(klass, year = nil)
    @klass = klass
    @year = year
  end
end
