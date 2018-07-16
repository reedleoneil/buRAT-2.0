class Inator
  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def input(android, data, log)
    #Implement on the concrete class.
  end

  def output(android, data ,log)
    Android.instance.output(android, @id, data, log)
  end
end
