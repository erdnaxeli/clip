enum Clip::Errors
  Required
end

class Clip::ParsingError < Exception
  getter arguments : Hash(String, Clip::Errors)
  getter options : Hash(String, Clip::Errors)

  def initialize(
    @arguments = Hash(String, Clip::Errors).new,
    @options = Hash(String, Clip::Errors).new
  )
  end
end
