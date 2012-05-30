# -*- encoding: utf-8 -*-

require File.expand_path("../lib/generic_unix_server", __FILE__)

Gem::Specification.new do |s|
  s.summary = "Generic Unix Server"
  s.name = "generic_unix_server"
  s.author = "Maël Clérambault"
  s.email =  "mael@clerambault.fr"
  s.files = %w(lib/generic_unix_server.rb LICENSE README.md)
  s.add_dependency("daemon")
  s.version = GenericUnixServer::VERSION
end
