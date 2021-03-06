module Clip::Help
  def help(name : String? = PROGRAM_NAME)
    {% begin %}
      {% options = [] of _ %}
      {% arguments = [] of _ %}

      {%
        @type.instance_vars.map do |ivar|
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

          if !ivar.annotation(Argument) && (
               ivar.has_default_value? || ivar.annotation(Option) || ivar.type == Bool
             )
            options << ivar
          elsif ivar.type != Bool && ivar.type != Bool? && !ivar.annotation(Option) &&
                (!ivar.has_default_value? || ivar.annotation(Argument))
            arguments << ivar
          end
        end
      %}

      {%
        options = options.sort_by do |x|
          if ivar.annotation(Option) && ivar.annotation(Option).args.size > 0
            ivar.annotation(Option).args[0]
          else
            "--#{ivar.id.gsub(/_/, "-")}"
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

      {% help = " [OPTIONS]" %}

      {% for argument in arguments %}
        {% help += " " %}

        {% if argument.has_default_value? %}
          {% help += "[" + argument.stringify.upcase + "]" %}
        {% else %}
          {% help += argument.stringify.upcase %}
        {% end %}

        {% if argument.type < Array ||
                argument.type.union_types.all? { |x| x == Nil || x < Array } %}
          {% help += "..." %}
        {% end %}
      {% end %}

      {% if @type.annotation(Doc) %}
        {% if @type.annotation(Doc).args.size != 1 %}
          {% raise "The annotation Clip::Doc expects exactly one argument." %}
        {% end %}

        {% doc = "" %}
        {% line = [] of _ %}
        {% for word in @type.annotation(Doc).args[0].split(' ') %}
          {% if (line + [word]).join(' ').size <= 80 %}
            {% line << word %}
          {% else %}
            {% doc += line.join(' ') + "\n" %}
            {% line = [word] %}
          {% end %}
        {% end %}

        {% if line.size > 0 %}
          {% doc += line.join(' ') + "\n" %}
        {% end %}

        {% help += "\n\n" + doc %}
      {% else %}
        {% help += "\n" %}
      {% end %}

      {% if arguments.size > 0 %}
        {% help += "\nArguments:\n" %}

        {% max_argument_size = 0 %}
        {% for ivar in arguments %}
          {% size = ivar.stringify.size %}
          {% if size > max_argument_size %}
            {% max_argument_size = size %}
          {% end %}
        {% end %}

        {% if max_argument_size > 30 %}
          {% max_argument_size = 30 %}
        {% end %}

        {% shift = 2 + max_argument_size + 2 %}

        {% for ivar in arguments %}
          {% current_argument = "  " + ivar.stringify.upcase %}

          {% suffix = "" %}
          {% if ivar.has_default_value? %}
            {% if ivar.default_value != nil %}
              {% suffix = "[default: #{ivar.default_value.id.gsub(/"/, "")}]" %}
            {% end %}
          {% else %}
            {% suffix = "[required]" %}
          {% end %}

          {% lines = [] of _ %}
          {% if ivar.annotation(Doc) %}
            {% if ivar.annotation(Doc).args.size != 1 %}
              {% raise "The annotation Clip::Doc expects exactly one argument." %}
            {% end %}

            {% doc = ivar.annotation(Doc).args[0] %}

            {% if shift + doc.size > 80 %}
              {% line = [] of _ %}
              {% for word in doc.split(' ') %}
                {% if word != "" %}
                  {% if shift + (line + [word]).join(' ').size <= 80 %}
                    {% line << word %}
                  {% else %}
                    {% lines << line %}
                    {% line = [word] %}
                  {% end %}
                {% end %}
              {% end %}

              {% if line.size > 0 %}
                {% lines << line %}
              {% end %}
            {% else %}
              {% lines << [doc] %}
            {% end %}

            {% if suffix != "" %}
              {% if shift + lines[-1].join(' ').size + 2 + suffix.size <= 80 %}
                {% lines[-1] << "" << suffix %}
              {% else %}
                {% lines << [suffix] %}
              {% end %}
            {% end %}
          {% else %}
            {% if suffix != "" %}
              {% lines << [suffix] %}
            {% end %}
          {% end %}

          {% if lines.size > 0 %}
            {% if current_argument.size <= 32 %}
              {% for i in current_argument.size...shift %}
                {% current_argument += ' ' %}
              {% end %}
            {% else %}
              {% current_argument += "\n" %}
              {% for i in 0...34 %}
                {% current_argument += ' ' %}
              {% end %}
            {% end %}

            {% current_argument += lines[0].join(' ') %}

            {% for line in lines[1...lines.size] %}
              {% current_argument += "\n" %}
              {% for i in 0...shift %}
                {% current_argument += ' ' %}
              {% end %}
              {% current_argument += line.join(' ') %}
            {% end %}
          {% end %}

          {% help += current_argument %}
          {% help += "\n" %}
        {% end %}
      {% end %}

      {% help += "\nOptions:\n" %}
      {% if options.size > 0 %}

        {% max_option_size = "--help".size %}
        {% for ivar in options %}
          {% if ivar.annotation(Option) && ivar.annotation(Option).args.size > 0 %}
            {% names = ivar.annotation(Option).args %}
          {% else %}
            {% names = {"--#{ivar.id.gsub(/_/, "-")}"} %}
          {% end %}

          {% type_size = 0 %}
          {% if ivar.type == Bool || ivar.type == Bool? %}
            {% if !ivar.annotation(Option) || ivar.annotation(Option).args.size == 0 %}
              {% type_size = " / --no-#{ivar.id.gsub(/_/, "-")}".size %}
            {% end %}
          {% elsif [String, String?, Array(String), Array(String)?].includes?(ivar.type) %}
            {% type_size = 5 %}
          {% elsif ivar.type < Int || ivar.type.union_types.all? { |x| x == Nil || x < Int } ||
                     (ivar.type < Array && ivar.type.type_vars.all? { |x| x == Nil || x < Int }) ||
                     ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Int }) } %}
            {% type_size = 8 %}
          {% elsif ivar.type < Float || ivar.type.union_types.all? { |x| x == Nil || x < Float } ||
                     (ivar.type < Array && ivar.type.type_vars.all? { |x| x == Nil || x < Float }) ||
                     ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Float }) } %}
            {% type_size = 6 %}
          {% end %}

          {% size = names.join(", ").size + type_size %}
          {% if size > max_option_size %}
            {% max_option_size = size %}
          {% end %}
        {% end %}

        {% if max_option_size > 30 %}
          {% max_option_size = 30 %}
        {% end %}

        {% shift = 2 + max_option_size + 2 %}
        {% for ivar in options %}
          {% if ivar.annotation(Option) && ivar.annotation(Option).args.size > 0 %}
            {% names = ivar.annotation(Option).args %}
          {% else %}
            {% names = {"--#{ivar.id.gsub(/_/, "-")}"} %}
          {% end %}

          {% current_option = "  " + names.join(", ") %}

          {% type_str = "" %}
          {% if ivar.type == Bool || ivar.type == Bool? %}
            {% if !ivar.annotation(Option) || ivar.annotation(Option).args.size == 0 %}
              {% type_str = " / --no-#{ivar.id.gsub(/_/, "-")}" %}
            {% end %}
          {% elsif [String, String?, Array(String), Array(String)?].includes?(ivar.type) %}
            {% type_str = " TEXT" %}
          {% elsif ivar.type < Int || ivar.type.union_types.all? { |x| x == Nil || x < Int } ||
                     (ivar.type < Array && ivar.type.type_vars.all? { |x| x == Nil || x < Int }) ||
                     ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Int }) } %}
            {% type_str = " INTEGER" %}
          {% elsif ivar.type < Float || ivar.type.union_types.all? { |x| x == Nil || x < Float } ||
                     (ivar.type < Array && ivar.type.type_vars.all? { |x| x == Nil || x < Float }) ||
                     ivar.type.union_types.all? { |x| x == Nil || (x < Array && x.type_vars.all? { |y| y < Float }) } %}
            {% type_str = " FLOAT" %}
          {% end %}
          {% current_option += type_str %}

          {% suffix = "" %}
          {% if ivar.has_default_value? %}
            {% if ivar.default_value != nil %}
              {% suffix = "[default: #{ivar.default_value.id.gsub(/"/, "")}]" %}
            {% end %}
          {% else %}
            {% suffix = "[required]" %}
          {% end %}

          {% lines = [] of _ %}
          {% if ivar.annotation(Doc) %}
            {% if ivar.annotation(Doc).args.size != 1 %}
              {% raise "The annotation Clip::Doc expects exactly one argument." %}
            {% end %}

            {% doc = ivar.annotation(Doc).args[0] %}

            {% if shift + doc.size > 80 %}
              {% line = [] of _ %}
              {% for word in doc.split(' ') %}
                {% if shift + (line + [word]).join(' ').size <= 80 %}
                  {% line << word %}
                {% else %}
                  {% lines << line %}
                  {% line = [word] %}
                {% end %}
              {% end %}

              {% if line.size > 0 %}
                {% lines << line %}
              {% end %}
            {% else %}
              {% lines << [doc] %}
            {% end %}

            {% if suffix != "" %}
              {% if shift + lines[-1].join(' ').size + 2 + suffix.size <= 80 %}
                {% lines[-1] << "" << suffix %}
              {% else %}
                {% lines << [suffix] %}
              {% end %}
            {% end %}
          {% else %}
            {% if suffix != "" %}
              {% lines << [suffix] %}
            {% end %}
          {% end %}

          {% if lines.size > 0 %}
            {% if current_option.size <= 32 %}
              {% for i in current_option.size...shift %}
                {% current_option += ' ' %}
              {% end %}
            {% else %}
              {% current_option += "\n" %}
              {% for i in 0...34 %}
                {% current_option += ' ' %}
              {% end %}
            {% end %}

            {% current_option += lines[0].join(' ') %}

            {% for line in lines[1...lines.size] %}
              {% current_option += "\n" %}
              {% for i in 0...shift %}
                {% current_option += ' ' %}
              {% end %}
              {% current_option += line.join(' ') %}
            {% end %}
          {% end %}

          {% help += current_option %}
          {% help += "\n" %}
        {% end %}
      {% else %}
        {% shift = 10 %}
      {% end %}

      {% help += "  --help" %}
      {% for i in 8...shift %}
        {% help += ' ' %}
      {% end %}
      {% help += "Show this message and exit.\n" %}

      String.build do |str|
        str << "Usage:"

        if !name.nil?
          str << " " << name
        end

        {% if help != "" %}
          str << {{help}}
        {% end %}
      end
    {% end %}
  end
end
