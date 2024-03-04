class_name VSTError

enum VSTCodeError {PARAM_ERROR, TIMEOUT_ERROR, NETWORK_ERROR, SERVER_ERROR}

var code: VSTCodeError
var description: String
var info: String

func _init(error_code: VSTCodeError, error_info: String = ""):
	code = error_code
	info = error_info
	description = _get_description_from_code(error_code)


func _get_description_from_code(error_code: VSTCodeError) -> String:
	var result = ""
	match (error_code):
		VSTCodeError.PARAM_ERROR:
			result = "The request aren't fullfilled properly. Check the data"
		VSTCodeError.NETWORK_ERROR:
			result = "The request result in an error"
		VSTCodeError.SERVER_ERROR:
			result = "There is an error in server"
		VSTCodeError.TIMEOUT_ERROR:
			result = "The server doesn't response"
		_:
			result = "Unknown error"
	return result


func _to_string():
	return "%s %s %s" % [str(code), description, info]
