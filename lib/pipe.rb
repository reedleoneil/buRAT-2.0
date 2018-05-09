class Pipe
  attr_accessor :uuid, :clientIn, :inatorIn, :clientOut, :inatorOut
  def initialize(clientIn, inatorIn, clientOut, inatorOut)
    @uuid = self.object_id
    @clientIn = clientIn
    @inatorIn = inatorIn
    @clientOut = clientOut
    @inatorOut = inatorOut
  end
end
