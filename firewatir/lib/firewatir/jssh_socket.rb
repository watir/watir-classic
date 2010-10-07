module JsshSocket
  # Determine if str is a valid identifier in Javascript
  # This is NOT a full validation - it will mess up on unicode. Sorry.
  # See Section 7.6 of the ECMA-262 spec
  def valid_js_identifier?(str)
    /\A[a-z$_][a-z0-9]*\Z/i.match(str)
  end

  # Evaluate javascript and return result. Raise an exception if an error occurred.
  def js_eval(str)
    str.gsub!("\n", "")
    jssh_socket.send("#{str};\n", 0)
    value = read_socket()
    if md = /^(\w+)Error:(.*)$/.match(value)
      errclassname="JS#{md[1]}Error"
      unless JsshSocket.const_defined?(errclassname)
        JsshSocket.const_set(errclassname, Class.new(StandardError))
      end
      raise JsshSocket.const_get(errclassname), md[2]
    end
    value
  end

  # evaluate the provides javascript method on the current object and return
  # the result
  def js_eval_method method_name
    js_eval("#{element_object}.#{method_name}")
  end

  def jssh_socket
    $jssh_socket || @container.jssh_socket
  end

  #
  # Description:
  #  Reads the javascript execution result from the jssh socket.
  #
  # Input:
  # 	- socket - It is the jssh socket, the  only point of communication between the browser and firewatir scripts.
  #
  # Output:
  #	The javascript execution result as string.
  #
  def read_socket(socket = jssh_socket)
    return_value = ""
    data = ""
    receive = true
    #puts Thread.list
    s = nil
    while(s == nil) do
      s = Kernel.select([socket] , nil , nil, 1)
    end
    #if(s != nil)
    for stream in s[0]
      data = stream.recv(1024)
      #puts "data is : #{data}"
      while(receive)
        #while(data.length == 1024)
        return_value += data
        if(return_value.include?("\n> "))
          receive = false
        else
          data = stream.recv(1024)
        end
        #puts "return_value is : #{return_value}"
        #puts "data length is : #{data.length}"
      end
    end

    # If received data is less than 1024 characters or for last data
    # we read in the above loop
    #return_value += data

    # Get the command prompt inserted by JSSH
    #s = Kernel.select([socket] , nil , nil, 0.3)

    #if(s != nil)
    #    for stream in s[0]
    #        return_value += socket.recv(1024)
    #    end
    #end

    length = return_value.length
    #puts "Return value before removing command prompt is : #{return_value}"

    #Remove the command prompt. Every result returned by JSSH has "\n> " at the end.
    if length <= 3
      return_value = ""
    elsif(return_value[0..2] == "\n> ")
      return_value = return_value[3..length-1]
    else
      #return_value = return_value[0..length-3]
      return_value = return_value[0..length-4]
    end
    #puts "Return value after removing command prompt is : #{return_value}"
    #socket.flush

    # make sure that command prompt doesn't get there.
    if(return_value[return_value.length - 3..return_value.length - 1] == "\n> ")
      return_value = return_value[0..return_value.length - 4]
    end
    if(return_value[0..2] == "\n> ")
      return_value = return_value[3..return_value.length - 1]
    end
    #puts "return value is : #{return_value}"
    return return_value
  end
end
