generic_unix_daemon  
======

generic_unix_daemon is a library to build trivial socket command server in ruby.

The source code is located at : <http://github.com/hanklords/generic_unix_daemon>

Usage
-----

### Server

```ruby
require "generic_unix_server"

class TestServer < GenericUnixServer
  def_cmd :TIME do |*args|
    "OK " + Time.now
  end
end

s = TestServer.new('test.sock')

s.start!
```


### Client

```ruby
require "generic_unix_server"

c = GenericUnixClient.new('test.sock')
p c.send_cmd(:HELP)
p c.send_cmd(:TIME)

```
