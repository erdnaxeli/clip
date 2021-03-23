module Clip::Mapper
  def initialize(command : Array(String))
    {% begin %}
      command = command.flat_map do |param|
        if param.starts_with?("--")
          param.split('=')
        else
          param
        end
      end

      arguments_errors = Hash(String, Clip::Errors).new
      options_errors = Hash(String, Clip::Errors).new

      # We first handle options.
      {% for ivar in @type.instance_vars %}
        {% if ivar.has_default_value? || ivar.annotation(Option) || ivar.type == Bool %}
          {% if ivar.type == Bool %}
            idx = command.index("--{{ivar.id}}")
            no_idx = command.index("--no-{{ivar.id}}")
            if !idx.nil?
              value = command.delete_at(idx, 1)[0]
              @{{ivar.id}} = true
            elsif !no_idx.nil?
              value = command.delete_at(no_idx, 1)[0]
              @{{ivar.id}} = false
            {% if !ivar.has_default_value? %}
              else
                options_errors[{{ivar.stringify}}] = Clip::Errors::Required
                @{{ivar.id}} = true
            {% end %}
            end
          {% elsif ivar.type == String || ivar.type < Number %}
            idx = command.index("--{{ivar.id}}")
            if !idx.nil?
              value = command.delete_at(idx, 2)[1]
              {% if ivar.type == String %}
                @{{ivar.id}} = value
              {% else %}
                @{{ivar.id}} = {{ivar.type.id}}.new(value)
              {% end %}
            {% if !ivar.has_default_value? %}
              else
                options_errors[{{ivar.stringify}}] = Clip::Errors::Required
                {% if ivar.type == String %}
                  @{{ivar.id}} = ""
                {% else %}
                  @{{ivar.id}} = 0
                {% end %}
            {% end %}
            end
          {% else %}
            {% raise "Unhandled type #{ivar.type.stringify}." %}
          {% end %}
        {% end %}
      {% end %}

      # Then all that is left on `command` should be arguments.
      {% for ivar in @type.instance_vars %}
        {% if ivar.type != Bool && (
          (!ivar.has_default_value? && !ivar.annotation(Option)) ||
          ivar.annotation(Argument)
        ) %}
          if value = command.shift?
            {% if ivar.type == String %}
              @{{ivar.id}} = value
            {% elsif ivar.type < Number %}
              @{{ivar.id}} = {{ivar.type.id}}.new(value)
            {% else %}
              {% raise "Unhandled type #{ivar.type.stringify}." %}
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
