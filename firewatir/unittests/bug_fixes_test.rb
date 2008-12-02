$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Bugs< Test::Unit::TestCase
  
  
    def setup
        goto_page("frame_buttons.html")
    end
  
    tag_method :test_frame_objects_bug3, :fails_on_ie
    def test_frame_objects_bug3
        frame = browser.frame("buttonFrame")
        button = frame.button(:name, "b1")
        assert_equal("buttonFrame", frame.name)
        assert_equal("b2", button.id)
        text1 = frame.text_field(:id, "text_id")
        text1.set("NewValue")
        assert("NewValue",frame.text_field(:id, "text_id").value)
    end
        
    def test_link_object_bug9
        goto_page("links1.html")
        link =  browser.link(:text, "nameDelet")
        assert_equal("test_link", link.name)
    end


    # element_by_xpath should return an element that's instance of the
    # appropriate class, not the generic Element class. So if it's a div,
    # it should return an instance of Div, if it's a checkbox, CheckBox,
    # and so on. TODO write tests for all classes
    tag_method :test_element_by_xpath_bug01, :fails_on_ie
    def test_element_by_xpath_bug01
      goto_page("div.html")
      element = browser.element_by_xpath("//div[@id='div1']")
      assert_not_nil(element) # helder
      # next assert always breaks, dunno why (error, not failure)
      #assert_instance_of(Div, element, "wrong constructor was used")
      # using this hack instead
      assert_class element, 'Div'
    end
    
    tag_method :test_elements_by_xpath_bug10, :fails_on_ie
    def test_elements_by_xpath_bug10
        goto_page("links1.html")
        elements = browser.elements_by_xpath("//a")
        assert_equal(11, elements.length)
        assert_equal("links2.html", elements[0].href)
        assert_equal("link_class_1", elements[1].className)
        assert_equal("link_id", elements[5].id)
        assert_equal("Link Using an ID", elements[5].text)
    end

    def test_button_by_value_bug8
        goto_page("buttons1.html")
        assert_equal("Sign In", browser.button(:value,"Sign In").value)
    end
       
    tag_method :test_html_bug7, :fails_on_ie
    def test_html_bug7
        goto_page("links1.html")
        html = browser.html
        assert_match(/.*<a id="linktos" *>*/,html)
    end

    def test_span_onclick_bug14
        goto_page("div.html")
        browser.span(:id, "span1").fireEvent("onclick")
        assert(browser.text.include?("PASS") )
    end

    tag_method :test_file_field_value_bug20, :fails_on_ie # hangs, actually
    def test_file_field_value_bug20
        actual_file_name = "c:\\Program Files\\TestFile.html"
        goto_page("fileupload.html")
        browser.file_field(:name, "file3").set(actual_file_name)
        set_file_name = browser.file_field(:name, "file3").value
        # make sure correct value for upload file is posted.
        assert(actual_file_name, set_file_name)
    end    

    tag_method :test_attribute_value_bug22, :fails_on_ie
    def test_attribute_value_bug22
        goto_page("div.html")
        assert("Test1", browser.element_by_xpath("//div[@id='div1']").attribute_value("title"))
    end
    
    def test_url_value_bug23
        goto_page("buttons1.html")
        browser.button(:id, "b2").click
        assert($htmlRoot + "pass.html", browser.url)
    end

    def test_contains_text_bug28
        goto_page("buttons1.html")
        browser.button(:id, "b2").click
        assert_false(browser.contains_text("passed"))
        assert(browser.contains_text("PASS"))
        assert(browser.contains_text("PAS"))
        assert(browser.contains_text(/PAS/))
        assert(browser.contains_text(/pass/i))
        assert_false(browser.contains_text(/pass/))
    end

    tag_method :test_frame_bug_21, :fails_on_ie
    def test_frame_bug_21
        goto_page("frame_buttons.html")
        frame1 = browser.frame(:name, "buttonFrame")
        frame2 = browser.frame(:name, "buttonFrame2")
        assert_equal("buttons1.html", frame1.src)
        assert_equal("blankpage.html", frame2.src)
    end
    
    def test_quotes_bug_11
        goto_page("textfields1.html")
        browser.text_field(:name, "text1").set("value with quote (\")")
        assert_equal("value with quote (\")", browser.text_field(:name, "text1").value)
        browser.text_field(:name, "text1").set("value with backslash (\\)")
        assert_equal("value with backslash (\\)", browser.text_field(:name, "text1").value)
    end

    tag_method :test_close_bug_26, :fails_on_ie
    def test_close_bug_26
        if ! (RUBY_PLATFORM =~ /darwin/i)
            browser.close()
            browser = FireWatir::Firefox.new
        end    
    end

    def test_class_bug_29
        goto_page("div.html")
        div = browser.div(:class, "blueText")
        assert_equal("div2", div.id)
    end

    def test_element_using_any_attribute
        goto_page("div.html")
        div = browser.div(:title, "Test1")
        assert_equal("div1", div.id)
    end
        
    tag_method :test_element_using_any_attribute2, :fails_on_ie
    def test_element_using_any_attribute2
        goto_page("div.html")
        div = browser.div(:attribute, "attribute")
        assert_equal("div1", div.id)
    end

    tag_method :test_file_field_bug_20, :fails_on_ie
    def test_file_field_bug_20
        goto_page("fileupload.html")
        # Enter dummy path.
        if(RUBY_PLATFORM =~ /.*mswin.*/)
            browser.file_field(:name, "file3").set("c:\\results.txt")
        else    
            browser.file_field(:name, "file3").set("/user/lib/results.txt")
        end    
        browser.button(:name, "upload").click()
        url = browser.url
        assert_match(/.*results.txt&upload=upload$/,url)
    end
    
    def test_button_bug2
        goto_page("buttons1.html")
        btn = browser.button(:id, "b7")
        assert_equal("b7", btn.id)
    end
    
    def test_getAllContents_bug25
        goto_page("select_tealeaf.html")
        browser.select_lists.each do |select|
            contents =  select.getAllContents().to_s
            puts contents
            assert_equal("=<>>=<=", contents)
            break
        end
    end

    tag_method :test_fire_event_bug31, :fails_on_ie
    def test_fire_event_bug31
        goto_page("div.html")
        div = browser.div(:attribute, "attribute")
        div.fire_event("ondblclick")
        assert("PASS", browser.text)
        goto_page("div.html")
        div = browser.div(:id, "div1")
        div.fireEvent("ondblclick")
        assert("PASS", browser.text)
    end

    def test_contains_text_bug37
        goto_page("frame_buttons.html")
        frame = browser.frame(:name, "buttonFrame")
        assert(frame.contains_text("second button"))
        assert_false(frame.contains_text("second button second"))
    end
end 
