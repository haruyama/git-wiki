# -*- encoding: utf-8 -*-
require './git-wiki'
disable :run
Encoding.default_internal = nil
Encoding.default_external = 'UTF-8'
set :root, Pathname(__FILE__).dirname
run Sinatra::Application
