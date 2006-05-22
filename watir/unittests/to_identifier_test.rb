# feature tests for to_identifier which generates a string from an element
# which may be used to recreate that element in a different process.
# Used by click_no_wait to perform blocking clicks in another process.
# revision: $Revision: 992 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ToIdentifier< Test::Unit::TestCase
  include Watir

  # close any active modal dialog windows
  def teardown
    if $ie and $ie.enabled_popup(0)
      modal = $ie.modal_dialog
      modal.document.parentWindow.close if modal
    end
  end

  # Test that 
  def test_to_identifier_ie
    hwnd = $ie.hwnd     # get HWND from active IE COM object
    identifier = $ie.to_identifier
    assert_equal(String, identifier.class)
    assert_equal(identifier, "IE.attach(:hwnd, #{hwnd})")
  end
  
  def test_to_identifier_ie_modal_page
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
    hwnd = $ie.hwnd
    $ie.button(:value, 'Launch Dialog').click_no_wait
    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.attach_modal('Modal Dialog')
    modal_hwnd = modal.hwnd
    assert_not_equal(hwnd, modal_hwnd)    # modal should have different window handle
    identifier = modal.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).attach_modal('#{modal.document.title}", identifier)

    modal.button(:value, 'Close').click
  end

#    assert_equal(PopUp.method_name, 'popup')
#    assert($ie.respond_to?(PopUp.method_name))
#
#    assert_equal(Frame.method_name, 'frame')
#    assert($ie.respond_to?(Frame.method_name))
#
  def test_to_identifier_ie_modal_dialog_hwnd
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
    hwnd = $ie.hwnd
    $ie.button(:value, 'Launch Dialog').click_no_wait
    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.modal_dialog
    modal_hwnd = modal.hwnd
    assert_not_equal(hwnd, modal_hwnd)    # modal should have different window handle
    identifier = modal.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).modal_dialog(:hwnd, #{modal_hwnd})", identifier)

    modal.button(:value, 'Close').click
  end

  def test_to_identifier_ie_modal_dialog_title
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
    hwnd = $ie.hwnd
    $ie.button(:value, 'Launch Dialog').click_no_wait
    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.modal_dialog(:title, 'Modal Dialog')
    modal_hwnd = modal.hwnd
    assert_not_equal(hwnd, modal_hwnd)    # modal should have different window handle
    identifier = modal.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).modal_dialog(:title, \"#{modal.document.title}\")", identifier)

    modal.button(:value, 'Close').click
  end

#    assert_equal(Form.method_name, 'form')
#    assert($ie.respond_to?(Form.method_name))
###############################################
  def test_to_identifier_ie_form_name
    $ie.goto($htmlRoot + 'forms2.html')
    hwnd = $ie.hwnd
    form = $ie.form(:name, 'test2')
    identifier = form.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).form(:name, \"#{form.name}\")", identifier)
  end

  def test_to_identifier_ie_form_string
    $ie.goto($htmlRoot + 'forms2.html')
    hwnd = $ie.hwnd
    form = $ie.form('test2')
    identifier = form.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).form(:name, \"#{form.name}\")", identifier)
  end

  def test_to_identifier_ie_form_index
    $ie.goto($htmlRoot + 'forms2.html')
    hwnd = $ie.hwnd
    form = $ie.form(:index, 1)
    identifier = form.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).form(:index, 1)", identifier)
  end

  def test_to_identifier_ie_form_method
    $ie.goto($htmlRoot + 'forms2.html')
    hwnd = $ie.hwnd
    form = $ie.form(:method, 'get')
    identifier = form.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).form(:method, \"get\")", identifier)
  end

  def test_to_identifier_ie_form_action
    $ie.goto($htmlRoot + 'forms2.html')
    hwnd = $ie.hwnd
    form = $ie.form(:action, 'pass.html')
    identifier = form.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).form(:action, #{form.action.inspect})", identifier)
  end

  def test_to_identifier_ie_form_id
    $ie.goto($htmlRoot + 'forms2.html')
    hwnd = $ie.hwnd
    form = $ie.form(:id, 'form2')
    identifier = form.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).form(:id, #{form.id.inspect})", identifier)
  end

#    assert_equal(Table.method_name, 'table')
#    assert($ie.respond_to?(Table.method_name))

  def test_to_identifier_ie_table_id
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    table = $ie.table(:id, 't1')
    identifier = table.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:id, #{table.id.inspect})", identifier)
  end

  def test_to_identifier_ie_table_index
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    table = $ie.table(:index, 2)
    identifier = table.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:index, 2)", identifier)
  end

  def test_to_identifier_ie_table_name
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    table = $ie.table(:name, 't1name')
    identifier = table.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:name, #{table.name.inspect})", identifier)
  end

  def test_to_identifier_ie_table_class_name
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    table = $ie.table(:class_name, 't1class')
    identifier = table.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:class_name, #{table.class_name.inspect})", identifier)
  end

  def test_to_identifier_ie_table_text
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    table = $ie.table(:text, "Row 1 Col1 Row 1 Col2 \r\nRow 2 Col1 Row 2 Col2")
    identifier = table.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:text, #{table.text.inspect})", identifier)
  end

  def test_to_identifier_ie_table_text_regexp
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    table = $ie.table(:text, /Row/)
    identifier = table.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:text, /Row/)", identifier)
  end

