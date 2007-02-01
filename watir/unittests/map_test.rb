$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
  
class Map_Tests < Watir::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + 'map_test.html')
  end        

  def test_01
    assert_contains_text "Test Page for Map Tests"
  end
    
  def test_map_exists_by_name
    assert($ie.map(:name, 'maptest01').exists?)
    assert ! ($ie.map(:name, 'maptest03').exists?)
  end  
  
  def test_map_exists_by_id
    assert($ie.map(:id, 'maptestid01').exists?)
    assert ! ($ie.map(:id, 'maptestid03').exists?)
  end  

  def test_map_area_exists_by_href
    assert($ie.area(:url, /pass.html/).exists?)
    assert($ie.area(:url, /simple_table_buttons.html/).exists?)
    assert($ie.area(:url, /images1.html/).exists?)
    assert ! ($ie.area(:url, /blobs.html/).exists?)
    assert($ie.map(:name, 'maptest01').area(:url, /pass.html/).exists?)
    assert($ie.map(:id, 'maptestid01').area(:url, /images1.html/).exists?)
  end
  
  def test_map_area_exists_by_alt
    assert($ie.area(:alt, 'Pass').exists?)
    assert($ie.area(:alt, 'Table Buttons').exists?)
    assert($ie.area(:alt, 'Images').exists?)
    assert ! ($ie.area(:alt, 'Blobs').exists?)
    assert($ie.map(:name, 'maptest01').area(:alt, 'Pass').exists?)
    assert($ie.map(:id, 'maptestid01').area(:alt, 'Table Buttons').exists?)
  end

  def test_map_area_click
    $ie.area(:alt, 'Table Buttons').click
	assert_contains_text "This table has 3 images"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.area(:alt, 'Pass').click
	assert_contains_text "PASS"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.area(:alt, 'Images').click
	assert_contains_text "The triangle only has"
    $ie.back  
	assert_contains_text "Test Page for Map Tests"
    $ie.area(:url, /simple_table_buttons.html/).click
	assert_contains_text "This table has 3 images"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.area(:url, /pass.html/).click
	assert_contains_text "PASS"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.area(:url, /images1.html/).click
	assert_contains_text "The triangle only has"
    $ie.back  
	assert_contains_text "Test Page for Map Tests"
    $ie.map(:name, 'maptest01').area(:alt, 'Table Buttons').click
	assert_contains_text "This table has 3 images"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.map(:id, 'maptestid01').area(:alt, 'Pass').click
	assert_contains_text "PASS"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.map(:name, 'maptest01').area(:url, /pass.html/).click
	assert_contains_text "PASS"
    $ie.back
	assert_contains_text "Test Page for Map Tests"
    $ie.map(:id, 'maptestid01').area(:url, /images1.html/).click
	assert_contains_text "The triangle only has"
    $ie.back  
	assert_contains_text "Test Page for Map Tests"
  end
  
  def test_maps
    assert_equal(2, $ie.maps.length)
  end
  
  def test_areas
    assert_equal(3, $ie.map(:index, 2).areas.length)
  end
  
  def assert_contains_text text
    assert($ie.contains_text(text))
  end
  
end # class Map_Tests

