require_relative '../lib/pipe.rb'
require_relative '../lib/pipe_inator.rb'

class Test
  def create_pipe
    pipe = Pipe.new("12345", "0000", "54321", "0001")
    p pipe.uuid
    p pipe.clientIn
    p pipe.inatorIn
    p pipe.clientOut
    p pipe.inatorOut
  end

  def pipe_inator
    pipeInator = PipeInator.new()
    p pipeInator.help
    pipeInator.open("zxcv", "0000", "54321", "0003")
    pipeInator.open("qwert", "0001", "54321", "0004")
    pipeInator.open("asdfg", "0002", "54321", "0005")
    p pipeInator.pipes
    pipe_to_remove = pipeInator.pipes[1].uuid
    pipeInator.close(pipe_to_remove)
    p pipeInator.pipes
    p "--------------------------------------"
    p pipeInator.pipe("zxcv", "0000")
  end
end

test = Test.new
test.pipe_inator
