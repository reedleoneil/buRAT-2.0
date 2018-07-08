require 'open3'

class BuRemoteShellInator < Inator
  def initialize(id, name, remoteshell)
    super(id, name)
    @remoteshell = remoteshell
    Thread.new {
    while line = @remoteshell.stdout.gets
      data = {"stdout" => "#{line}"}
      output(data, line)
    end
    }
  end

  def input(data, log)
    shell data
  end

  def shell(cmd)
    #stdin, stdout, stderr, wait_thr = Open3.popen2e(cmd)
    @remoteshell.stdin.puts cmd
  end
end
