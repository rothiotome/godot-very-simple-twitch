# Network
## Information
The motivation for using this wrapper is to facilitate the call APIs and gather responses and errors by the server. The idea is to make it as verbose as possible using a builder pattern so that at first glance the request can be can be readed without much effort.

Before making the network call, the wrapper will check a series of conditions within the method "check_request_data" which will throw a series of errors or warnings in case the request is not not well builded. The wrapper is permissive with the definition of REST APIs. This way you can have a GET call with body or a POST with GET parameters in the url (TBD).

Note: To achieve this effect it is necessary to call new() and pass a node to the "launch_request" method. To the "launch_request" method, which is in charge of putting the node inside the tree and doing its to make all its cycle.

## Usage
To use the wrapper for network requests simply construct a Network_Call object and start configuring it with the to, with, etc... methods.

* to (String) -> url destination
* with (String) -> request body
* add_get_param (String,String) y add_all_get_param(Dictionary) -> add get params to request
* add_header(String,String) y add_all_header(Dictionary) -> add headers to request
* verb(Http_Method) -> set the method for REST request
* in_time(int) -> set the timeout time to the request
* set_on_call_success (Callable) -> call that function if the request was ok (200)
* set_on_call_fail (Callable) -> call that function if the request was fail (>400)
* no_cache -> set no cache for request ( only used in GET requests )

## Example
```GDScript
	func _onReady():
		Network_Call.new().to("https://catfact.ninja/fact").set_on_call_success(on_cat_fact).set_on_call_fail(on_error).launch_request(self)
	
	func on_cat_fact(result):
		$Label.text = str(result)
	
	func on_error(error):
		$Label.text = "Error requesting fact about cats :("
```
## Cache
The network module has a cache for GET requests to save time and bandwidth for similar requests in 'short' time spans.

Because nodes are ephemeral (network requests are nodes that disappear) the cache is stored on disk and not in memory (that resposability was left for the upper layers).

The cache works as follows: 
* 1. The request is hashed ( using the url ) 
* 2. A file with that name ( the hash ) is searched on disk. 
* 3.a If it exists and it has not passed 300 seconds ( arbitrary and improvable time using an etag? ) the request is resolved returning the content of the file. 
* 3.b If the file does not exist or more than 300 seconds that time has elapsed the request is made and cached using the same hash.

The time validity of that cache is on CACHE_TIME_IN_SECONDS constant at network_call.gd

The cached content is an array of bytes due to the heterogeneous nature of the possible requests (text, images, sound...).
