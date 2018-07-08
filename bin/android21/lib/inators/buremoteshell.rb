class BuRemoteShell
  attr_accessor :stdin, :stdout, :stderr, :wait_thr
  def initialize(shell)
    stdin, stdout, stderr, wait_thr = Open3.popen2e(shell)
    @stdin = stdin
    @stdout = stdout
    @stderr = stderr
    @wait_thr = wait_thr
  end
end
