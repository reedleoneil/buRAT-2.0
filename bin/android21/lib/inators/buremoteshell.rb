require 'open3'

class BuRemoteShell < Inator
  def initialize()
    super("1111", "Remote Shell")
  end

  def in(data, log)
    cmd = data
    puts cmd
    stdin, stdout, stderr, wait_thr = Open3.popen2e(cmd)
    Thread.new {
    while line = stdout.gets
      data = {"stdout" => "#{line}"}
      out(data, line)
    end
    }
  end
end
