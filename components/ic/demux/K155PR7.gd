extends CircuitComponent
class_name K155PR7
var res_pins_1: Array[Pin]
var res_pins_2: Array[Pin]
var int_pins: int
var res_1: int
var res_2: int

func _ready():
	res_pins_1 = [pin(1),pin(2),pin(3),pin(4)]
	res_pins_2 = [pin(5),pin(6)]

func _process_signal():
	pin(8).set_low()     # GND
	pin(16).set_high()   # VCC
	
	pin(7).set_low()    # Q6
	pin(9).set_low()    # Q7
	
	if (pin(15).low):   # ~RE
		# Get integer input
		int_pins = (
			(pin(10).high as int) | ((pin(11).high as int)<<1) | ((pin(12).high as int)<<2) | ((pin(13).high as int)<<3) | ((pin(14).high as int)<<4)
		)
		
		res_1 = floor(int_pins%10) as int
		@warning_ignore("integer_division")
		res_2 = floor(int_pins/10%10) as int
		
		for _pin in res_pins_1:
			@warning_ignore("int_as_enum_without_cast")
			_pin.state = res_1 & 1
			res_1 = res_1>>1
		for _pin in res_pins_2:
			@warning_ignore("int_as_enum_without_cast")
			_pin.state = res_2 & 1
			res_2 = res_2>>1
		
		
		
