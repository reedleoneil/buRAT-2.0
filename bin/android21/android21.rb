
gems = [
          'json',
          'faye/websocket'
        ]

libs = [
          'lib/android',
          'lib/inator',
          'lib/inators/buandroid_inator',
          'lib/inators/buremoteshell',
          'lib/inators/buremoteshell_inator',
          'lib/inators/busocket',
          'lib/inators/busocket_inator'
        ]

gems.each { |gem| require gem }
libs.each { |lib| require_relative lib }

android = Android.instance
remoteshell = BuRemoteShell.new('bash')
socket = BuSocket.new(nil, 'ws://localhost:10969', true, 7)
android.id = '0021'
android.name = 'Android 21'
android.type = 'Slave'
android.computer = 'katana'
android.user = 'samurai'
android.os = 'Ubuntu 18.04'
android.ip = 'localhost'
android.country = 'PH'
android.city = 'Minalin'
android.socket = socket
android.inators << BuAndroidInator.new("0001", "Core", android)
android.inators << BuRemoteShellInator.new("0002", "Remote Shell", remoteshell)
android.inators << BuSocketInator.new("0003", "Socket", socket)
android.connect
