class Borges::ListPreference < Borges::Preference

  attr_accessor :options

  def initialize(value, options)
    super(value)
    @options = options
  end

  def render_on(r)
    r.select(@options, @value) do |v|
      @value = v
    end
  end

end

