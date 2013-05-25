# git-wiki

A wiki engine that uses a Git repository as its data store.

## Requirements

* [Sinatra](http://www.sinatrarb.com/)
* [Sinatra::Reloader](http://www.sinatrarb.com/contrib/reloader.html)
* [Sinatra::ContentFor](http://www.sinatrarb.com/contrib/content_for.html)
* [rack\_csrf](https://rubygems.org/gems/rack_csrf)
* [Thin](http://code.macournoyer.com/thin/)
* [haruyama/ruby-git](https://github.com/haruyama/ruby-git)
* [haruyama/facwparser](https://github.com/haruyama/facwparser)

## usage

% bundle
% thin start

## What is different in this fork?

* XSS protection
* CSRF protection
* use [highlight.js](http://softwaremaniacs.org/soft/highlight/en/)
* use Confluence (3.5 and earlier) Wiki Markup

## License

The MIT License
 Copyright (C) 2004 Sam Hocevar
 Copyright (C) HARUYAMA Seigo

This system includes following products. I re-distribute them under each licence.

* [jQuery version 2.0.1](http://jquery.com/)
* [Twitter Bootstrap version 2.3.1](http://twitter.github.com/bootstrap/)
* [highlight.js version 7.3](http://softwaremaniacs.org/soft/highlight/en/)
