module Clip::Mapper
  abstract class Help
    abstract def help
  end

  macro included
    extend Clip::Help
    extend Clip::Parse

    class Help < Clip::Mapper::Help
      @command : String?

      def initialize(path = Array(String).new)
        if path.size > 0
          @command = path.join(' ')
        else
          @command = nil
        end
      end

      def help(name : String? = PROGRAM_NAME)
        if @command
          if name.nil?
            {{@type}}.help("#{@command}")
          else
            {{@type}}.help("#{name} #{@command}")
          end
        else
          {{@type}}.help(name)
        end
      end
    end
  end

  def initialize(command : Array(String), path = Array(String).new)
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

          {% default_name = "--#{ivar.id.gsub(/_/, "-")}" %}
          {% option_names = [] of _ %}
          {% if ivar.annotation(Option) && ivar.annotation(Option).args.size > 0 %}
            {% option_names = ivar.annotation(Option).args %}
            {% ivar.annotation(Option).args.each do |x|
                 raise "option #{x} does not start with an hyphen" if !x.starts_with?('-')
               end %}
          {% end %}

          {% if ivar.type == Bool || ivar.type == Bool? %}
            idx = nil

            {% if option_names.size > 0 %}
              {{option_names}}.each do |option_name|
                idx = command.index(option_name)
                break if !idx.nil?
              end

              {% if ivar.has_default_value? %}
                {% value = !ivar.default_value %}
              {% else %}
                {% value = true %}
              {% end %}
            {% else %}
              idx = command.index({{default_name}})
              no_idx = command.index("--no-{{ivar.id.gsub(/_/, "-")}}")
              {% value = true %}
            {% end %}

            if !idx.nil?
              command.delete_at(idx)
              @{{ivar.id}} = {{value}}
            {% if option_names.size == 0 %}
              elsif !no_idx.nil?
                command.delete_at(no_idx, 1)
                @{{ivar.id}} = {{!value}}
            {% end %}
            {% if !ivar.has_default_value? %}
              else
                {% if option_names.size > 0 %}
                  options_errors[{{option_names[0]}}] = Clip::Errors::Required
                {% else %}
                  options_errors[{{default_name}}] = Clip::Errors::Required
                {% end %}
                @{{ivar.id}} = true
            {% end %}
            end
          {% elsif ivar.type == String || ivar.type == String? ||
                     ivar.type < Int || ivar.type < Float ||
                     ivar.type.union_types.all? { |x| x == Nil || x < Int } ||
                     ivar.type.union_types.all? { |x| x == Nil || x < Float } ||
                     ivar.type == Array(String) || ivar.type == Array(String)? ||
                     (ivar.type < Array && ivar.type.type_vars.all? { |x| x < Int }) ||
                     (ivar.type < Array && ivar.type.type_vars.all? { |x| x < Float }) ||
                     ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Int }) } ||
                     ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Float }) } %}
            {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
              {% if ivar.type.nilable? %}
                {% var_type = ivar.type.union_types.find { |x| x != Nil } %}
                %value = {{var_type.id}}.new
              {% else %}
                %value = {{ivar.type}}.new
              {% end %}

              loop do
            {% end %}

            {% if option_names.size > 0 %}
              idx = nil
              option_name = ""
              {{option_names}}.each do |name|
                option_name = name
                idx = command.index(name)
                break if !idx.nil?
              end
            {% else %}
              idx = command.index({{default_name}})
            {% end %}

            if idx.nil?
              {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
                break
              {% elsif !ivar.has_default_value? %}
                {% if option_names.size > 0 %}
                  options_errors[option_name] = Clip::Errors::Required
                {% else %}
                  options_errors[{{default_name}}] = Clip::Errors::Required
                {% end %}

                {% if ivar.type.nilable? %}
                  @{{ivar.id}} = nil
                {% elsif ivar.type == String %}
                  @{{ivar.id}} = ""
                {% else %}
                  @{{ivar.id}} = 0
                {% end %}
              {% end %}
            else
              if !command[idx + 1]? || command[idx + 1].starts_with?('-')
                command.delete_at(idx)
                {% if option_names.size > 0 %}
                  options_errors[option_name] = Clip::Errors::MissingValue
                {% else %}
                  options_errors[{{default_name}}] = Clip::Errors::MissingValue
                {% end %}
                {% if !(ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array }) &&
                        !ivar.has_default_value? %}
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
                {% elsif ivar.type == Array(String) || ivar.type == Array(String)? %}
                  %value << value
                {% else %}
                  {% if !(ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array }) &&
                          !ivar.has_default_value? %}
                    # We need to initialize the variable first, see
                    # https://github.com/crystal-lang/crystal/issues/5931
                    {% if ivar.type == String %}
                      @{{ivar.id}} = ""
                    {% else %}
                      @{{ivar.id}} = 0
                    {% end %}
                  {% end %}
                  begin
                    {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
                      {% if ivar.type.nilable? %}
                        {% var_type = ivar.type.union_types.find { |x| x != Nil }.type_vars[0] %}
                      {% else %}
                        {% var_type = ivar.type.type_vars[0] %}
                      {% end %}

                      %value << {{var_type.id}}.new(value)
                    {% elsif ivar.type.nilable? %}
                      {% var_type = ivar.type.union_types.find { |x| x != Nil } %}
                      @{{ivar.id}} = {{var_type.id}}.new(value)
                    {% else %}
                      @{{ivar.id}} = {{ivar.type.id}}.new(value)
                    {% end %}
                  rescue ArgumentError
                    {% if option_names.size > 0 %}
                      options_errors[option_name] = Clip::Errors::InvalidValue
                    {% else %}
                      options_errors[{{default_name}}] = Clip::Errors::InvalidValue
                    {% end %}
                  end
                {% end %}
              end
            end
            {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
              end

              {% if ivar.has_default_value? %}
                if %value.size > 0
                  @{{ivar.id}} = %value
                end
              {% else %}
                if %value.size == 0
                  {% if option_names.size > 0 %}
                    options_errors[option_name] = Clip::Errors::Required
                  {% else %}
                    options_errors[{{default_name}}] = Clip::Errors::Required
                  {% end %}
                end
                @{{ivar.id}} = %value
              {% end %}

            {% end %}
          {% else %}
            {% raise "Unsupported type #{ivar.type.stringify}" %}
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
      {% arguments = [] of _ %}
      {%
        @type.instance_vars.map do |ivar|
          if ivar.type != Bool && ivar.type != Bool? && !ivar.annotation(Option) &&
             (!ivar.has_default_value? || ivar.annotation(Argument))
            if ![Bool, Bool?, String, String?, Array(String), Array(String)?].includes?(ivar.type) &&
               !(ivar.type < Int) && !(ivar.type < Float) &&
               !ivar.type.union_types.all? { |x| x == Nil || x < Int } &&
               !ivar.type.union_types.all? { |x| x == Nil || x < Float } &&
               !(
                 ivar.type < Array && (
                   ivar.type.type_vars.all? { |x| x < Int } ||
                   ivar.type.type_vars.all? { |x| x < Float }
                 )
               ) &&
               !ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Int }) } &&
               !ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Float }) }
              raise "Unsupported type #{ivar.type.stringify}."
            end

            arguments << ivar
          end
        end
      %}
      {%
        arguments = arguments.sort_by do |x|
          if x.annotation(Argument) && x.annotation(Argument)[:idx]
            x.annotation(Argument)[:idx].stringify + x.stringify
          else
            "0" + x.stringify
          end
        end
      %}
      {% for ivar in arguments %}
        {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
          {% if ivar.type.nilable? %}
            {% var_type = ivar.type.union_types.find { |x| x != Nil } %}
            %value = {{var_type.id}}.new
          {% else %}
            %value = {{ivar.type}}.new
          {% end %}

          loop do
        {% end %}

        if value = command.shift?
          {% if ivar.type == String || ivar.type == String? %}
            @{{ivar.id}} = value
          {% elsif ivar.type == Array(String) || ivar.type == Array(String)? %}
            %value << value
          {% else %}
            {% if !(ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array }) &&
                    !ivar.has_default_value? %}
              # We need to initialize the variable first, see
              # https://github.com/crystal-lang/crystal/issues/5931
              {% if ivar.type == String %}
                @{{ivar.id}} = ""
              {% else %}
                @{{ivar.id}} = 0
              {% end %}
            {% end %}
            begin
              {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
                {% if ivar.type.nilable? %}
                  {% var_type = ivar.type.union_types.find { |x| x != Nil }.type_vars[0] %}
                {% else %}
                  {% var_type = ivar.type.type_vars[0] %}
                {% end %}

                %value << {{var_type.id}}.new(value)
              {% elsif ivar.type.nilable? %}
                {% var_type = ivar.type.union_types.find { |x| x != Nil } %}
                @{{ivar.id}} = {{var_type}}.new(value)
              {% else %}
                @{{ivar.id}} = {{ivar.type.id}}.new(value)
              {% end %}
            rescue ArgumentError
              arguments_errors[{{ivar.stringify}}] = Clip::Errors::InvalidValue
            end
          {% end %}
          {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
            else
              break
          {% elsif !ivar.has_default_value? %}
            else
              arguments_errors[{{ivar.stringify}}] = Clip::Errors::Required
              {% if ivar.type.nilable? %}
                @{{ivar.id}} == nil
              {% elsif ivar.type == String %}
                @{{ivar.id}} = ""
              {% else %}
                @{{ivar.id}} = 0
              {% end %}
          {% end %}
        end

        {% if ivar.type < Array || ivar.type.union_types.all? { |x| x == Nil || x < Array } %}
          end

          {% if ivar.has_default_value? %}
            if %value.size > 0
              @{{ivar.id}} = %value
            end
          {% else %}
            if %value.size == 0
              options_errors[{{ivar.stringify}}] = Clip::Errors::Required
            end
            @{{ivar.id}} = %value
          {% end %}

        {% end %}
      {% end %}

      if options_errors.size > 0 || arguments_errors.size > 0
        raise Clip::ParsingError.new(arguments_errors, options_errors)
      end
    {% end %}
  end
end
