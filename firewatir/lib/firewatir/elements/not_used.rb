# # this class is a collection of the table body objects that exist in the table
# # it wouldnt normally be created by a user, but gets returned by the bodies method of the Table object
# # many of the methods available to this object are inherited from the Element class
# # TODO: Implement TableBodies class.
# class TableBodies < Element
# 
#   # Description:
#   #   Initializes the form element.
#   #
#   # Input:
#   #   - how - Attribute to identify the form element.
#   #   - what - Value of that attribute.
#   #
#   def initialize( parent_table)
#     element = container
#     @o = parent_table     # in this case, @o is the parent table
#   end
# 
#   # returns the number of TableBodies that exist in the table
#   def length
#     assert_exists
#     return @o.tBodies.length
#   end
# 
#   # returns the n'th Body as a FireWatir TableBody object
#   def []n
#     assert_exists
#     return TableBody.new(element, :direct, ole_table_body_at_index(n))
#   end
# 
#   # returns an ole table body
#   def ole_table_body_at_index(n)
#     return @o.tBodies[(n-1).to_s]
#   end
# 
#   # iterates through each of the TableBodies in the Table. Yields a TableBody object
#   def each
#     1.upto( @o.tBodies.length ) { |i| yield TableBody.new(element, :direct, ole_table_body_at_index(i)) }
#   end
# 
# end # TableBodies
# 
# # this class is a table body
# # TODO: Implement TableBody class
# class TableBody < Element
#   def locate
#     @o = nil
#     if @how == :direct
#       @o = @what     # in this case, @o is the table body
#     elsif @how == :index
#       @o = @parent_table.bodies.ole_table_body_at_index(@what)
#     end
#     @rows = []
#     if @o
#       @o.rows.each do |oo|
#         @rows << TableRow.new(element, :direct, oo)
#       end
#     end
#   end
# 
# 
#   # Description:
#   #   Initializes the form element.
#   #
#   # Input:
#   #   - how - Attribute to identify the form element.
#   #   - what - Value of that attribute.
#   #
#   def initialize( how, what, parent_table = nil)
#     element = container
#     @how = how
#     @what = what
#     @parent_table = parent_table
#     super nil
#   end
# 
#   # returns the specified row as a TableRow object
#   def [](n)
#     assert_exists
#     return @rows[n - 1]
#   end
# 
#   # iterates through all the rows in the table body
#   def each
#     locate
#     0.upto(@rows.length - 1) { |i| yield @rows[i] }
#   end
# 
#   # returns the number of rows in this table body.
#   def length
#     return @rows.length
#   end
# end # TableBody

