$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_MultipleSpecifiers < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "multiple_specifiers.html"
  end

  %w[form table cell row button file_field text_field
     hidden select_list checkbox radio link image element div].each do |element|
    class_eval %Q{
      def test_#{element} 
        assert "one", browser.#{element}(:name => "test#{element}", :class => "one").class_name
        assert "two", browser.#{element}(:name => "test#{element}", :class => "two").class_name
        assert_raises(UnknownObjectException) {browser.#{element}(:name => "nonexistent", :class => "one").class_name}      
      end
    }
  end

  def test_frame
    goto_page "frame_buttons.html"
    assert "buttons1.html", browser.frame(:name => /buttonFrame/, :src => "buttons1.html").src
    assert "blankpage.html", browser.frame(:name => /buttonFrame/, :src => "blankpage.html").src
    assert_raises(UnknownFrameException) {browser.frame(:name => "nonexistent", :src => "buttons1.html").src}
  end

end
