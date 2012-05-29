require 'socket'
require_relative 'daemon'

class GenericUnixServer
  MAX_CMD_LEN=1024
  class Error < StandardError; end
  class CmdToLong < StandardError; end
  include Daemon

  def self.def_cmd(cmd, &blk); define_method("process_" + cmd.to_s, &blk) end
  
  def_cmd(:CMD)  { |*args| "OK " + @known_commands.keys.sort.join(" ") }
  def_cmd(:HELP) { |*args| "OK Usage: CMD param1 param2 ..." }
  def_cmd(:ECHO) { |*args| "OK " + args.join(" ") }

  def start!
    File.delete(@socket_file) if File.exists?(@socket_file)
    @server = UNIXServer.open(@socket_file)
    File.chmod(0666, @socket_file)
      
    while c = @server.accept
      begin
      while l = c.gets(MAX_CMD_LEN)
        raise CmdToLong if l.size >= MAX_CMD_LEN
        c.puts process(l.strip).to_s
      end
      rescue => e
        p e
      ensure
        c.close
      end
    end
  ensure
    @server.close
    File.delete(@socket_file)
  end
  
  private
  def initialize(socket_file)
    @socket_file = File.expand_path(socket_file)
    @known_commands = Hash.new(:unknown)
    methods.each {|m| @known_commands[m.to_s.sub(/^process_/, '')] = m if m =~ /^process_/ }
  end
  
  def process(line)
    cmd, *args = line.split(" ")
    __send__(@known_commands[cmd], *args)
  rescue Error => e
    "NOK " + e.to_s
  rescue => e
    p e
    "NOK Internal Error"
  end
  
  def unknown(*args); "NOK Unknown Command" end
end

class GenericUnixClient
  class Error < StandardError; end
  def initialize(s); @socket_file = s end
  
  def send_cmd(cmd, *params)
    UNIXSocket.open(@socket_file) {|f|
      f.puts params.unshift(cmd).join(" ")
      l = f.gets
      raise Error if l.nil?
      status, *response = l.split(" ")
      raise Error.new(response.join(" ")) if status != "OK"
      response
   }
  end
end
