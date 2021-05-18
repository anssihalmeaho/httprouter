# httprouter
HTTP routing library for FunL

There is standard library **stdhttp** for HTTP server (and client) implementation
in [FunL](https://github.com/anssihalmeaho/funl) but it's not so easy to
define routing information in it (HTTP method and service path to handler mapping).

**httprouter** provides means to:

* define routing information in declarative manner
* get parts of path as named parameters, like `/item/:id` and `/item/123` => `map('id' '123')`

## Services

### new-router

Creates new router instance.

```
call(httprouter.new-router <map: router-info>) -> map: provided services
```

Router info map is given as argument, it contains:

Key | Value
--- | -----
'addr' | address to listen (string)
'routes' | routes information (map)
'cert-file' | certificate file name (string), only with HTTPS/TLS
'key-file' | key file name (string), only with HTTPS/TLS

Routes information contains method names and path (as list) mapping to handlers (__proc__):

For example:

```
map(
	'GET' list(
			list(
				list('app' 'item' ':id')
				my-handler
			)

			list(
				list('app' 'allitems')
				my-handler
			)
		)
)
```

In this example routes would match with following kind of requests:

* GET /app/item/123
* GET /app/allitems

**Note**. last trailing backslash is eaten away if given.

Handler is procedure of type:

```
proc(<opaque:http-response-writer> <request-map> <parameters-map>) -> <value>
```

Return value of handler does not matter.

First and second arguments are same as handler registered with **stdhttp.reg-handler**.

Third value is map which contains named parameter values which are parsed from request path.
Named parameter in route is recognized so that it starts with **':'**.

### Services in map

Map returned from **httprouter.new-router** contains router services (procedures) by name (string):

Name | Service
---- | -------
'listen' | listens and serves HTTP requests
'listen-tls' | listens and serves HTTPS/TLS requests
'shutdown' | gracefully shuts down router

## Get started
Prerequisite is to have [FunL interpreter](https://github.com/anssihalmeaho/funl) compiled.
Clone httprouter from Github:

```
git clone https://github.com/anssihalmeaho/httprouter.git
```

Put **httprouter.fnl** to some directory which can be found under **FUNLPATH** or in working directory.

See more information: https://github.com/anssihalmeaho/funl/wiki/Importing-modules

## Example codes

See example HTTP/HTTPS servers using httprouter: https://github.com/anssihalmeaho/httprouter/tree/main/examples

