module Clip
  macro add_commands(mapping)
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
          {{value.id}}.new(command[1...])
      {% end %}
      else
        raise Clip::UnknownCommand.new(command[0])
      end
    end

    def self.help(name = PROGRAM_NAME)
      {% help = "COMMAND [ARGS]...\n\nCommands:\n" %}

      {% for key, value in mapping %}
        {% if mapping.is_a?(NamedTupleLiteral) %}
          {% key = key.id.stringify %}
        {% end %}

        {% help += "  " + key + "\n" %}
      {% end %}

      "Usage: #{name} {{help.id}}"
    end
  end
end
