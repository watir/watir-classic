# Only load the customization file we name in a global variable. This
# appears to be the only way to customize IRB. 

module IRB
  # running config
  def IRB.run_config
    if @CONF[:RC]
      rcs = []
      #rcs.push File.expand_path("~/.irbrc") if ENV.key?("HOME")
      #rcs.push ".irbrc"
      #rcs.push "irb.rc"
      #rcs.push "_irbrc"
      rcs.push $irbrc if $irbrc
      catch(:EXIT) do
	for rc in rcs
	  begin
	    load rc
	    throw :EXIT
	  rescue LoadError, Errno::ENOENT
	  rescue
	    print "load error: #{rc}\n"
	    print $!.type, ": ", $!, "\n"
	    for err in $@[0, $@.size - 2]
	      print "\t", err, "\n"
	    end
	    throw :EXIT
	  end
	end
      end
    end
  end
end

module IRB
  module ExtendCommandBundle
    @ALIASES.delete_if { | x | x[0]==:jobs }
  end
end
