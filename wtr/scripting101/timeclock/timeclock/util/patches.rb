require 'drb'

# In the 1.6.7 delivered with Mac OS X 1.2, Socket::TCP_NODELAY is undefined.
# Here is the value from /usr/include/netinet/tcp.h

Socket.const_set('TCP_NODELAY', 1) unless Socket.const_defined?('TCP_NODELAY')


