#!/usr/bin/env ruby
require 'redcloth'

def convert( textile_file )
  "Convert file in textile to html."
  html = RedCloth.new( File.read( textile_file )).to_html
  html.gsub(/<br \/>/, '') # because i like auto-fill mode
end

(Dir["*.txt"] + Dir["../lab/exercises/*.txt"]).each do |textile_file|
  begin
    html = convert( textile_file )
    html_file = textile_file.sub(/\.txt$/, ".html")
    File.open( html_file, "w" ) {| f | f.write(html)}
    puts html_file
  rescue StandardError => error
    puts error.message
  end
end
