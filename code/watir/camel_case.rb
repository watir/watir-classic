# These are provided for backwards compatability with Watir 1.1

module Container
        alias waitForIE wait
        alias fileField file_field
        alias textField text_field
        alias selectBox select_list
        alias checkBox checkbox
end


module Watir
    
    class IE
        alias getStatus status
        alias getDocument document
        alias pageContainsText contains_text
        alias waitForIE wait
        alias getHTML html
        alias getText text
        alias showFrames show_frames
        alias showForms show_forms
        alias showImages show_images
        alias showLinks show_links
        alias showActive show_active
        alias showAllObjects show_all_objects
        def   getIE; @ie; end
        
    end
    
end