require_relative 'pipe.rb'
class PipeInator
  attr_reader :pipes
  def initialize
    @pipes = []
  end

  def help
    "PipeInator v1.00"
  end

  def open(clientIn, inatorIn, clientOut, inatorOut)
    @pipes << Pipe.new(clientIn, inatorIn, clientOut, inatorOut)
  end

  def close(uuid)
    @pipes.delete_if { |pipe| pipe.uuid == uuid }
  end

  def pipe(clientIn, inatorIn)
    @pipes.select { |pipe| pipe.clientIn == clientIn && pipe.inatorIn == inatorIn }
  end
end
