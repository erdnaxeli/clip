module Clip::Mapper
  macro included
    extend Clip::Help
  end

  def initialize(command : Array(String))
    {% begin %}
      command = command.flat_map do |param|
        if param.starts_with?("--")
          param.split('=')
        elsif param.starts_with?('-')
          param[1...].chars.map { |x| "-#{x}" }
        else
          param
        end
      end

      arguments_errors = Hash(String, Clip::Errors).new
      options_errors = Hash(String, Clip::Errors).new

      # We first handle options.
      {% for ivar in @type.instance_vars %}
        {% if !ivar.annotation(Argument) && (
                ivar.has_default_value? || ivar.annotation(Option) ||
                  ivar.type == Bool || ivar.type == Bool?
              ) %}
          {% if ivar.annotation(Option) %}
            {% if ivar.annotation(Option).args.size > 0 %}
              option_names = {{ivar.annotation(Option).args}}
              {% ivar.annotation(Option).args.each do |x|
                   raise "option #{x} does not start with an hyphen" if !x.starts_with?('-')
                 end %}
            {% else %}
              option_names = {"--{{ivar.id.gsub(/_/, "-")}}"}
            {% end %}
          {% else %}
            option_names = {"--{{ivar.id.gsub(/_/, "-")}}"}
          {% end %}

          {% if ivar.type == Bool || ivar.type == Bool? %}
            idx = nil
            option_names.each do |option_name|
              idx = command.index(option_name)
              break if !idx.nil?
            end

            no_idx = command.index("--no-{{ivar.id.gsub(/_/, "-")}}")

            if !idx.nil?
              value = command.delete_at(idx, 1)[0]
              @{{ivar.id}} = true
            elsif !no_idx.nil?
              value = command.delete_at(no_idx, 1)[0]
              @{{ivar.id}} = false
              {% if !ivar.has_default_value? %}
            else
              options_errors[option_names[0]] = Clip::Errors::Required
              @{{ivar.id}} = true
              {% end %}
            end
          {% elsif ivar.type == String || ivar.type == String? ||
                     ivar.type < Int || ivar.type < Float ||
                     ivar.type.union_types.all? { |x| x == Nil || x < Int } ||
                     ivar.type.union_types.all? { |x| x == Nil || x < Float } %}
            idx = nil
            option_name = ""
            option_names.each do |name|
              option_name = name
              idx = command.index(name)
              break if !idx.nil?
            end

            if !idx.nil?
              if !command[idx + 1]? || command[idx + 1].starts_with?('-')
                command.delete_at(idx)
                options_errors[option_name] = Clip::Errors::MissingValue
                {% if !ivar.has_default_value? %}
                  {% if ivar.type.nilable? %}
                    @{{ivar.id}} = nil
                  {% elsif ivar.type == String %}
                    @{{ivar.id}} = ""
                  {% else %}
                    @{{ivar.id}} = 0
                  {% end %}
                {% end %}
              else
                value = command.delete_at(idx, 2)[1]
                {% if ivar.type == String || ivar.type == String? %}
                  @{{ivar.id}} = value
                {% else %}
                  {% if !ivar.has_default_value? %}
                    # We need to initialize the variable first, see
                    # https://github.com/crystal-lang/crystal/issues/5931
                    {% if ivar.type == String %}
                      @{{ivar.id}} = ""
                    {% else %}
                      @{{ivar.id}} = 0
                    {% end %}
                  {% end %}
                  begin
                    {% if ivar.type.nilable? %}
                      {% var_type = ivar.type.union_types.find { |x| x != Nil } %}
                      @{{ivar.id}} = {{var_type}}.new(value)
                    {% else %}
                      @{{ivar.id}} = {{ivar.type.id}}.new(value)
                    {% end %}
                  rescue ArgumentError
                    options_errors[option_name] = Clip::Errors::InvalidValue
                  end
                {% end %}
              end
              {% if !ivar.has_default_value? %}
                else
                  options_errors[option_names[0]] = Clip::Errors::Required
                  {% if ivar.type.nilable? %}
                    @{{ivar.id}} = nil
                  {% elsif ivar.type == String %}
                    @{{ivar.id}} = ""
                  {% else %}
                    @{{ivar.id}} = 0
                  {% end %}
              {% end %}
            end
          {% else %}
            {% raise "Unsupported type #{ivar.type.stringify}." %}
          {% end %}
        {% end %}
      {% end %}

      command.reject! do |option|
        if option =~ /^-/
          options_errors[option] = Clip::Errors::Unknown
          true
        end
      end

      # Then all that is left on `command` should be arguments.
      {% for ivar in @type.instance_vars %}
        {% if ivar.type != Bool && ivar.type != Bool? && !ivar.annotation(Option) &&
                (!ivar.has_default_value? || ivar.annotation(Argument)) %}
          {% if !(
                  ivar.type == String || ivar.type == String? ||
                    ivar.type < Int || ivar.type < Float ||
                    ivar.type.union_types.all? { |x| x == Nil || x < Int } ||
                    ivar.type.union_types.all? { |x| x == Nil || x < Float }
                ) %}
            {% raise "Unsupported type #{ivar.type.stringify}." %}
          {% end %}

          if value = command.shift?
            {% if ivar.type == String || ivar.type == String? %}
              @{{ivar.id}} = value
            {% else %}
              {% if !ivar.has_default_value? %}
                # We need to initialize the variable first, see
                # https://github.com/crystal-lang/crystal/issues/5931
                {% if ivar.type == String %}
                  @{{ivar.id}} = ""
                {% else %}
                  @{{ivar.id}} = 0
                {% end %}
              {% end %}
              begin
                {% if ivar.type.nilable? %}
                  {% var_type = ivar.type.union_types.find { |x| x != Nil } %}
                  @{{ivar.id}} = {{var_type}}.new(value)
                {% else %}
                  @{{ivar.id}} = {{ivar.type.id}}.new(value)
                {% end %}
              rescue ArgumentError
                options_errors[{{ivar.stringify}}] = Clip::Errors::InvalidValue
              end
            {% end %}
            {% if !ivar.has_default_value? %}
              else
                arguments_errors[{{ivar.stringify}}] = Clip::Errors::Required
                {% if ivar.type == String %}
                  @{{ivar.id}} = ""
                {% else %}
                  @{{ivar.id}} = 0
                {% end %}
            {% end %}
          end
        {% end %}
      {% end %}

      if options_errors.size > 0 || arguments_errors.size > 0
        raise Clip::ParsingError.new(arguments_errors, options_errors)
      end
    {% end %}
  end
end