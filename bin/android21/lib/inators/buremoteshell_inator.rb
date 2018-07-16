require 'open3'

class BuRemoteShellInator < Inator
  def initialize(id, name, remoteshell)
    super(id, name)
    @remoteshell = remoteshell
    @android = nil
    Thread.new {
    while line = @remoteshell.stdout.gets
      data = {"stdout" => "#{line}"}
      output(@android, data, line) if @android != nil
    end
    }
  end

  def input(android, data, log)
    p android
    @android = android
    shell data
  end

  def shell(cmd)
    #stdin, stdout, stderr, wait_thr = Open3.popen2e(cmd)
    @remoteshell.stdin.puts cmd
  end
end
