require 'socket'

class GenericUnixServer
  def self.def_cmd(cmd, &blk); define_method("process_" + cmd.to_s, &blk) end
  
  def_cmd(:CMD)  { |*args| "OK " + @known_commands.keys.sort.join(" ") }
  def_cmd(:HELP) { |*args| "OK Usage: CMD param1 param2 ..." }
  def_cmd(:ECHO) { |*args| "OK " + args.join(" ") }

  def initialize(socket_file)
    @socket_file = socket_file
    File.delete(@socket_file) if File.exists?(@socket_file)
    @known_commands = Hash.new(:unknown)
    methods.each {|m| @known_commands[m.to_s.sub(/^process_/, '')] = m if m =~ /^process_/ }
  end
  
  def process(line)
    cmd, *args = line.split(" ")
    __send__(@known_commands[cmd], *args)
  rescue => e
    p e
    "NOK Internal Error"
  end
  
  def unknown(*args); "NOK Unknown Command" end

  def start
    @server = UNIXServer.open(@socket_file)
    File.chmod(0666, @socket_file)
      
    while c = @server.accept
      begin
      while l = c.gets
        c.puts process(l.strip).to_s
      end
      rescue => e
        p e
      ensure
        c.close
      end
    end
  end
  
  def stop
    @server.close
    File.delete(@socket_file)
  end
end

class GenericUnixClient
  def initialize(s); @socket_file = s end
  
  def send_cmd(cmd, *params)
    UNIXSocket.open(@socket_file) {|f|
      f.puts params.unshift(cmd).join(" ")
      status, *response = f.gets.split(" ")
      response
   }
  end
end