
# Examples for HTTP routing library (httprouter)

## Simple HTTP server example

This simple HTTP (**https_server.fnl**) server support several operations:

- Add item (any JSON object which has field **"id"** of integer type)
- Ask all items from server
- Ask items with certain **id**

Server reacts to shutdown of server process by catching the signal and calls
shutdown service of __httprouter__.

Following service paths are provided:

operation | Method | path
--------- | ------ | ----
Add item | POST | /app/item
Ask all items | GET | /app/allitems
Ask items with id | GET | /app/item/:id

Port number for server is assumed to be 8003 in this example.

### Running example

FunL interpreter (__funla__) is needed to run server:
Start server:

```
../funla http_server.fnl
```

Using __curl__ for HTTP client.

Add some items:

```
curl -X POST -d '{"id": 100, "name": "A"}' http://localhost:8003/app/item
curl -X POST -d '{"id": 101, "name": "B"}' http://localhost:8003/app/item
curl -X POST -d '{"id": 100, "name": "C"}' http://localhost:8003/app/item
```

Then ask all items:

```
curl http://localhost:8003/app/allitems
[{"id": 100, "name": "A"}, {"id": 101, "name": "B"}, {"id": 100, "name": "C"}]
```

Ask items for certain id's:

```
curl http://localhost:8003/app/item/100
[{"id": 100, "name": "A"}, {"id": 100, "name": "C"}]

curl http://localhost:8003/app/item/101
[{"id": 101, "name": "B"}]

curl http://localhost:8003/app/item/102
[]
```

Shutdown the server (press CTRL-C etc.):

```
../funla http_server.fnl
signal received: 2interrupt
'http: Server closed'
```


## Simple HTTPS server example

HTTPS example server is similar to HTTP server but it uses HTTPS (TLS) protocol.

Pre-condition: following kind of certificate files need to be generated to working directory:

* 'https-server.crt'
* 'https-server.key'

Use for example following commands:

```
openssl genrsa -out https-server.key 2048
openssl ecparam -genkey -name secp384r1 -out https-server.key
openssl req -new -x509 -sha256 -key https-server.key -out https-server.crt -days 3650
```

See: https://golangcode.com/basic-https-server-with-certificate/

Start server:

```
../funla https_server.fnl
```

Add some items:

```
curl -k -X POST -d '{"id": 100, "name": "A"}' https://localhost:8003/app/item
curl -k -X POST -d '{"id": 101, "name": "B"}' https://localhost:8003/app/item
curl -k -X POST -d '{"id": 100, "name": "C"}' https://localhost:8003/app/item
```

Then ask all items:

```
curl -k https://localhost:8003/app/allitems
[{"id": 100, "name": "A"}, {"id": 101, "name": "B"}, {"id": 100, "name": "C"}]
```

Ask items for certain id's:

```
curl -k https://localhost:8003/app/item/100
[{"id": 100, "name": "A"}, {"id": 100, "name": "C"}]

curl -k https://localhost:8003/app/item/101
[{"id": 101, "name": "B"}]

curl -k https://localhost:8003/app/item/102
[]
```

Shutdown is done in similar way as for HTTP server:

```
../funla https_server.fnl
signal received: 2interrupt
'http: Server closed'
```

