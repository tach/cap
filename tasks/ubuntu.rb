# tasks/ubuntu.rb
#
# Tasks for Ubuntu setup

namespace :ubuntu1004 do
  task :init_setup do
    minimize
    setup_dns
    install_pkgs
  end

  task :install_pkgs do
    run "#{sudo} apt-get update"
    install_deb(*pkgs)
  end

  task :dist_upgrade do
    # Set sources.list
    new_dist = ENV['dist'] or raise "Specify distribution"
    sources_list = <<_EOT
# This file is generated automatically by Capistrano
# See https://github.com/tach/cap/ for details.

# OFFICIAL PACKAGES
deb http://jp.archive.ubuntu.com/ubuntu #{new_dist} main restricted universe multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu #{new_dist} main restricted universe multiverse

# OFFICIAL UPDATES
deb http://jp.archive.ubuntu.com/ubuntu #{new_dist}-updates main restricted universe multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu #{new_dist}-updates main restricted universe multiverse

# SECURITY UPDATES
deb http://security.ubuntu.com/ubuntu #{new_dist}-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu #{new_dist}-security main restricted universe multiverse
_EOT
    put_as_root(sources_list, "/etc/apt/sources.list")

    # Upgrade
    debconf_noninteractive
    run "#{sudo} apt-get update"
    # TODO: Failed because debconf dialog has shown
    #       debconf noniteractive setting disabled?
    #install_deb('apt')
    #install_deb('dpkg')
    #install_deb('libc6')
    #install_deb('debconf')
    #run "#{sudo} apt-get -y --force-yes upgrade"
    # TODO: Failed because python-minimal and python2.7 is conflict with
    #       old one
    #run "#{sudo} apt-get -y --force-yes dist-upgrade"
    # TODO: after that, we mustrun update-grub and grub-install
    # TODO: /etc/resolv.conf has been empty because of resolvconf package
    #       We should fix this
    debconf_interactive
  end

  task :minimize, :roles => :ubuntu1004 do
    listfile = 'files/selections_minimum_10.04.list'
    exec_minimize(listfile)
  end

  task :setup_dns, :roles => :ubuntu1004 do
    # Generate unbound.conf
    conf = <<_EOT
# This file is generated automatically by Capistrano
# See https://github.com/tach/cap/ for details.

server:
  verbosity: 1
  do-ip6: no
  chroot: ""

forward-zone:
  name: "."
_EOT
    dns_servers.map { |addr| conf << "  forward-addr: #{addr}\n" }

    # Install unbound
    install_deb('unbound')

    # Update unbound.conf
    tmp_conf = "/tmp/unbound.conf.#{rand}"
    put conf, tmp_conf
    run "#{sudo} cp #{tmp_conf} /etc/unbound/unbound.conf"
    run "rm #{tmp_conf}"
    run "#{sudo} service unbound restart"
  end
end

def exec_minimize(filename)
  # Put selections file
  sel_file = "/tmp/dpkg.#{rand}.selections"
  sel_str = File.read(filename)
  put sel_str, sel_file

  # Set selections
  run "#{sudo} apt-get update"
  run "#{sudo} dpkg --clear-selections"
  run "#{sudo} dpkg --set-selections < #{sel_file}"
  run "rm -f #{sel_file}"

  # Install/Remove packages
  run "#{sudo} apt-get -y --force-yes dselect-upgrade"
  run "#{sudo} sudo aptitude -y purge '~c'"
end

def install_deb(*pkgs)
  debconf_noninteractive
  run "#{sudo} apt-get -y --force-yes install #{pkgs.join(' ')}"
  debconf_interactive
end

def debconf_noninteractive
  run "echo 'debconf debconf/frontend select Noninteractive' | #{sudo} debconf-set-selections"
end

def debconf_interactive
  run "echo 'debconf debconf/frontend select Dialog' | #{sudo} debconf-set-selections"
end

# vim: ts=2 sw=2 et ft=ruby:
