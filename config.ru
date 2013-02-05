# note for self: the default port is 9292
require './git-wiki'
disable :run
Encoding.default_external = 'utf-8' if defined?(Encoding) && Encoding.respond_to?('default_external')
set :root, Pathname(__FILE__).dirname
run Sinatra::Application
