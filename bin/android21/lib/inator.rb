class Inator
  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def in(data, log)
    p "not implemented"
  end

  def out(data ,log)
    packet = {
      "header" => "data",
      "payload" => {
        "android" => Android.instance.id,
        "inator" => @id,
        "data" => data
      },
      "trailer" => log
    }.to_json
    Android.instance.ws.send(packet)
  end
end
