extends Label

export var custom_format_string = ""
export var decimal_digits = 2

func _format_value(value:float) -> String:
	if custom_format_string == "":
		var format = ("%." + str(decimal_digits) + "f") if decimal_digits > 0 else "%d"
		return format % value
	else:
		return custom_format_string % value

func set_value(value:float) -> void:
	text = _format_value(value)
	
func set_quantized_timer_value(time:float, _delta:float) -> void:
	text = _format_value(time)
