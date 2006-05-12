# test program for IEController.rb

require 'IEController'




ie = IEController.new()


myDir = __FILE__[0 .. __FILE__.rindex('\\' ) ]
ie.goto(myDir + 'ieTest.html')

# set the radio button
a,messages = ie.setRadioButton('radioblah' , '1')

a,messages = ie.setRadioButton('radio1' , '1')
if !a then

    puts 'Problem with radio button radio1'
    puts messages.join ("\n")
end

sleep 1
a,messages = ie.setRadioButton('radio1' , '2')
if !a then

    puts 'Problem with radio button radio1'
    puts messages.join ("\n")
end

sleep 1
a,messages = ie.setRadioButton('radio1' , '3')
if !a then

    puts 'Problem with radio button radio1'
    puts messages.join ("\n")
end


sleep 1
a, message = ie.clickButton( "radioSubmit" )
if !a then

    puts 'Problem with button radioSubmit'
    puts messages.join ("\n")
end

sleep 1

a, messges = ie.setField("text1" , "Hello world" )
if !a
    puts 'Problem with text box text1' 
    puts messages.join ("\n")
end


sleep 1
ie.quit()