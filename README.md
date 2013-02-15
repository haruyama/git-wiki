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

% thin start

## What is different in this fork?

* XSS protection
* CSRF protection
* use [highlight.js](http://softwaremaniacs.org/soft/highlight/en/)
* use Confluence (3.5 and earlier) Wiki Markup
