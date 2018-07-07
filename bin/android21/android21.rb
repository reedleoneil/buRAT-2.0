
gems = [
          'json',
          'faye/websocket'
        ]

libs = [
          'lib/android',
          'lib/inator',
          'lib/inators/buandroid_inator',
          'lib/inators/buremoteshell_inator',
        ]

gems.each { |gem| require gem }
libs.each { |lib| require_relative lib }

android = Android.instance
android.inators << BuAndroidInator.new("1111", "Core", android)
android.inators << BuRemoteShellInator.new("2222", "Remote Shell")
android.connect 'ws://localhost:10969'
