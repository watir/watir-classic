# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'ruby-trace/errors'
require "ruby-trace/misc"
require 'ruby-trace/message'
require 'monitor'
require 'ftools'


module Trace

  # Destinations are named entities that obey the accept(Message)
  # protocol.
  class Destination
    attr_reader :name

    def initialize(name)
      @name=name
      @monitor = Monitor.new
    end

    def accept(message)
      subclass_responsibility
    end
  end

                  ### A fixed-size ring buffer. ###

  class BufferDestination < Destination
    include TraceErrors

    def initialize(name)
      super
      @limit = 100
      @next_index = 0
      new_buffer
    end

    # Empty buffer of messages.
    def clear
      @monitor.synchronize {
        new_buffer
      }
    end

    def accept(message)
      @monitor.synchronize {
        @buffer[@next_index] = message
        @next_index += 1
        @next_index = 0 if @next_index == @limit
      }
    end

    # Return an array containing all messages in the buffer, in the
    # order they were entered.
    def messages
      @monitor.synchronize {
        if @buffer[@next_index] == nil
          @buffer[0...@next_index]
        else
          @buffer[@next_index...@limit] + @buffer[0...@next_index]
        end
      }
    end

    # Change the number of messages the buffer holds. The old
    # messages are retained. If there are too many for the new
    # limit, the oldest are dropped.
    def limit=(limit)
      @monitor.synchronize {
        assert(limit > 0) { "Buffer size limit must be greater than zero." }

        old_messages = messages
        @limit = limit
        new_buffer
        old_messages.each { | msg | accept(msg) } 
        limit
      }
    end

    # Send the messages to the given IO stream, after formatting
    # with the given formatter.
    def to_IO(io, formatter=Formatter.new)
      @monitor.synchronize {
        messages.each do | msg |
          io.puts(formatter.accept(msg))
        end
      }
    end

    # Send the messages to some other destination.
    def to_destination(destination)
      @monitor.synchronize {
        # Frames are adjusted (-1) so that the message is tagged as
        # coming from this routine.
        destination.accept(Message.new("==== Beginning of buffer contents.",
                                       "", "announce", -1))
        messages.each do | msg |
          destination.accept(msg)
        end
        destination.accept(Message.new("==== End of buffer contents.",
                                       "", "announce", -1))
      }
    end

    private

    def new_buffer
      @buffer = Array.new(@limit)
      @next_index = 0
    end

  end

                    ### Just print to $defout ###

  class PrintingDestination < Destination

    attr_accessor :formatter

    def initialize(name)
      super
      @formatter = Formatter.new
    end
    
    def accept(message)
      @monitor.synchronize {
        puts @formatter.accept(message)
      }
    end
  end

    ### Logfiles with versioning, size limits, and timestamps ###

  # It would be appealing to make Logfile more general-purpose, make it
  # inherit from File. Two problems:
  # - it's a hassle making it support all the File methods.
  # - reopen is problematic on Windows. It makes sense to make reopen
  #   with no arguments back up the current file and leave the stream
  #   pointing to a new empty logfile. But when I do that, I get unclosed
  #   files lying around, which is a problem if you then reopen one of them
  #   (as you would if the greatest_backup_tag is '000').

  class LogfileDestination < Destination
    include TraceErrors
    include Util

    Infinity=-1  # Size limit to use if the file size is unlimited.
    Timestamp_directive = /%t/
    Backup_directive = /%b/

    attr_accessor :limit, :formatter
    attr_reader :filename, :greatest_backup_tag

    def initialize(name, filename_as_given = 'Tracelog.txt', modestring="w",
                   limit=LogfileDestination::Infinity,
                   greatest_backup_tag = '000')

      Internal.trace.announce("Creating #{name} on file #{filename_as_given}.")
      Internal.trace.announce("Mode=#{modestring}; limit = #{limit}; greatest backup tag = #{greatest_backup_tag}.")

      valid_modestrings = ['a', 'w']
      assert(valid_modestrings.include?(modestring)) {
        try_one("Invalid mode string: '#{modestring}'.",
                valid_modestrings)
      }

      assert(('000'..'999').include?(greatest_backup_tag)) {
        "The greatest backup tag argument must be in ('000'..'999')."
      }
               

      super name
      @limit = limit
      @greatest_backup_tag = greatest_backup_tag
      @formatter = Formatter.new(Formatter::TWO_LINE_WITH_DATE,
                                 Formatter::VERBOSE_SORTABLE_TIME)

      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      @timestamped_filename =
        filename_as_given.gsub(Timestamp_directive, timestamp)
      @filename = @timestamped_filename.gsub(Backup_directive, "")

      if Backup_directive =~ @timestamped_filename
        @backup = Struct.new(:prefix, :suffix, :glob, :regex).new(
           $`, $',
           @timestamped_filename.gsub(Backup_directive, '.[0-9][0-9][0-9]'),
           Regexp.new(@timestamped_filename.gsub(Backup_directive, '\\.(...)')))
        backup if File.exists?(@filename)
      end
      
      @file = File.new(@filename, modestring)
      @size = File.size(@filename)
    end

    # Note the size count is only a rough estimate.
    def accept (message)
      @monitor.synchronize {
        string = @formatter.accept(message)
        strsize = string.length + 3  # assume 2 lines, plus CR on Windows.
        ensure_room_for(strsize)
        @size += strsize
        @file.puts string
      }
    end

    def close()
      @file.close
    end

    private

    def ensure_room_for(numbytes)
      return if @limit == Infinity

      if @size + numbytes > @limit
        reopen
      end
    end

    ## Move @filename to a backup file. The files are used
    ## round-robin from "*000*" to "*#{@greatest_backup_tag}*".
    ##
    ## Note, we use file modification time for ordering, rather than
    ## file 'creation' time because File::Stat.ctime is unreliable
    ## on Windows NT. (If a file 'foo' is created, then deleted, then
    ## a file 'foo' is created, the new 'foo' will have the ctime of
    ## the first.)

    def backup
      matches = Dir[@backup.glob].sort # Dir[] not guaranteed sorted.
      if matches.length == 0
        version = '000'
      else
        # Find *final* instance of the most recent time.
        # Since files are updated round-robin, any decrease in 
        # modification times means that the latest file has been found. 
        max_value = 0
        i = 0
        
        while i < matches.length
          seconds = test(?M, matches[i]).to_i
          break if seconds < max_value 
          max_value = seconds if seconds >= max_value
          i += 1
        end

        matches[i-1] =~ @backup.regex
        if ($1 >= @greatest_backup_tag)
          assert_identifiable_youngest_file(matches)
          version = '000'
        else
          version = $1.succ
        end
      end
      Internal.trace.announce "Creating backup file #{backup_name(version)}."
      File.move(@filename, backup_name(version))
    end

    def backup_name(number)
      @backup.prefix + '.' + number + @backup.suffix
    end

    # What if all the backup files had the same mod time?
    # Which file should be replaced?
    def assert_identifiable_youngest_file(filenames)
      return unless filenames.length > 1
      
      # This separate return check because it's possible some of the
      # filenames are left over from an earlier run.
      return if @greatest_backup_tag == '000'

      same_mods = filenames.find_all { | x |
        test(?M, filenames[0]) == test(?M, x)
      }

      assert(filenames.length > same_mods.length) {
        files = filenames.collect { | e | "#{e} -> #{test(?M, e)}" }
        files[0,0] = "Every backup file has the same modification time: "
        files.push "There's no way to know which should be replaced."
        lines(files)
      }
    end

    def reopen()
      close
      backup if @backup
      @file = File.new(@filename, "w")
      @size = File.size(@filename)
    end

  end

end
