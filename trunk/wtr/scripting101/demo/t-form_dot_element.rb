# Tests form-dot-element-name reference
# Use Timeclock server on localhost as testbed.  Assumes Timeclock is 
# already running.

require 'English'
require '../toolkit'
require 'dakutils'
require 'test/unit'
require 'test/unit/assertionfailederror'

 
class Test_form_dot_element  < Test::Unit::TestCase
  def setup()
    start_log()
    $log.debug('Test_form_dot_element setup()')
    
    start_ie("http://localhost:8080")
    $iec.wait
  end


  def check_page_elements()
    $log.debug("check_page_elements() for page titled '#{$iec.ie.Document.Title}'")
    $iec.wait
    page_forms = forms()
    $log.debug("call check_form_elements() for #{page_forms.length} forms")
    page_forms.each {|form| check_form_elements(form)}
  end


  def check_form_elements(form)
    $log.debug("check_form_elements() for form with action '#{form.action}'")
    form_elements = get_elements(form)
    $log.debug("call check_form_dot_element() for #{form_elements.length} elements")
    form_elements.each {|element| check_form_dot_element(form, element)}
  end


  def check_form_dot_element(form, element)
    name = element.name
    value = element.value
    $log.debug("check_form_dot_element() for element '#{name}'"\
      " in form with action '#{form.action}'")
    
    begin
      assert_equal(value, form.__send__(name),\
        "form.#{name} didn't return element.value '#{value}'")
    rescue => exception
      if exception.kind_of?(Test::Unit::AssertionFailedError) then raise
      else
        msg ="form.#{name} threw exception: #{$ERROR_INFO}"
        $log.debug msg
        flunk msg
      end
    end
  end
  
    
  def test_login_page_form_elements()
    $log.debug('test_login_page_form_elements()')
    check_page_elements()
  end
  
  
  def test_first_job_page_form_elements()
    $log.debug('test_first_job_page_form_elements()')
    
    login_with_new_user('new_user')
    
    check_page_elements()
  end
  
  
  def test_new_user_start_page_form_elements()
    $log.debug('test_new_user_start_page_form_elements()')
    
    login_with_new_user('new_user')
    create_first_job('first job')
    
    check_page_elements()
  end
  
  
  def teardown
    $log.debug('teardown()')
    2.times {$iec.wait(); sleep(0.2)}
    $iec.close
    #$iec.wait causes WIN32OLERuntimeError: Unknown property or method : `busy'
      #HRESULT error code:0x80010108
      #The object invoked has disconnected from its clients"
  end
end
