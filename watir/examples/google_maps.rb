#-------------------------------------------------------------------------------------------------------------#
# access_to_invisible_contents_in_frames.rb
#
# Purpose: * to demonstrate that WATIR can "see" into frames where "View Source" doesn't work
#          * to demonstrate an assertion based on HTML tag content
# 
#------------------------------------------------------------------------------------------------------------#



#includes
require 'watir'   # the controller
include Watir

#test::unit includes
require 'test/unit'


class TC_google_maps < Test::Unit::TestCase


    def test_google_maps
  
        #variables
        testSite = "http://maps.google.com"

        #open the IE browser
        ie = IE.new

        puts "going to maps.google.com"
        ie.goto(testSite)

        puts "getting map for Durango"
        ie.text_field(:id,"q").set("Durango,CO")
        ie.button(:index, 1).click

        puts "showing the HTML inside the frame, where View Source does not work:"
        puts " "
        puts ie.frame("vp").getHTML
   
        puts "storing frames HTML into variable for lat/long test assertion"
        matchlat = '37.275278'
        matchlong = '-107.879444'

        begin
            assert_match(matchlat,ie.frame("vp").html.to_s)
            puts("PASS latitude OK\n")
        rescue => e
            puts("FAIL Didn't find latitude")
        end
 
        begin
            assert_match(matchlong,ie.frame("vp").html.to_s)
            puts("PASS longitude OK\n")
        rescue => e
            puts("FAIL Didn't find longitude")
        end

    end

end