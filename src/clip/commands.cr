module Clip
  macro add_commands(mapping)
    macro finished
      \{% mapping = {{mapping}} %}
      {% verbatim do %}
        {% unless mapping.is_a?(HashLiteral) || mapping.is_a?(NamedTupleLiteral) %}
          {% raise "Clip::add_commands's argument must be a hash or a named tuple." %}
        {% end %}

        def self.new(command : Array(String))
          if command.size == 0
            raise Clip::MissingCommand.new
          end

          case command[0]
          {% for key, value in mapping %}
            {% if mapping.is_a?(NamedTupleLiteral) %}
              {% key = key.id.stringify %}
            {% end %}

            when {{key}}
              {{value.id}}.parse(command[1...])
          {% end %}
          else
            raise Clip::UnknownCommand.new(command[0])
          end
        end

        def self.help(name = PROGRAM_NAME)
          {% help = "COMMAND [ARGS]...\n\nCommands:\n" %}

          {% max_command_size = "help".size %}
          {% for key, value in mapping %}
            {% if key.size > max_command_size %}
              {% max_command_size = key.size %}
            {% end %}
          {% end %}

          {% max_command_size = 30 if max_command_size > 30 %}

          {% shift = 2 + max_command_size + 2 %}
          {% for key, value in mapping %}
            {% if mapping.is_a?(NamedTupleLiteral) %}
              {% key = key.id.stringify %}
            {% end %}

            {% current_command = "  " + key %}

            {% if ann_doc = value.resolve.annotation(Clip::Doc) %}
              {% if ann_doc.args.size != 1 %}
                {% raise "The annotation Clip::Doc expects exactly one argument." %}
              {% end %}

              {% doc = ann_doc.args[0] %}

              {% lines = [] of _ %}
              {% if shift + doc.size > 80 %}
                {% line = [] of _ %}
                {% for word in doc.split(' ') %}
                  {% if word != "" %}
                    {% if shift + line.join(' ').size + 1 + word.size <= 80 %}
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

              {% if current_command.size <= 32 %}
                {% for i in current_command.size...shift %}
                  {% current_command += ' ' %}
                {% end %}
              {% else %}
                {% current_command += "\n" %}
                {% for i in 0...34 %}
                  {% current_command += ' ' %}
                {% end %}
              {% end %}

              {% current_command += lines[0].join(' ') %}

              {% for line in lines[1...lines.size] %}
                {% current_command += "\n" %}
                {% for i in 0...shift %}
                  {% current_command += ' ' %}
                {% end %}
                {% current_command += line.join(' ') %}
              {% end %}
            {% end %}

            {% help += current_command %}
            {% help += "\n" %}
          {% end %}

          {% help += "  help" %}
          {% for i in 6...shift %}
            {% help += ' ' %}
          {% end %}
          {% help += "Show this message and exit.\n" %}

          "Usage: #{name} {{help.id}}"
        end

        def self.parse(command : Array(String) = ARGV)
          if command[0] == "help"
            {{@type}}::Help::INSTANCE
          else
            new command
          end
        end
      {% end %}
    end
  end
end
