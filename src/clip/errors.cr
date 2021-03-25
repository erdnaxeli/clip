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
    msg = String.build do |str|
      str << "Error:\n"
      @options.each do |option, error|
        str << "  "

        case error
        in Errors::InvalidValue
          str << "option's value is invalid: "
        in Errors::MissingValue
          str << "option's value is missing: "
        in Errors::Required
          str << "option is required: "
        in Errors::Unknown
          str << "no such option: "
        end

        str << option << "\n"
      end

      @arguments.each do |argument, error|
        str << "  "

        case error
        in Errors::InvalidValue
          str << "argument's value is invalid: "
        in Errors::MissingValue
          str << "argument's value is missing: "
        in Errors::Required
          str << "argument is required: "
        in Errors::Unknown
          raise "BUG: unreachable"
        end

        str << argument.capitalize << "\n"
      end
    end
    super(msg)
  end
end
