class BuAndroidInator < Inator
  def initialize(id, name, android)
    super(id, name)
    @android = android
  end

  def input(data, log)
    if data == 'disconnect'
      @android.disconnect
    end
  end
end
