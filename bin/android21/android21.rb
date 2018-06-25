
gems = ['json']
libs = [
          'lib/android',
          'lib/inator',
          'lib/inators/busocket',
          'lib/inators/buremoteshell'
        ]

gems.each { |gem| require gem }
libs.each { |lib| require_relative lib }

android = Android.instance

android.inators << BuSocket.new
android.inators << BuRemoteShell.new

android.connect 'ws://localhost:10969'
