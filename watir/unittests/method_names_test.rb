# feature tests for determining a method name from class name
# revision: $Revision: 992 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_MethodNames< Test::Unit::TestCase
  include Watir

  # Make sure that method_name returns correct method name corresponding
  # to each of the Watir element classes.  Most will use the default
  # underscore name, but some are overridden for historical or cosmetic
  # reasons.
  
  # For each method_name, make sure that the derived method name is
  # supported.  For most, this means that the Watir::IE element responds
  # to that method_name, though a couple of methods are only appropriate
  # within a table context.
  def test_method_name_ie
    assert_equal(IE.method_name, 'ie')
    assert($ie.respond_to?(IE.method_name))
  end

  def test_method_name_attach_modal
    assert_equal(ModalPage.method_name, 'attach_modal')
    assert($ie.respond_to?(ModalPage.method_name))
  end

  def test_method_name_popup
    assert_equal(PopUp.method_name, 'popup')
    assert($ie.respond_to?(PopUp.method_name))
  end

    # Method name converts for this class, but there is no corresponding
    # method name accessible by the user.
  def test_method_name_element
    assert_equal(Element.method_name, 'element')
    #    assert($ie.respond_to?(Element.method_name))
  end

    # Method name converts for this class, but there is no corresponding
    # method name accessible by the user.
  def test_method_name_element_mapper
    assert_equal(ElementMapper.method_name, 'element_mapper')
    #    assert($ie.respond_to?(ElementMapper.method_name))
  end

  def test_method_name_frame
    assert_equal(Frame.method_name, 'frame')
    assert($ie.respond_to?(Frame.method_name))
  end

  def test_method_name_modal_dialog
    assert_equal(ModalDialog.method_name, 'modal_dialog')
    assert($ie.respond_to?(ModalDialog.method_name))
  end

  def test_method_name_form
    assert_equal(Form.method_name, 'form')
    assert($ie.respond_to?(Form.method_name))
  end

    # Method name converts for this class, but there is no corresponding
    # method name accessible by the user.
  def test_method_name_non_control_element
    assert_equal(NonControlElement.method_name, 'non_control_element')
    #    assert($ie.respond_to?(NonControlElement.method_name))
  end

  def test_method_name_pre
    assert_equal(Pre.method_name, 'pre')
    assert($ie.respond_to?(Pre.method_name))
  end

  def test_method_name_p
    assert_equal(P.method_name, 'p')
    assert($ie.respond_to?(P.method_name))
  end

  def test_method_name_div
    assert_equal(Div.method_name, 'div')
    assert($ie.respond_to?(Div.method_name))
  end

  def test_method_name_span
    assert_equal(Span.method_name, 'span')
    assert($ie.respond_to?(Span.method_name))
  end

  def test_method_name_label
    assert_equal(Label.method_name, 'label')
    assert($ie.respond_to?(Label.method_name))
  end

  def test_method_name_table
    assert_equal(Table.method_name, 'table')
    assert($ie.respond_to?(Table.method_name))
  end

  def test_method_name_bodies
    assert_equal(TableBodies.method_name, 'bodies')
    assert($ie.table(:index, 1).respond_to?(TableBodies.method_name))
  end

  def test_method_name_body
    assert_equal(TableBody.method_name, 'body')
    assert($ie.table(:index, 1).respond_to?(TableBody.method_name))
  end

  def test_method_name_row
    assert_equal(TableRow.method_name, 'row')
    assert($ie.respond_to?(TableRow.method_name))
  end

  def test_method_name_cell
    assert_equal(TableCell.method_name, 'cell')
    assert($ie.respond_to?(TableCell.method_name))
  end

  def test_method_name_image
    assert_equal(Image.method_name, 'image')
    assert($ie.respond_to?(Image.method_name))
  end

  def test_method_name_link
    assert_equal(Link.method_name, 'link')
    assert($ie.respond_to?(Link.method_name))
  end

    # Method name converts for this class, but there is no corresponding
    # method name accessible by the user.
  def test_method_name_input_element
    assert_equal(InputElement.method_name, 'input_element')
    #    assert($ie.respond_to?(InputElement.method_name))
  end

  def test_method_name_select_list
    assert_equal(SelectList.method_name, 'select_list')
    assert($ie.respond_to?(SelectList.method_name))
  end

  def test_method_name_button
    assert_equal(Button.method_name, 'button')
    assert($ie.respond_to?(Button.method_name))
  end

  def test_method_name_text_field
    assert_equal(TextField.method_name, 'text_field')
    assert($ie.respond_to?(TextField.method_name))
  end

  def test_method_name_hidden
    assert_equal(Hidden.method_name, 'hidden')
    assert($ie.respond_to?(Hidden.method_name))
  end

  def test_method_name_file_field
    assert_equal(FileField.method_name, 'file_field')
    assert($ie.respond_to?(FileField.method_name))
  end

    # Method name converts for this class, but there is no corresponding
    # method name accessible by the user.
  def test_method_name_radio_check_common
    assert_equal(RadioCheckCommon.method_name, 'radio_check_common')
    #    assert($ie.respond_to?(RadioCheckCommon.method_name))
  end

  def test_method_name_radio
    assert_equal(Radio.method_name, 'radio')
    assert($ie.respond_to?(Radio.method_name))
  end

  def test_method_name_checkbox
    assert_equal(CheckBox.method_name, 'checkbox')
    assert($ie.respond_to?(CheckBox.method_name))
  end

    # The following classes are collections of elements and as
    # such have no direct method.  The equivilent method for
    # the collected item will be used for any item in the
    # collection.
    # ie.links[1].to_identifier -> "IE.attach(:hwnd, 4392042).link(:index, 1)"

#    assert_equal(Buttons.method_name, 'buttons')
#    assert_equal(FileFields.method_name, 'file_fields')
#    assert_equal(CheckBoxes.method_name, 'checkboxes')
#    assert_equal(Radios.method_name, 'radios')
#    assert_equal(SelectLists.method_name, 'select_lists')
#    assert_equal(Links.method_name, 'links')
#    assert_equal(Images.method_name, 'images')
#    assert_equal(TextFields.method_name, 'text_fields')
#    assert_equal(Hiddens.method_name, 'hiddens')
#    assert_equal(Tables.method_name, 'tables')
#    assert_equal(TableRows.method_name, 'rows')
#    assert_equal(TableCells.method_name, 'cells')
#    assert_equal(Labels.method_name, 'labels')
#    assert_equal(Pres.method_name, 'pres')
#    assert_equal(Ps.method_name, 'p')
#    assert_equal(Spans.method_name, 'spans')
#    assert_equal(Divs.method_name, 'divs')
end
