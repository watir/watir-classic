def update_glob(glob)
  Dir[glob].each do |fn|
    content = File.read(fn)
    if content =~ lic_re
      content.sub!(lic_re, new_lic)
    else
      content = new_lic + "\n" + content
    end
    puts 'writing license to ' + fn + '...'
    File.open(fn, 'w+') do |f| f.puts content end
  end
end

lic = File.read('../doc/license.txt')
lic_re = /=begin.*Copyright.*?=end/mi
new_lic = "=begin\n#{lic}=end"

update_glob('../src/**/*.rb')


