class_name TwitchUtils

const LUMINANCE_LOW := 0.2
const LUMINANCE_HIGH := 0.8

const DEFAULT_NAME_COLORS:Array[String] = [
		"#FF0000", 
		"#00FF00",
		"#0000FF",
		"#B22222",
		"#FF7F50",
		"#9ACD32",
		"#FF4500",
		"#2E8B57",
		"#DAA520",
		"#D2691E",
		"#5F9EA0",
		"#1E90FF",
		"#FF69B4",
		"#8A2BE2",
		"#00FF7F",
		]

static func get_random_name_color(login: String, session_seed:int = 0):
	var position: int = session_seed + hash(login)
	return DEFAULT_NAME_COLORS[position % DEFAULT_NAME_COLORS.size()]


static func normalize_color(color: Color) -> Color:
	var luminance = color.get_luminance()
	if luminance > LUMINANCE_HIGH:
		return color.darkened(0.2)
	if luminance < LUMINANCE_LOW:
		return color.lightened(0.2)
	return color


static func normalize_hex_color(color: String) -> Color:
	return normalize_color(Color(color))
