RUBY?=ruby

syntax:
	${RUBY} -dcw -I./lib ./lib/Borges.rb

test: syntax
	${RUBY} -dw -I./lib ./lib/Borges/TestCase.rb

all: syntax
	${RUBY} -w -I./lib ./lib/Borges/WEBrick.rb

sushinet: syntax
	${RUBY} -w -I./lib -I./data/examples/ruby/Borges/ ./data/examples/ruby/Borges/SushiNet.rb

doc: syntax
	rdoc -Tcss2 -x "setup.rb|extra" -o data/doc/ruby/Borges/RDoc -w 2 

clean:
	rm -rf data/doc/ruby/Borges/RDoc .*.swp
	rm -f config.save InstalledFiles