#    assert_equal(TableBody.method_name, 'body')
#    assert($ie.table(:index, 1).respond_to?(TableBody.method_name))

  def test_to_identifier_ie_table_body_id
    $ie.goto($htmlRoot + 'table1.html')
    hwnd = $ie.hwnd
    body = $ie.table(:id, 'body_test').body(:id, 'tbody_id')
    identifier = body.to_identifier
    assert_equal(identifier.class, String)
    assert_equal("IE.attach(:hwnd, #{hwnd}).table(:id, 'body_test').body(:id, \"tbody_id\")", identifier)
  end

#    assert_equal(TableRow.method_name, 'row')
#    assert($ie.respond_to?(TableRow.method_name))

#    assert_equal(TableCell.method_name, 'cell')
#    assert($ie.respond_to?(TableCell.method_name))



#    assert_equal(Pre.method_name, 'pre')
#    assert($ie.respond_to?(Pre.method_name))
#
#    assert_equal(P.method_name, 'p')
#    assert($ie.respond_to?(P.method_name))
#
#    assert_equal(Div.method_name, 'div')
#    assert($ie.respond_to?(Div.method_name))
#
#    assert_equal(Span.method_name, 'span')
#    assert($ie.respond_to?(Span.method_name))
#
#    assert_equal(Label.method_name, 'label')
#    assert($ie.respond_to?(Label.method_name))
#
#    assert_equal(TableBodies.method_name, 'bodies')
#    assert($ie.table(:index, 1).respond_to?(TableBodies.method_name))
#
#    assert_equal(Image.method_name, 'image')
#    assert($ie.respond_to?(Image.method_name))
#
#    assert_equal(Link.method_name, 'link')
#    assert($ie.respond_to?(Link.method_name))
#
#    # Method name converts for this class, but there is no corresponding
#    # method name accessible by the user.
#    assert_equal(InputElement.method_name, 'input_element')
##    assert($ie.respond_to?(InputElement.method_name))
#
#    assert_equal(SelectList.method_name, 'select_list')
#    assert($ie.respond_to?(SelectList.method_name))
#
#    assert_equal(Button.method_name, 'button')
#    assert($ie.respond_to?(Button.method_name))
#
#    assert_equal(TextField.method_name, 'text_field')
#    assert($ie.respond_to?(TextField.method_name))
#
#    assert_equal(Hidden.method_name, 'hidden')
#    assert($ie.respond_to?(Hidden.method_name))
#
#    assert_equal(FileField.method_name, 'file_field')
#    assert($ie.respond_to?(FileField.method_name))
#
#    # Method name converts for this class, but there is no corresponding
#    # method name accessible by the user.
#    assert_equal(RadioCheckCommon.method_name, 'radio_check_common')
##    assert($ie.respond_to?(RadioCheckCommon.method_name))
#
#    assert_equal(Radio.method_name, 'radio')
#    assert($ie.respond_to?(Radio.method_name))
#
#    assert_equal(CheckBox.method_name, 'checkbox')
#    assert($ie.respond_to?(CheckBox.method_name))
#
#    # The following classes are collections of elements and as
#    # such have no direct method.  The equivilent method for
#    # the collected item will be used for any item in the
#    # collection.
#    # ie.links[1].to_identifier -> "IE.attach(:hwnd, 4392042).link(:index, 1)"
#
##    assert_equal(Buttons.method_name, 'buttons')
##    assert_equal(FileFields.method_name, 'file_fields')
##    assert_equal(CheckBoxes.method_name, 'checkboxes')
##    assert_equal(Radios.method_name, 'radios')
##    assert_equal(SelectLists.method_name, 'select_lists')
##    assert_equal(Links.method_name, 'links')
##    assert_equal(Images.method_name, 'images')
##    assert_equal(TextFields.method_name, 'text_fields')
##    assert_equal(Hiddens.method_name, 'hiddens')
##    assert_equal(Tables.method_name, 'tables')
##    assert_equal(TableRows.method_name, 'rows')
##    assert_equal(TableCells.method_name, 'cells')
##    assert_equal(Labels.method_name, 'labels')
##    assert_equal(Pres.method_name, 'pres')
##    assert_equal(Ps.method_name, 'p')
##    assert_equal(Spans.method_name, 'spans')
##    assert_equal(Divs.method_name, 'divs')
#  end
end
