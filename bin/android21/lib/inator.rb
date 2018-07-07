class Inator
  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def input(data, log)
    #Implement on the concrete class.
  end

  def output(data ,log)
    Android.instance.output(@id, data, log)
  end
end
