
ns main

import stdhttp
import stdvar
import stdjson
import stdbytes

create-get-item-with-id = func(items)
	proc(w r params)
		import stdfu

		selected-id = conv(get(params ':id') 'int')
		matched-items = call(stdfu.filter call(stdvar.value items) func(item) eq(get(item 'id') selected-id) end)
		_ = call(stdhttp.add-response-header w map('Content-Type' 'application/json'))
		_ _ response = call(stdjson.encode matched-items):
		call(stdhttp.write-response w 200 response)
	end
end

create-get-all-items = func(items)
	proc(w r)
		all-items = call(stdvar.value items)
		_ = call(stdhttp.add-response-header w map('Content-Type' 'application/json'))
		_ _ response = call(stdjson.encode all-items):
		call(stdhttp.write-response w 200 response)
	end
end

create-add-item = func(items)
	proc(w r params)
		_ _ item = call(stdjson.decode get(r 'body')):
		has-id idvalue = getl(item 'id'):

		updator = func(prev-items)
			if( has-id
				append(prev-items item)
				prev-items
			)
		end

		call(stdvar.change items updator)
	end
end

main = proc()
	import httprouter

	items = call(stdvar.new list())

	routes = map(
		'GET' list(

				list(
					list('app' 'item' ':id')
					call(create-get-item-with-id items)
				)

				list(
					list('app' 'allitems')
					call(create-get-all-items items)
				)
			)

		'POST' list(
				list(
					list('app' 'item')
					call(create-add-item items)
				)
			)
	)

	router-info = map(
		'addr'      ':8003'
		'routes'    routes
		'cert-file' 'https-server.crt'
		'key-file'  'https-server.key'
	)

	# create new router instance
	router = call(httprouter.new-router router-info)

	# get router procedures
	listen = get(router 'listen-tls')
	shutdown = get(router 'shutdown')

	# signal handler for doing router shutdown
	import stdos
	sig-handler = proc(signum sigtext)
		_ = print('signal received: ' signum sigtext)
		call(shutdown)
	end
	_ = call(stdos.reg-signal-handler sig-handler 2)

	# wait and serve requests (until shutdown is made)
	call(listen)
end

endns

