class HtmlTest < Borges::Component

  def tests
    x = self.class.instance_methods(false).sort.select do |m|
      m =~ /^render/
    end
    x.delete('render_content_on')
    return x
  end

  def initialize
    @message = 'Hello world!!'

    @boolean_list = {}
    [:a, :b, :c, :d].map do |k|
      @boolean_list[k] = rand > 0.5
    end

    @number = rand(10)
  end

  def render_content_on(r)
    t = tests
    0.upto((t.length / 2) - 1) do |i|
      r.div_with_class('row') do
        r.div_with_class('left') do send(t[i * 2], r) end
        r.div_with_class('left') do send(t[i * 2 + 1], r) end
      end
    end
  end

  def render_checkboxes_on(r)
    r.text(@boolean_list.sort_by { |a| a[0].to_s }.join(' '))
    r.paragraph
    r.form do
      @boolean_list.sort_by { |a| a[0].to_s }.each do |key, value|
        r.text(key)
        r.space

        r.checkbox(value) do |b|
          @boolean_list[key] = b
        end

        r.break
      end
      r.submit_button do end
    end
  end

  def render_radio_buttons_on(r)
    r.text(@boolean_list.sort_by { |a| a[0].to_s }.join(' '))
    r.paragraph
    r.form do
      @boolean_list.sort_by { |a| a[0].to_s }.each do |key, value|
        group = r.radio_group
        r.text(key)
        r.space

        r.radio_button(group, value) do
          @boolean_list[key] = true
        end

        r.radio_button(group, (not value)) do
          @boolean_list[key] = false
        end

        r.break
      end
      r.submit_button do end
    end
  end

  def render_selects_on(r)
    r.text(@number)
    r.paragraph
    r.form do
      r.select((1..10).to_a, @number) do |i| @number = i end
      r.submit_button do end
    end
  end

  def render_submit_buttons_on(r)
    r.text(@number)
    r.paragraph
    r.form do
      1.upto(10) do |i|
        r.submit_button(i) do @number = i end
        r.space
      end
    end
  end

  def render_text_area_on(r)
    r.form do
      r.text(@message)
      r.paragraph
      r.text_area(@message) do |v| @message = v end
      r.break
      r.submit_button do end
    end
  end

  def render_text_input_on(r)
    r.form do
      r.text(@message)
      r.paragraph
      r.text_input(@message) do |v| @message = v end
      r.submit_button do end
    end
  end

=begin
  def render_z(r)
    r.space
  end
=end

  def style
    return "
    .row {clear: both}
    .left {float: left; width: 45%; margin: 1%}
    "
  end

end

