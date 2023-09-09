
ns main

import stdhttp
import stdvar
import stdjson
import stdbytes

create-get-item-with-id = func(items)
	proc(w r params)
		import stdfu

		selected-id = conv(get(params ':id') 'int')
		matched-items = call(stdfu.filter
			call(stdvar.value items)
			func(item) eq(get(item 'id') selected-id) end
		)
		_ _ response = call(stdjson.encode matched-items):

		map(
			'status' 200
			'header' map('Content-Type' 'application/json')
			'body'   response
		)
	end
end

create-get-all-items = func(items)
	proc(w r)
		all-items = call(stdvar.value items)
		_ _ response = call(stdjson.encode all-items):

		map(
			'header' map('Content-Type' 'application/json')
			'body'   response
		)
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
		_ = call(stdvar.change items updator)
		map('status' 201)
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

	my-error-logger = proc()
		import stdlog

		options = map(
			'prefix'       'my-HTTP-logger: '
			'separator'    ' : '
			'date'         true
			'time'         true
			'microseconds' true
			'UTC'          true
		)
		log = call(stdlog.get-default-logger options)
		proc(error-text)
			call(log error-text)
		end
	end

	router-info = map(
		'addr'         ':8003'
		'routes'       routes
		'error-logger' call(my-error-logger)
	)

	# create new router instance
	router = call(httprouter.new-router-v2 router-info)

	# get router procedures
	listen = get(router 'listen')
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

