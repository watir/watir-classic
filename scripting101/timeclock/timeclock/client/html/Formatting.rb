# XHTML formatting support
# All of these have been factored out of running code, so they're tested
# indirectly.

module Timeclock
  module Client
    module Html
      module Formatting
        Prolog = %Q{.<!DOCTYPE html PUBLIC
                    .           "-//W3C//DTD XHTML 1.0 Transitional//EN"
                    .           "DTD/xhtml1-transitional.dtd"	>
                   }.after_dots

        # tags
        def self.def_tag(name, type)
          class_eval "def #{name}(*args)
                        #{type}('#{name}', *args)
                      end"
        end

        def_tag :html, :expansive
        def_tag :head, :expansive
        def_tag :body, :expansive
        def_tag :p, :expansive
        def_tag :form, :expansive
        def_tag :input, :tight
        def_tag :table, :expansive
        def_tag :tr, :expansive
        def_tag :td, :expansive
        def_tag :h1, :tight
        def_tag :b, :tight
        def_tag :div, :expansive
        def_tag :title, :tight
        def_tag :pre, :expansive

        
        # Utilities used in constructing nested tag structures. 
        HeaderBlueFill = "#66ffff"
        BodyBlueFill = "#ccffff"
        
        TextResultGreen = {:style => "color: #009900;"}
        TextResultRed = {:style => "color: #cc0000;"}

        def center(color=nil)
          hash = {:align => 'center'}
          if color
            hash[:bgcolor] = color
          end
          hash
        end

        def colored_row(color, *args)
          tr(td(center(color), *args))
        end
                       

        def head_row(*args)
          colored_row(HeaderBlueFill, *args)
        end

        def body_row(*args)
          colored_row(BodyBlueFill, *args)
        end

        def session_id
          flunk "Including class must define session_id"
        end

        def command_form(command, *args)
          form({:method => 'get',
                 :action => command,
                 :id => command,
                 :name => command},
               hidden('session', "#{session_id}"),
               *args)
        end

        def submit(name, button_text)
          input({:type => 'submit',
                  :name => name,
                  :value => button_text})
        end

        def hidden(name, value)
          input({:type => 'hidden',
                  :name => name,
                  :value => value})
        end

        def tight_table(*args)
          table({:cellpadding=>"3", :border=>"0", :cellspacing=>"0"},
                *args)
        end

        def vertical(*args)
          table(*args.collect { | arg |
                  tr(td(center, arg))
                })
        end

        def green_p(*args)
          p(TextResultGreen, *args)
        end

        def red_p(*args)
          p(TextResultRed, *args)
        end
          



        # Low level utilities.

        def rshift(string)
          "  " + string.split("\n").join("\n  ")
        end

        # Split optional hash of attributes away from trailing texts.
        def attributes_and_contents(args)
          all_attributes = {}
          contents = []
          args.each { | arg |
            if arg.is_a? Hash
              all_attributes.merge!(arg)
            else
              contents << arg
            end
          }

          if all_attributes.empty?
            return [], contents
          else
            pairs = all_attributes.to_a
            # sorting makes tests deterministic. It would be terser
            # to sort the constructed string, but that would confusingly
            # put "arg2=foo" before "arg=foo".
            pairs.sort! { | one, two | one[0].to_s<=>two[0].to_s }
            return pairs.collect { | pair | " #{pair[0]}=\"#{pair[1]}\""},
                   contents
          end
        end

        def wrap(tag, attribute_text, content_text)
          "<#{tag}#{attribute_text}>#{content_text}</#{tag}>"
        end

        def tight(tag, *args)
          attrs, contents = attributes_and_contents(args)
          wrap(tag, attrs.join, contents.join)
        end

        def expansive(tag, *args)
          attrs, contents = attributes_and_contents(args)
          wrap(tag, attrs.join, 
               $/ + contents.collect { | text | rshift(text) +$/ }.join)
        end
        
      end
    end
  end
end

        
        
