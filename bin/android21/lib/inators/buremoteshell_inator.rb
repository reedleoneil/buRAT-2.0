require 'open3'

class BuRemoteShellInator < Inator
  def initialize(id, name)
    super(id, name)
  end

  def input(data, log)
    shell data
  end

  def shell(cmd)
    stdin, stdout, stderr, wait_thr = Open3.popen2e(cmd)
    Thread.new {
    while line = stdout.gets
      data = {"stdout" => "#{line}"}
      output(data, line)
    end
    }
  end
end
