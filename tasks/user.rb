# tasks/user.rb
#
# Tasks for Ubuntu setup

namespace :user do
  task :setup do
    copy_ssh_id
    checkout_dotfiles
    chsh
    cleanup
  end

  task :copy_ssh_id do
    run "mkdir -p -m 700 ~/.ssh"
    #put authorized_keys, '.ssh/authorized_keys'
    upload "#{ENV['HOME']}/.ssh/authorized_keys", '.ssh/authorized_keys', :mode => '600'
  end

  task :checkout_dotfiles do
    hostkey = <<_EOT
|1|7un0KB6zimuKNwBmANoSyrRFwVM=|g+DMf3scYk5ZZ+wvnaaYXyl1VNI= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwzvAHkh5FScJGoddt8/B6mAeWGFO1biuJ+Cp5SGmC8/vrSAtvFuXieirA2AVXBGe8SJBrJAXih5qrsLuFTLnnvnc4uytHF0OgchF6uPagUg6RDYXuuUiU2muwuTJ1IsgnAwZ2GhWcAVF1XMr9p80DD7Yb7aiqkcLnWHENOTyxs/+rBgu//sH26h0LxBvIgQv/EPpJ4BHdh+qm6o2gquAAkfnT5coAfMAc5h9azS6oa6CWp0oPfm9GtIgTtzsccli3v3D/daA2sO+8S2IBXoet66p27W0zFlMfWv+sDSUZplvpWMJcOxnlqHIQm3nfFGAHwNBafW2SxNIDQ9CgubJeQ==
|1|HbYfaQFjWW/HvGr9FL67UgCrkL0=|vwvaGVM0En471vvCHo2GwU2TrZI= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwzvAHkh5FScJGoddt8/B6mAeWGFO1biuJ+Cp5SGmC8/vrSAtvFuXieirA2AVXBGe8SJBrJAXih5qrsLuFTLnnvnc4uytHF0OgchF6uPagUg6RDYXuuUiU2muwuTJ1IsgnAwZ2GhWcAVF1XMr9p80DD7Yb7aiqkcLnWHENOTyxs/+rBgu//sH26h0LxBvIgQv/EPpJ4BHdh+qm6o2gquAAkfnT5coAfMAc5h9azS6oa6CWp0oPfm9GtIgTtzsccli3v3D/daA2sO+8S2IBXoet66p27W0zFlMfWv+sDSUZplvpWMJcOxnlqHIQm3nfFGAHwNBafW2SxNIDQ9CgubJeQ==
_EOT
    put hostkey, '.ssh/known_hosts'
    run "svn co XXXX"
    run "ln -s .dotfiles/.zsh* .dotfiles/.zlog* ."
  end

  task :chsh do
    last unless loginshell
    run "chsh -s #{loginshell}", :pty => true do |channel, stream, data|
      channel.send_data "#{password}\n" if /assword:/ =~ data
    end
  end

  task :cleanup do
    run "rm -rf .bash* .profile .cache"
  end
end

# vim: ts=2 sw=2 et ft=ruby:
