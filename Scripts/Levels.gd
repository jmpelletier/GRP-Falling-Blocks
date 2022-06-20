extends Node

signal levelup(new_level)
signal update_line_count(new_count)
signal set_gravity(lines_per_second)

const BlockGravity = preload("res://Scripts/BlockGravity.gd")

class LevelDefinition:
	var gravity = 1.0
	var lines_to_clear = 10
	var time_to_lockdown = 0.5
	
	func _init(grav, lines = 10, lockdown = 0.5):
		self.gravity = grav
		self.lines_to_clear = lines
		self.time_to_lockdown = lockdown
		
var levels = [
	LevelDefinition.new(1),
	LevelDefinition.new(1.2),
	LevelDefinition.new(1.6),
	LevelDefinition.new(2),
	LevelDefinition.new(2.8),
	LevelDefinition.new(3.8),
	LevelDefinition.new(5.2),
	LevelDefinition.new(7.4),
	LevelDefinition.new(10.6),
	LevelDefinition.new(15.6),
	LevelDefinition.new(23.2),
	LevelDefinition.new(35.4),
	LevelDefinition.new(55),
	LevelDefinition.new(87.4),
	LevelDefinition.new(141.7),
	LevelDefinition.new(234.5),
	LevelDefinition.new(396.8),
	LevelDefinition.new(686.3),
	LevelDefinition.new(1213.7)
]

export var level = 0
export var lines_cleared = 0

var block_gravity = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for n in get_parent().get_children():
		if n is BlockGravity:
			block_gravity = n
			break
	if block_gravity == null:
		push_error("Levels does not have a BlockGravity sibling.")
	else:
		block_gravity.lines_per_second = get_gravity()
		
	_set_level(level)
	_set_line_count(lines_cleared)
	_set_gravity(get_gravity())

func get_next_level_lines(current_level:int) -> int:
	current_level = int(clamp(current_level, 0, levels.size() - 1))
	var total = 0
	for i in range(current_level + 1):
		total += levels[i].lines_to_clear
	return total
	
func get_gravity() -> float:
	var i = int(clamp(level, 0, levels.size()))
	return levels[i].gravity
	
func _set_level(new_level):
	level = new_level
	Logger.log_event("levelup", String(level + 1))
	emit_signal("levelup", level + 1)
	
func _set_line_count(new_count):
	lines_cleared = new_count
	Logger.log_event("lines_total", String(new_count))
	emit_signal("update_line_count", lines_cleared)
	
func _set_gravity(new_gravity):
	Logger.log_event("set_gravity", String(new_gravity))
	emit_signal("set_gravity", new_gravity)
	
func on_lines_cleared(count:int):
	_set_line_count(lines_cleared + count)
	var target = get_next_level_lines(level)
	while lines_cleared >= target:
		_set_level(level + 1)
		target = get_next_level_lines(level)
	
	_set_gravity(get_gravity())
#	if block_gravity != null:
#		block_gravity.lines_per_second = get_gravity()
