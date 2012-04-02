# lib/common.rb
#
# Common Utility Functions

def put_as_root(data, path, options={})
  tmp_path = "/tmp/#{File.basename(path)}.#{rand}"
  put path, tmp_path, options
  run "sudo cp #{tmp_path} #{path}"
  run "rm #{tmp_path}"
end

# vim: ts=2 sw=2 et ft=ruby:
