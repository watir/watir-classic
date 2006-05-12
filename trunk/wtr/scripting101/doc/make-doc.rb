#!/usr/bin/env ruby
require 'redcloth'

def convert( textile_file )
  "Convert file in textile to html."
  r = RedCloth.new( File.read( textile_file ))
  r.fold_lines = true
  html = r.to_html
end

(Dir["./*.txt"] + Dir["../exercises/*.txt"] - ["./using-irb.txt"]).each do
|textile_file|
  begin
    html = convert( textile_file )
    html_file = textile_file.sub(/\.txt$/, ".html")
    File.open( html_file, "w" ) {| f | f.write(html)}
    puts html_file
  rescue StandardError => error
    puts error.message
  end
end
