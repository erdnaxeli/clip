enum Clip::Errors
  InvalidValue
  MissingValue
  Required
  Unknown
end

class Clip::ParsingError < Exception
  getter arguments : Hash(String, Clip::Errors)
  getter options : Hash(String, Clip::Errors)

  def initialize(
    @arguments = Hash(String, Clip::Errors).new,
    @options = Hash(String, Clip::Errors).new
  )
    super("Error with arguments (#{@arguments}) and / or options (#{@options})")
  end
end
