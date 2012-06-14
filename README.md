rain8net
========

The Rain8net device is an RS232 controlled sprinkler controller. The "net" in Rain8net refers to the device's 
ability to be expanded with with several networked modules. This ruby library can be used to control any number 
of Rain8net devices from your ruby app.

More information about the Rain8 series of products can be found at WGL Designs. 

http://www.wgldesigns.com

## Installation
```bash
sudo gem install rain8net
```
or, put this in your Gemfile:
```ruby
gem 'rain8net'
```
## Usage
```ruby
r8 = Rain8net.new(tty: 0)
r8.turn_on_zone(1)
sleep(30) # run for 30 seconds...
puts r8.zone_status(1) # => true
puts r8.zone_status(2) # => false
r8.turn_off_zone(1)
```
## Tips

* Be sure the user running your rails application has R/W access to the serial port. (try: chmod 777 /dev/ttyS0)
* If you have more than 1 module in your setup, be sure to configure the address of each device using the manufacturer's configuration program.
