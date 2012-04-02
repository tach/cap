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
    run "sudo cp #{tmp_conf} /etc/unbound/unbound.conf"
    run "rm #{tmp_conf}"
    run "#{sudo} service unbound restart"

    # Generate resolv.conf
    ns_str = ''
    dns_servers.map { |addr| ns_str << "nameserver #{addr}\n" }
    conf = <<_EOT
# This file is generated automatically by Capistrano
# See https://github.com/tach/cap/ for details.
search #{search_domains.join(' ')}
nameserver 127.0.0.1
#{ns_str}
_EOT

    # Update resolv.conf
    tmp_conf = "/tmp/resolv.conf.#{rand}"
    put conf, tmp_conf
    run "sudo cp #{tmp_conf} /etc/resolv.conf"
    run "rm #{tmp_conf}"
  end
end

def exec_minimize(filename)
  # Put selections file
  sel_file = "/tmp/dpkg.#{rand}.selections"
  sel_str = File.read(filename)
  put sel_str, sel_file

  # Set selections
  run "#{sudo} dpkg --clear-selections"
  run "#{sudo} dpkg --set-selections < #{sel_file}"
  run "rm -f #{sel_file}"

  # Install/Remove packages
  run "#{sudo} apt-get -y --force-yes dselect-upgrade"
  run "#{sudo} sudo aptitude -y purge '~c'"
end

def install_deb(*pkgs)
  run "#{sudo} apt-get -y --force-yes install #{pkgs.join(' ')}"
end

# vim: ts=2 sw=2 et ft=ruby:
