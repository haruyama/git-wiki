#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'fileutils'
require './environment'
require 'sinatra'
require 'sinatra/content_for'

get('/') { redirect "/#{HOMEPAGE}" }

# page paths

get '/:page' do
  @menu = Page.new("menu")
  @page = Page.new(params[:page])
  @page.tracked? ? show(:show, @page.name) : redirect('/e/' + @page.uri_encoded_name)
end

get '/:page/raw' do
  @page = Page.new(params[:page])
  send_data @page.raw_body, :type => 'text/plain', :disposition => 'inline'
end

get '/:page/append' do
  @page = Page.new(params[:page])
  @page.update(@page.raw_body + "\n\n" + params[:text], params[:message])
  redirect '/' + @page.uri_encoded_name
end

get '/e/:page' do
  @menu = Page.new("menu")
  @page = Page.new(params[:page])
  show :edit, "Editing #{@page.name}"
end

post '/e/:page' do
  @menu = Page.new("menu")
  @page = Page.new(params[:page])
  @page.update(params[:body], params[:message])
  redirect '/' + @page.uri_encoded_name
end

post '/eip/:page' do
  @page = Page.new(params[:page])
  @page.update(params[:body])
  @page.body
end

get '/h/:page' do
  @menu = Page.new("menu")
  @page = Page.new(params[:page])
  show :history, "History of #{@page.name}"
end

get '/h/:page/:rev' do
  @menu = Page.new("menu")
  @page = Page.new(params[:page], params[:rev])
  show :show, "#{@page.name} (version #{params[:rev]})"
end

get '/d/:page/:rev' do
  @page = Page.new(params[:page])
  show :delta, "Diff of #{@page.name}"
end

# application paths (/a/ namespace)

get '/a/list' do
  pagenames = $repo.tree.contents.map { |c| c.name}
  @menu = Page.new("menu")
  @pages = pagenames.select { |name| name[0] != '_'}.sort.map { |name| Page.new(name) }
  show(:list, 'Listing pages')
end

get '/a/patch/:page/:rev' do
  @page = Page.new(params[:page])
  headers 'Content-Type' => 'text/x-diff'
  headers 'Content-Disposition' => 'filename=patch.diff'
  @page.delta(params[:rev])
end

get '/a/tarball' do
  content_type 'application/x-gzip'
  headers 'Content-Disposition' => 'filename=archive.tgz'
  archive = $repo.archive('HEAD', nil, :format => 'tgz', :prefix => 'wiki/')
  File.open(archive).read
end

get '/a/branches' do
  @menu = Page.new("menu")
  @branches = $repo.branches
  show :branches, "Branches List"
end

get '/a/branch/:branch' do
  $repo.checkout(params[:branch])
  redirect '/' + HOMEPAGE
end

get '/a/history' do
  @menu = Page.new("menu")
  @history = $repo.log
  show :branch_history, "Branch History"
end

post '/a/new_remote' do
  $repo.add_remote(params[:branch_name], params[:branch_url])
  $repo.fetch(params[:branch_name])
  redirect '/a/branches'
end

get '/a/search' do
  @menu = Page.new("menu")
  @search = params[:search]
  @titles = search_on_filename(@search)
  @grep = {}
  [@titles, @grep].each do |x|
    x.values.each do |v|
      v.each { |w| w.last.gsub!(@search, "<mark>#{escape_html @search}</mark>") }
    end
  end
  show :search, 'Search Results'
end

# file upload attachments

get '/a/file/upload/:page' do
  @page = Page.new(params[:page])
  show :attach, 'Attach File for ' + @page.name
end

post '/a/file/upload/:page' do
  @page = Page.new(params[:page])
  @page.save_file(params[:file], params[:name])
  redirect '/e/' + @page.name
end

get '/a/file/delete/:page/:file.:ext' do
  @page = Page.new(params[:page])
  @page.delete_file(params[:file] + '.' + params[:ext])
  redirect '/e/' + @page.uri_encoded_name
end

get '/_attachment/:page/:file.:ext' do
  @page = Page.new(params[:page])
  send_file(File.join(@page.attach_dir, params[:file] + '.' + params[:ext]))
end

# support methods
def search_on_filename(search)
  needle = search.as_wiki_link
  titles = {}
  pagenames = $repo.tree.contents.map { |c| c.name}
  pagenames.each do |page|
    page.force_encoding('UTF-8')
    next unless page.include? needle
    current_branch_sha1 = $repo.log.first
    # unfreeze the String page by creating a "new" one
    titles["#{current_branch_sha1}:#{page}"] = [[0, "#{page}"]]
  end
  titles
end

# returns an absolute url
def page_url(page)
  "#{request.env["rack.url_scheme"]}://#{request.env["HTTP_HOST"]}/#{page}"
end

private

def show(template, title)
  @title = title
  erb(("#{template}.html").to_sym)
end
