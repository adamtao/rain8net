#:nodoc: all
require "helper"
class TestRain8net < Test::Unit::TestCase
  
  def initialize(options)
    super(options)
  end
  
  def setup
    # Sets up a 2-module Rain8net system with 16 zones.
    @r8 = Rain8net.new(:tty => 0, :addresses=>['01', '02'])
  end
  
  def test_constructor
    assert_instance_of(Rain8net, @r8, message = "@r8 should be an instance of Rain8net")
  end
  
  def test_zone_assignments
    assert_equal('01', @r8.module_address_for_zone(4), message = "Zone 4 should be associated with module at address '01'")
    assert_equal('02', @r8.module_address_for_zone(10), message = "Zone 10 should be associated with module at address '02'")
  end
  
  def test_turning_on_first_zone
    res = @r8.turn_on_zone 1
    assert_not_nil(res, message = "Should get something back when turning on a zone.")
  end

end