require 'bundler/setup'

require 'securerandom'

require 'git'
require 'facwparser'

require './extensions'
require './page'


REPO_LOCATIONS = ["#{ENV['HOME']}/wiki", "#{ENV['HOME']}/.wiki"]

def is_repo?(location)
  File.exists?(location) && File.directory?(location)
end

def find_repo(locations = REPO_LOCATIONS)
  locations.detect do |location|
    is_repo?(location)
  end
end

def create_repo(location = REPO_LOCATIONS.first)
  puts "Initializing repository in #{location}..."
  Git.init(location)
  location
end

def find_or_create_repo
  find_repo || create_repo
end

GIT_REPO = find_or_create_repo
HOMEPAGE = 'home'
SESSION_SECRET = SecureRandom.random_bytes(32)

JIRA_BROWSE_URL = ENV['JIRA_BROWSE_URL'] || ''

$repo = Git.open(GIT_REPO)

