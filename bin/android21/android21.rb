
require 'json'
require_relative 'lib/android'
require_relative 'lib/inator'
require_relative 'lib/inators/busocket'
require_relative 'lib/inators/buremoteshell'

socket_inator = BuSocket.new 1111
remote_shell = BuRemoteShell.new

Android.instance.inators << socket_inator
Android.instance.inators << remote_shell

socket_inator.connect 'ws://localhost:10969'
