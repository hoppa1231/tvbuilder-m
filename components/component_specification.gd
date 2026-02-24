extends RefCounted
class_name ComponentSpecification

var name: String = ""
var num_pins: int = 0
var height: float = 0.0
var width: float = 0.0
var textures: Dictionary = {}
var pinSpecifications: Array = []
var details: Dictionary = {}
var content: String = ""

func initialize(name:String, num_pins:int, height:float, width:float, textures:Dictionary, pinSpecifications:Array, details:Dictionary)->void:
	self.name = name
	self.num_pins = num_pins
	self.width = width
	self.height = height
	self.textures = textures
	self.pinSpecifications = pinSpecifications
	self.details = details

func initialize_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ).get_as_text()
	var parsed = JSON.parse_string(file)
	
	if parsed == null:
		InfoManager.write_error("Ошибка распознавания спецификации компонента: %s" % [path])
		return
	
	if("content" in parsed):
		self.content = parsed
	self.num_pins = parsed.num_pins
	self.width = parsed.width
	self.height = parsed.height
	#self.texture = parsed.texture
	self.name = parsed.name
	self.pinSpecifications = Array()
	self.details = parsed.get("details", {})
	
	var textures =  parsed.textures
	for t in textures:
		self.textures[t.name] = t.path
		
	var pins = parsed.pinSpecifications
	for pin in pins:
		var spec = PinSpecification.new()
		spec.initialize(pin.index, NetConstants.parse_direction(pin.direction), pin.position, pin.readable_name, pin.description, pin.dependencies)
		self.pinSpecifications.append(spec)
		
func set_details(details: Dictionary) -> void:
	self.details = details
