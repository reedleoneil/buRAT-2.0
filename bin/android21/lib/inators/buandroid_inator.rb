class BuAndroidInator < Inator
  def initialize(id, name, android)
    super(id, name)
    @android = android
  end

  def input(android, data, log)
    if data == 'disconnect'
      @android.disconnect
    end
  end
end
