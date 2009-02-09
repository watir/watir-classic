$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class Map_Tests < Watir::TestCase
  
  def setup
    goto_page 'map_test.html'
  end        
  
  def test_01
    assert_contains_text "Test Page for Map Tests"
  end
  
  def test_map_exists_by_name
    assert(browser.map(:name, 'maptest01').exists?)
    assert ! (browser.map(:name, 'maptest03').exists?)
  end  
  
  def test_map_exists_by_id
    assert(browser.map(:id, 'maptestid01').exists?)
    assert ! (browser.map(:id, 'maptestid03').exists?)
  end  
  
  def test_map_area_exists_by_href
    assert(browser.area(:url, /pass.html/).exists?)
    assert(browser.area(:url, /simple_table_buttons.html/).exists?)
    assert(browser.area(:url, /images1.html/).exists?)
    assert ! (browser.area(:url, /blobs.html/).exists?)
    assert(browser.map(:name, 'maptest01').area(:url, /pass.html/).exists?)
    assert(browser.map(:id, 'maptestid01').area(:url, /images1.html/).exists?)
  end
  
  def test_map_area_exists_by_alt
    assert(browser.area(:alt, 'Pass').exists?)
    assert(browser.area(:alt, 'Table Buttons').exists?)
    assert(browser.area(:alt, 'Images').exists?)
    assert ! (browser.area(:alt, 'Blobs').exists?)
    assert(browser.map(:name, 'maptest01').area(:alt, 'Pass').exists?)
    assert(browser.map(:id, 'maptestid01').area(:alt, 'Table Buttons').exists?)
  end
  
  def test_map_area_click
    browser.area(:alt, 'Table Buttons').click
    assert_contains_text "This table has 3 images"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.area(:alt, 'Pass').click
    assert_contains_text "PASS"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.area(:alt, 'Images').click
    assert_contains_text "The triangle only has"
    browser.back  
    assert_contains_text "Test Page for Map Tests"
    browser.area(:url, /simple_table_buttons.html/).click
    assert_contains_text "This table has 3 images"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.area(:url, /pass.html/).click
    assert_contains_text "PASS"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.area(:url, /images1.html/).click
    assert_contains_text "The triangle only has"
    browser.back  
    assert_contains_text "Test Page for Map Tests"
    browser.map(:name, 'maptest01').area(:alt, 'Table Buttons').click
    assert_contains_text "This table has 3 images"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.map(:id, 'maptestid01').area(:alt, 'Pass').click
    assert_contains_text "PASS"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.map(:name, 'maptest01').area(:url, /pass.html/).click
    assert_contains_text "PASS"
    browser.back
    assert_contains_text "Test Page for Map Tests"
    browser.map(:id, 'maptestid01').area(:url, /images1.html/).click
    assert_contains_text "The triangle only has"
    browser.back  
    assert_contains_text "Test Page for Map Tests"
  end
  
  def test_maps
    assert_equal(2, browser.maps.length)
  end
  
  def test_areas
    assert_equal(3, browser.map(:index, 2).areas.length)
  end
  
  def assert_contains_text text
    assert(browser.contains_text(text))
  end
  
end # class Map_Tests

