# Rain8net library for Ruby.
#
# Author: Adam Anderson (adam@makeascene.com)
#
# NOTE: You must install ruby-serialport in order to use this library.
# As of this writing, it is not available as a gem, but can be downloaded
# here:
# https://github.com/hparra/ruby-serialport
#
# Rain8net is an RS232 controlled sprinkler controller. The "net"
# in Rain8net refers to the device's ability to be expanded with
# several networked modules. This class can be used to control 
# one device or a whole network of devices.
#
# Usage:
#
#  require 'rain8net'
#  r8 = Rain8net.new
#  r8.turn_on_zone(1)
#  sleep(30) # run for 30 seconds...
#  puts r8.zone_status(1) # => true
#  puts r8.zone_status(2) # => false
#  r8.turn_off_zone(1)
#
# More information about the Rain8 series of products can be found on
# the manufacturer's website at:
# http://www.wgldesigns.com
#
# Copyright (c) 2008 Make A Scene Media, Inc. All Rights Reserved.
# Licensed under GPL
#
Kernel::require "serialport" # Kernel::require works better for serialport.
class Rain8net
  attr_reader :sp, :addresses, :tty
  
  # Create a new object. Options include:
  # TTY port (COM port) number on the machine connected to the
  # RS232 port of the first module in the network. 
  #   :tty => 0 
  #
  # Address of the Rain8net devices. These are the addresses
  # of the modules in the Rain8 network. The manufacturer default
  # for each module is "01". Configure the address using the 
  # manufacturer's configuration program before hooking it up
  # to your Rain8 network.
  #   :addresses => ['01', '45', '02']
  # Make sure your addresses are entered in the order they have
  # been built into your Rain8net system. The zones numbers are
  # determined based on the order they are entered in the 
  # addresses array. (See Rain8net#module_address_for_zone)
  #
  # Example:
  #   r8 = Rain8net.new(:tty => 0, :addresses=>['01'])
  # Note: values above are the defaults. So, the above is equivilant to:
  #   r8 = Rain8net.new
  #
  def initialize(options={})
    default_options = {:tty => 0, :addresses => ["01"]}
    options = default_options.merge(options)
    @tty = options[:tty]
    @addresses = options[:addresses]
    @sp = SerialPort.new(@tty, 4800, 8, 1, SerialPort::NONE)
  end

  # Turn on an individual zone:
  #   r8.turn_on_zone(1)
  #
  def turn_on_zone(zone=1)
    send_code("40#{module_address_for_zone(zone)}3#{zone}")
  end
  
  # Turn off an individual zone:
  #   r8.turn_off_zone(1)
  #
  def turn_off_zone(zone=1)
    send_code("40#{module_address_for_zone(zone)}4#{zone}")
  end
  
  # Turn off all zones for the entire system.
  #   r8.turn_all_off
  #
  def turn_all_off
    send_code("205555")
  end
  
  # Alias for Rain8net#turn_all_off
  #
  def all_off
    turn_all_off
  end
  
  # Read all settings from a given module. Returns
  # the raw hex response from the module.
  #   settings = r8.read_settings
  #   settings.to_s
  #   => (a whole bunch of hex info)
  #
  # TODO: Interpret the settings and format them into
  # something usable.
  def read_settings
    send_code("232323")
    response
  end
  
  # Get the status of the given zone. Returns true if
  # a zone is running, false if it is not.
  #   r8.zone_status(1)
  #   => true
  #
  def zone_status(zone=1)
    zone = zone.to_i
    send_code("40#{module_address_for_zone(zone)}F0")
    # Response includes a status of each of the 8 zones for the module.
    r = response.reverse.unpack("B*").to_s.match(/(^.{8})/).to_s.split(//).reverse
    position = (zone - (((zone - 1) / 8).to_i * 8) - 1).to_i
    (r[position].to_i == 1) ? true : false
  end
  
  # Determines which address from the @addresses attribute is hooked
  # up to a given zone. Note, there is no fancy way to figure out
  # out what your hardware connections actually are. This method uses
  # the convention that your FIRST 8 zones are connected to the FIRST 
  # address in the @addresses array. Zones 9-16 are connected to the 
  # next address in the array and so on.
  #   r8.module_address_for_zone(5)
  #   => "01"
  #
  def module_address_for_zone(zone=1)
    module_position = ((zone.to_f - 0.01) / 8).to_i
    begin
      @addresses[module_position]
    rescue
      raise "No module found for zone #{zone}"
    end
  end
  
  # Sends the given code to the Rain8net module.
  #   r8.send_code("205555")
  #
  def send_code(code)
    sp.write([code].pack("H*"))
  end

  # After sending a code that expects a response, call this
  # function to receive the response from the Rain8net module
  #   r8.response
  #   => "@\001"
  def response
    sleep(1)
    sp.read
  end

end
