class TestTabs < Borges::Component

  def initialize
    @tabs = Borges::TabPanel.new({
      'Input' => InputTest.new,
      'Once' => OnceTest.new,
      'Html' => HtmlTest.new,
      'Encoding' => EncodingTest.new,
      'Calendar' => CalendarTest.new,
      'Error' => ErrorTest.new,
      'Exception' => ExceptionTest.new,
      'Closure' => ClosureTest.new,
      'Transaction' => TransactionTest.new,
      'Upload' => UploadTest.new,
      'Parent' => ParentTest.new(self),
    })

  end

  def render_content_on(r)
    r.heading('Test Components')
    r.render(@tabs)
  end

  register_application('test')

end

