# These are provided for backwards compatability with Watir 1.1

module Watir
    module Container
        alias waitForIE wait
        alias fileField file_field
        alias textField text_field
        alias selectBox select_list
        alias checkBox checkbox
    end
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
    class Element
        alias getOLEObject ole_object 
        alias fireEvent fire_event        
        alias innerText text
        alias afterText after_text
        alias beforeText before_text
    end    
    class Frame        
        alias getDocument document
        alias waitForIE wait
    end
    class Form        
        alias waitForIE wait 
    end


    class Image
      alias fileCreatedDate file_created_date
      alias fileSize file_size
      alias hasLoaded? loaded?
    end
    
    class RadioCheckCommon
      alias getState set?
      alias isSet?   set?
    end
    
    class TextField
        alias readOnly? :readonly?
        alias getContents value
        alias maxLength maxlength
        alias dragContentsTo drag_contents_to
    end 
    
    class SelectList
        alias getAllContents options
        alias getSelectedItems selected_options
        alias clearSelection clear
        alias includes? include?
    end   
end