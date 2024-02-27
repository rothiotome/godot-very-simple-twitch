class_name VST_Error

enum VST_Code_Error {PARAM_ERROR, TIMEOUT_ERROR, NETWORK_ERROR, SERVER_ERROR}

var code: VST_Code_Error
var description: String
var info: String

func _init(error_code: VST_Code_Error, error_info: String = ""):
	code = error_code
	info = error_info
	description = _get_description_from_code(error_code)
	
func _get_description_from_code(error_code: VST_Code_Error) -> String:
	var result = ""
	match (error_code):
		VST_Code_Error.PARAM_ERROR:
			result = "The request aren't fullfilled properly. Check the data"
		VST_Code_Error.NETWORK_ERROR:
			result = "The request result in an error"
		VST_Code_Error.SERVER_ERROR:
			result = "There is an error in server"
		VST_Code_Error.TIMEOUT_ERROR:
			result = "The server doesn't response"
		_:
			result = "Unknown error"
	return result

func _to_string():
	return "%s %s %s" % [str(code), description, info]