# # this class is the super class for the iterator classes ( buttons, links, spans etc
# # it would normally only be accessed by the iterator methods ( spans , links etc) of IE
# class ElementCollections
#   include Enumerable
#   include Container
# 
#   # Super class for all the iteractor classes
#   #   * container  - an instance of an IE object
#   def initialize( container)
#     element = container
#     @length = length() # defined by subclasses
# 
#     # set up the items we want to display when the show method s used
#     set_show_items
#   end
# 
#   private
#   def set_show_items
#     @show_attributes = AttributeLengthPairs.new( "id" , 20)
#     @show_attributes.add( "name" , 20)
#   end
# 
#   public
#   def get_length_of_input_objects(object_type)
#     object_types =
#     if object_type.kind_of? Array
#       object_type
#     else
#       [ object_type ]
#     end
# 
#     length = 0
#     objects = element.document.getElementsByTagName("INPUT")
#     if  objects.length > 0
#       objects.each do |o|
#         length += 1 if object_types.include?(o.invoke("type").downcase )
#       end
#     end
#     return length
#   end
# 
#   # iterate through each of the elements in the collection in turn
#   def each
#     0.upto( @length-1 ) { |i | yield iterator_object(i) }
#   end
# 
#   # allows access to a specific item in the collection
#   def [](n)
#     return iterator_object(n-1)
#   end
# 
#   # this method is the way to show the objects, normally used from irb
#   def show
#     s="index".ljust(6)
#     @show_attributes.each do |attribute_length_pair|
#       s=s + attribute_length_pair.attribute.ljust(attribute_length_pair.length)
#     end
# 
#     index = 1
#     self.each do |o|
#       s= s+"\n"
#       s=s + index.to_s.ljust(6)
#       @show_attributes.each do |attribute_length_pair|
#         begin
#           s=s  + eval( 'o.getOLEObject.invoke("#{attribute_length_pair.attribute}")').to_s.ljust( attribute_length_pair.length  )
#         rescue=>e
#           s=s+ " ".ljust( attribute_length_pair.length )
#         end
#       end
#       index+=1
#     end
#     puts s
#   end
# 
#   # this method creates an object of the correct type that the iterators use
#   private
#   def iterator_object(i)
#     element_class.new(element, :index, i+1)
#   end
# end
# 
# # --
# #   These classes are not for public consumption, so we switch off rdoc
# #
# # presumes element_class or element_tag is defined
# # for subclasses of ElementCollections
# module CommonCollection
#   def element_tag
#     element_class.tag
#   end
#   def length
#     element.document.getElementsByTagName(element_tag).length
#   end
# end
# 
# # This class is used as part of the .show method of the iterators class
# # it would not normally be used by a user
# class AttributeLengthPairs
# 
#   # This class is used as part of the .show method of the iterators class
#   # it would not normally be used by a user
#   class AttributeLengthHolder
#     attr_accessor :attribute
#     attr_accessor :length
# 
#     def initialize( attrib, length)
#       @attribute = attrib
#       @length = length
#     end
#   end
# 
#   def initialize( attrib=nil , length=nil)
#     @attr=[]
#     add( attrib , length ) if attrib
#     @index_counter=0
#   end
# 
#   # BUG: Untested. (Null implementation passes all tests.)
#   def add( attrib , length)
#     @attr <<  AttributeLengthHolder.new( attrib , length )
#   end
# 
#   def delete(attrib)
#     item_to_delete=nil
#     @attr.each_with_index do |e,i|
#       item_to_delete = i if e.attribute==attrib
#     end
#     @attr.delete_at(item_to_delete ) unless item_to_delete == nil
#   end
# 
#   def next
#     temp = @attr[@index_counter]
#     @index_counter +=1
#     return temp
#   end
# 
#   def each
#     0.upto( @attr.length-1 ) { |i | yield @attr[i]   }
#   end
# end
# 

#   
# 
# # Module for handling the Javascript pop-ups. Not in use currently, will be available in future.
# # Use ff.startClicker() method for clicking javascript pop ups. Refer to unit tests on how to handle
# # javascript pop up (unittests/javascript_test.rb)
# module Dialog
#   # Class for handling javascript popup. Not in use currently, will be available in future. See unit tests on how to handle
#   # javascript pop up (unittests/javascript_test.rb).
#   class JSPopUp
#     include Container
# 
#     def has_appeared(text)
#       require 'socket'
#       sleep 4
#       shell = TCPSocket.new("localhost", 9997)
#       read_socket(shell)
#       #jssh_command =  "var url = document.URL;"
#       jssh_command = "var length = getWindows().length; var win;length;\n"
#       #jssh_command << "for(var i = 0; i < length; i++)"
#       #jssh_command << "{"
#       #jssh_command << "   win = getWindows()[i];"
#       #jssh_command << "   if(win.opener != null && "
#       #jssh_command << "      win.title == \"[JavaScript Application]\" &&"
#       #jssh_command << "      win.opener.document.URL == url)"
#       #jssh_command << "   {"
#       #jssh_command << "       break;"
#       #jssh_command << "   }"
#       #jssh_command << "}"
# 
#       #jssh_command << " win.title;\n";
#       #jssh_command << "var dialog = win.document.childNodes[0];"
#       #jssh_command << "vbox = dialog.childNodes[1].childNodes[1];"
#       #jssh_command << "vbox.childNodes[1].childNodes[0].childNodes[0].textContent;\n"
#       puts jssh_command
#       shell.send("#{jssh_command}", 0)
#       jstext = read_socket(shell)
#       puts jstext
#       return jstext == text
#     end
#   end # JSPopUp
# end # Dialog
# 
