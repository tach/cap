# Master configuration file for Capistrano

# Use multiple stage extension
set :stage_dir, 'config'
require 'capistrano/ext/multistage'

# Capistrano configuration
ssh_options[:forward_agent] = true

# User configuration
set :loginshell, '/bin/zsh'

set :dns_servers, [ '8.8.8.8', '8.8.4.4' ]
set :search_domains, [ 'arege.jp' ]
set :pkgs, [
  'lv', 'zsh', 'fdclone', 'vim', 'wget', 'w3m', 'rsync',
  'git-core', 'subversion',
  'logcheck', 'ethtool',
  'lsof', 'strace', 'ltrace', 'tcpdump',
  'language-pack-ja', 'language-pack-ja-base', 'nkf',
]
