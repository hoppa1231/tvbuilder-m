extends CircuitComponent
class_name D_74485_x12

# ВХОД: 8 бит (LSB -> MSB)
const INPUT_PINS: Array[int] = [5, 4, 3, 2, 1, 19, 18, 17]

# ВЫХОД: три BCD-разряда, каждый 4 пина (LSB -> MSB)
const OUT_UNITS: Array[int] = [6, 7, 8, 9]      # единицы BCD (b0..b3)
const OUT_TENS:  Array[int] = [10, 11, 13, 14]  # десятки BCD
const OUT_HUNDS: Array[int] = [20, 21, 22, 23]  # сотни BCD 

var out_groups: Array = [] # [ [Pin,Pin,Pin,Pin], [..], [..] ]

func _ready():
	out_groups = [
		_pins_from_numbers(OUT_UNITS),
		_pins_from_numbers(OUT_TENS),
		_pins_from_numbers(OUT_HUNDS)
	]

func _process_signal():
	pin(12).set_low()   # GND
	pin(24).set_high()  # VCC

	# enable: ~E1 & ~E2 (оба LOW)
	if pin(16).low and pin(15).low:
		var x: int = _pins_to_int(INPUT_PINS)      # 0..255
		var y: int = clamp(x, 0, 999)
		var bcd_digits: Array[int] = _bin_to_bcd(y)  # [hund,tens,units]

		_write_bcd_digit(out_groups[0], bcd_digits[2]) # units
		_write_bcd_digit(out_groups[1], bcd_digits[1]) # tens
		_write_bcd_digit(out_groups[2], bcd_digits[0]) # hundreds
	else:
		_set_all_outputs_low()

# --------------------

func _pins_from_numbers(nums: Array[int]) -> Array[Pin]:
	var arr: Array[Pin]
	for i in nums: arr.append(pin(nums[i]))
	return arr

func _pins_to_int(number_pins: Array[int]) -> int:
	var result := 0
	for i in range(number_pins.size()):
		result |= (int(pin(number_pins[i]).high) << i)
	return result

func _write_bcd_digit(pins4: Array[Pin], digit: int) -> void:
	var nib := digit & 0xF
	for b in range(4):
		if ((nib >> b) & 1) == 1:
			pins4[b].set_high()
		else:
			pins4[b].set_low()

func _set_all_outputs_low() -> void:
	for group in out_groups:
		for p in group:
			p.set_low()

func _bin_to_bcd(value: int) -> Array[int]:
	var bcd: Array[int] = [0,0,0] # [hund,tens,units]

	for bit_index in range(9, -1, -1):
		# add-3
		for d in range(3):
			if bcd[d] >= 5:
				bcd[d] += 3

		# shift-in
		var carry := (value >> bit_index) & 1
		for d in [2,1,0]:
			var new_carry := (bcd[d] >> 3) & 1
			bcd[d] = ((bcd[d] << 1) & 0xF) | carry
			carry = new_carry

	return bcd
