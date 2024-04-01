@tool
class_name Network_Call extends Node

const CACHE_TIME_IN_SECONDS = 300

# TODO: add dynamic version here
const USER_AGENT = {"User-Agent": "VSTC/0.1.0 (Godot Engine)"}

const CACHE_PATH = "user://very-simple-chat/cache"

var url: String
var timeout: float
var body: String
var headers: Dictionary
var get_params: Dictionary
var on_call_success: Callable
var on_call_fail: Callable
var method: HTTPClient.Method
var use_cache: bool


func _init():
	headers = {}
	get_params = {}
	timeout = 0.0
	use_cache = true


func to(url_request: String) -> Network_Call:
	url = url_request
	return self


func with(body_object) -> Network_Call:
	body = JSON.stringify(body_object)
	return self


func in_time(timeout_request: float) -> Network_Call:
	timeout = timeout_request
	return self


func verb(method_request: HTTPClient.Method) -> Network_Call:
	method = method_request
	return self


func no_cache() -> Network_Call:
	use_cache = false
	return self


func add_header(key_header: String, value_header: String) -> Network_Call:
	headers[key_header] = value_header
	return self


func add_all_headers(headers_dic: Dictionary) -> Network_Call:
	for key in headers_dic:
		headers[key] = headers_dic[key]
	return self


func add_get_param(key_get_param:String, value_get_param) -> Network_Call:
	get_params[key_get_param] = str(value_get_param)
	return self


func add_all_get_params(get_params_dic: Dictionary) -> Network_Call:
	for key in get_params_dic:
		get_params[key] = get_params_dic[key]
	return self


func set_on_call_success(on_call_success_request: Callable) -> Network_Call:
	on_call_success = on_call_success_request
	return self


func set_on_call_fail(on_call_fail_request: Callable) -> Network_Call:
	on_call_fail = on_call_fail_request
	return self


func _pile_headers(headers_to_pile: Dictionary) -> PackedStringArray:
	var array:PackedStringArray = []
	for key in headers_to_pile:
		array.append("%s: %s" % [key, headers_to_pile[key]])
	for key in USER_AGENT:
		array.append("%s: %s" % [key, USER_AGENT[key]])
	return array


func _compile_url(host: String, params_to_pile: Dictionary) -> String:
	var final_url:String = host.strip_edges()+"?"
	for key in params_to_pile:
		var value_safe = str(params_to_pile[key]).uri_encode()
		var key_safe = str(key).uri_encode()
		final_url += "&%s=%s" % [key_safe, value_safe]
	return final_url


func launch_request(parent: Node):
	if method == HTTPClient.Method.METHOD_GET:
		var final_url = _compile_url(url, get_params)
		if use_cache:
			var cached_data = read_from_cache(get_key_from_url(final_url))
			if !cached_data.is_empty() && on_call_success != null:
				on_call_success.call(cached_data)
				return
	_launch_network_request(parent)


func _launch_network_request(parent: Node):
	var data_error = check_request_data()
	if data_error != "":
		var error:VSTError = VSTError.new(VSTError.VSTCodeError.PARAM_ERROR, data_error)
		on_call_fail.call(error)
		return

	parent.add_child(self)
	await get_tree().process_frame

	var final_url = _compile_url(url, get_params)
	var client = HTTPRequest.new()
	client.timeout = timeout
	client.request_completed.connect(on_request_completed.bind(final_url))

	add_child(client)
	await get_tree().process_frame

	var request_error = client.request(final_url, _pile_headers(headers), method, body)
	if request_error != OK:
		var error:VSTError = VSTError.new(VSTError.VSTCodeError.PARAM_ERROR, "The request can't be archieved reason: "+str(request_error))
		on_call_fail.call(error)
		return


func check_request_data() -> String:
	if timeout < 0.0:
		push_warning("Timeout can't be less than 0. Setted to 0")
		timeout = 0

	if !method:
		method = HTTPClient.Method.METHOD_GET

	if url == null or url.strip_edges() == "":
		return "Url can't be empty"
	return ""


func get_key_from_url(url:String) -> String:
	var last_part_url:String = url.substr(url.rfind("/"))
	return last_part_url.sha256_text()


func on_request_completed(_result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, url_request: String):
	if (status >= 200 and status < 400):
		if method == HTTPClient.Method.METHOD_GET: update_cache(body, get_key_from_url(url_request))
		if on_call_success: on_call_success.call(body)
	elif (status >= 400 and status < 500):
		if on_call_fail:
			var info = "%s -> %s" % [str(status), body.get_string_from_utf8()]
			var error:VSTError = VSTError.new(VSTError.VSTCodeError.NETWORK_ERROR, info)
			on_call_fail.call(error)
	elif (status >= 500):
		if on_call_fail:
			var info = "%s -> %s" % [str(status), body.get_string_from_utf8()]
			var error:VSTError = VSTError.new(VSTError.VSTCodeError.SERVER_ERROR, info)
			on_call_fail.call(error)
	call_deferred("queue_free")

func read_from_cache(key:String) -> PackedByteArray:
	var filename: String = CACHE_PATH.path_join(key)
	if FileAccess.file_exists(filename): # is a hit on cache?
		if FileAccess.get_modified_time(filename)+CACHE_TIME_IN_SECONDS > Time.get_unix_time_from_system(): # is expired?
			return FileAccess.get_file_as_bytes(filename)
	return []


func update_cache(content:PackedByteArray, key:String):
	var filename: String = CACHE_PATH.path_join(key)
	DirAccess.make_dir_recursive_absolute(filename.get_base_dir())
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_buffer(content)
	file.close()


func clear_cache():
	DirAccess.make_dir_recursive_absolute(CACHE_PATH)
	var files:PackedStringArray = DirAccess.get_files_at(CACHE_PATH)
	for file in files:
		DirAccess.remove_absolute(CACHE_PATH.path_join(file))
