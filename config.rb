# Master configuration file for Capistrano

# Use multiple stage extension
set :stage_dir, 'config'
require 'capistrano/ext/multistage'

set :dns_servers, [ '8.8.8.8', '8.8.4.4' ]
set :search_domains, [ 'arege.jp' ]
set :pkgs, [
  'lv', 'zsh', 'fdclone', 'vim', 'wget', 'w3m', 'rsync',
  'git-core', 'subversion',
  'lsof', 'logcheck',
]
