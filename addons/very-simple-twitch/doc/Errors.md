# Errors
## Information
This page is to explain the use and implementation of errors in VST. Errors have 3 parameters for code, description and extra information.

* error_code (enum @see VST_Error.VST_Code_Error) -> This parameter groups the types of errors in a general way.
* description (String) -> The description of the error is a general description of the general grouping in human language.
* info (String) -> The information is the particular description of the error. It should be used to add extra information about the particular error.

## New errors
To add new errors you must first ask yourself if it is necessary to add a new code or not. If necessary add the code in the VST_Error.VST_Code_Error enumeration.
To illustrate the error let's imagine that we have a function that updates the area of a triangle given a base and a height. This function updates an area parameter only if it is possible to calculate the area (the base or the height is greater than 0).

```GDScript
func calculateArea(base:int, heigth:int):
	if base <= 0:
		var error:VST_Error = VST_Error.new(VST_Error.VST_Code_Error.PARAM_ERROR, "base can't be less than or equals 0")
		push_warning(str(error))
		area = 0
	elif height <= 0:
		var error:VST_Error = VST_Error.new(VST_Error.VST_Code_Error.PARAM_ERROR, "height can't be less than or equals 0")
		push_warning(str(error))
		area = 0
	else
		area = (base*height)/2 
```

## Error Codes

* PARAM_ERROR Use this code for errors that have to do with invalid parameters. An int that should be a String or a String that cannot be empty.
* TIMEOUT_ERROR Use this code when a timer runs out or there is no response from a system.
* NETWORK_ERROR Use this code when there is a network error ( > 400 and < 500)
* SERVER_ERROR Use this code when, in a network communication, the server is down or has a problem ( > 500 ).
