# git-wiki

A wiki engine that uses a Git repository as its data store.

## Requirements

* sinatra
* rack\_csrf
* thin
* haruyama/ruby-git
* haruyama/facwparser

## usage

% thin start

## What is different in this fork?

* XSS protection
* CSRF protection
* use [highlight.js](http://softwaremaniacs.org/soft/highlight/en/)
* use Confluence Wiki Markup
