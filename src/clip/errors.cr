enum Clip::Errors
  InvalidValue
  MissingValue
  Required
  Unknown
end

class Clip::MissingCommand < Exception
end

class Clip::ParsingError < Exception
  getter arguments : Hash(String, Clip::Errors)
  getter options : Hash(String, Clip::Errors)

  def initialize(
    @arguments = Hash(String, Clip::Errors).new,
    @options = Hash(String, Clip::Errors).new
  )
    msg = String.build do |str|
      str << "Error:"

      @options.each do |option, error|
        str << "\n  "

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

        str << option
      end

      @arguments.each do |argument, error|
        str << "\n  "

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

        str << argument.upcase
      end
    end
    super(msg)
  end
end

class Clip::UnknownCommand < Exception
end
