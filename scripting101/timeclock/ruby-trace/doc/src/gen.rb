TOP_ROW = <<END
<table border="0" cellpadding="3" cellspacing="0" width="100%"
bgcolor="#CCCCCC">
    <tr>
        <td width="100%"><a href="http://www.visibleworkings.com">Visible
        Workings</a> &gt; Ruby-Trace User's Guide</td>
    </tr>
</table>
END

TITLE_ROW = <<END
<table border="0" cellpadding="7" cellspacing="0" width="100%"
bgcolor="#AAAAAA">
    <tr>
        <td><p align="center"><font size="5"><strong>The Ruby-Trace
        User's Guide </strong></font><br>
        <a href="mailto:marick@visibleworkings.com"
        title="marick@visibleworkings.com">Brian Marick</a> </p>
        </td>
    </tr>
</table>
END


def contents(line)
  contents_head = %Q{
      <table border="0" cellpadding="3" cellspacing="0" width="100%"
             bgcolor="#CCCCCC">
        <tr>
    }

  contents_tail = %Q{
        </tr>
      </table>
    }     

  simple = proc { | name |
    %Q{
          <td width="20%"><p align="center">#{name}</p></td>
      }
  }

  href = proc { | url, name | 
    %Q{
          <td width="20%">
            <p align="center"><a href="#{url}">#{name}</a></p>
          </td>
      }
  }

  entry = proc { | url, name |
    line =~ name ? simple.call(name) : href.call(url, name)
  }

  
  contents_head + entry.call('intro.html', 'Contents') + 
    entry.call('simple-programs.html', 'Simple Programs') + 
    entry.call('server-programs.html', 'Server Programs') + 
    entry.call('API.html', 'API') + 
    entry.call('glossary.html', 'Glossary') + contents_tail
end

END_MATTER = <<-END
  <p>Please send comments on this document to <a
  href="mailto:marick@visibleworkings.com">marick@visibleworkings.com</a>.
  The ruby-trace mailing list is at at <a
  href="http://groups.yahoo.com/group/ruby-trace">http://groups.yahoo.com/group/ruby-trace</a>.</p>
  
  <p>Copyright © 2001 by Brian Marick. This material may be
  distributed only subject to the terms and conditions set forth in
  the Open Publication License, draft v1.0 or later (the latest
  version is presently available at <a
  href="http://www.opencontent.org/openpub">http://www.opencontent.org/openpub</a>).
  </p>
  END

def one_file(file)
  lines = File.readlines file
  out = File.open("../" + file, "w")
  lines.each { |l|
    case l
    when /TOP_ROW/ then out.puts TOP_ROW
    when /TITLE_ROW/ then out.puts TITLE_ROW
    when /CONTENTS_ROW/ then out.puts contents l
    when /END_MATTER/ then out.puts END_MATTER
    else out.puts l
    end
  }
end

ARGV.each{ | arg | one_file(arg) }


exit 0



