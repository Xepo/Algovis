isArray = (obj) ->
	if obj.constructor.toString().indexOf("Array") == -1
		false
	else
		true
isObject = (obj) ->
	if obj.constructor.toString().indexOf("Object") == -1
		false
	else
		true
genrandomlist = (len, max) ->
	ret = []
	i = 0
	
	while i < len
		randomnumber = Math.floor(Math.random() * (max + 1))
		ret.push randomnumber
		i++
	ret
deepCompare = (obj1, obj2) ->
	return false  unless obj1? == obj2?
	return true  if not obj1?

	isarr1 = isArray(obj1)
	isarr2 = isArray(obj2)
	isobj1 = isObject(obj1)
	isobj2 = isObject(obj2)
	return false  if isarr1 != isarr2
	return false  if isobj1 != isobj2
	if isarr1 and isarr2 and obj1.length != obj2.length
		false
	else if isarr1
		for i of obj1
			return false  unless deepCompare(obj1[i], obj2[i])
		true
	else if isobj1
		for prop of obj1
			if not obj1.hasOwnProperty(prop) and not obj2.hasOwnProperty(prop)
				continue
			else unless obj1.hasOwnProperty(prop) == obj2.hasOwnProperty(prop)
				return false
			else return false  unless deepCompare(obj1[prop], obj2[prop])
		true
	else
		obj1 == obj2
@highlightcolors = [ "rgb(255,50,50)", "rgb(50,255,50)", "rgb(50,50,255)" ]
class visualizer_bars
	reset: ->
		@currentvalues = visarray: []
	
	resetsettings: ->
		@visarray = null
		@visindex = []
		@visindexranges = []
		@visextrabars = []
		@reset()

	setsettings: (settings) ->
		@resetsettings()
		commands = settings
		for i of commands
			command = commands[i][0]
			param = commands[i][1]
			if command == "array"
				@visarray = param
			else if command == "index"
				@visindex = @visindex.concat(param.split(","))
			else if command == "indexrange"
				params = param.split(" ")
				irange = Object()
				irange.name = params[0]
				irange.lowrange = params[1]
				irange.highrange = params[2]
				@visindexranges.push irange
			else if command == "extrabar"
				params = param.split(" ")
				ibar = Object()
				ibar.name = params[0]
				ibar.value = params[1]
				@visextrabars.push ibar
		assert @visarray

	setup: (canvas, rect, settings) ->
		@canvas = canvas
		@canvasrect = rect
		@resetsettings
		@setsettings settings
	
	isready: ->
		true
	
	getinitstmt: ->
		retvars = @visarray
		retvars += "," + @visindex.join(",")
		for i of @visindexranges
			retvars += "," + @visindexranges[i].lowrange + "," + @visindexranges[i].highrange
		for i of @visextrabars
			retvars += "," + @visextrabars[i].value
		retvars += ","
		vars = retvars.match(/[a-zA-Z][a-zA-Z0-9]*(?!\()/g)
		#"var " + vars.join("=null,") + "=null;"
		"" + vars.join(",") + ""
	
	getvaluesasparameter: ->
		param = (expr) -> "((typeof #{expr} === 'undefined' || #{expr} === null) ? null :  (#{expr}))"
		ret = "{'visarray': " + param(@visarray)
		ret += ", 'indexes': [" + [param(ind) for ind in @visindex].join(",") + "]"  if @visindex.length > 0
		if @visindexranges.length > 0
			irange = for j of @visindexranges
				thisrange = @visindexranges[j]
				irange.push "['" + thisrange.name + "'," + param(thisrange.lowrange) + "," + param(thisrange.highrange) + "]"
			ret += ", 'indexranges': [" + irange.join(",") + "]"
		if @visextrabars.length > 0
			ibar = []
			for j of @visextrabars
				thisbar = @visextrabars[j]
				ibar.push "['" + thisbar.name + "'," + param(thisbar.value) + "]"
			ret += ", 'extrabars': [" + ibar.join(",") + "]"
		ret + "}"
	
	generateinput: ->
		console.log "Generating input"
		return genrandomlist 25, 25
	
	needupdate: (values) ->
		return not deepCompare(@currentvalues, values)
	
	afterstmt: (values) ->
		@currentvalues = owl.deepCopy(values)  if values?.visarray?
	
	render: ->
		values = @currentvalues
		if values?.visarray?.length > 0
			
		else
			console.log "undefinedrender"
			return
		context = @canvas[0].getContext("2d")
		w = @canvas.width()
		h = @canvas.height()
		extrabars = values.extrabars ? []
		while extrabars.length < @visextrabars.length
			extrabars.push [ "", -1 ]
		renderer.render_bars context, w, h, values.visarray, values.indexes, values.indexranges, extrabars
	
	

class visualizer_graph
	setup: (canvas, rect, settings) ->
		@canvas = canvas
		@canvasrect = rect
		@setsettings settings
	
	isready: ->
		true
	
	reset: ->
		@currentvalues = visarray: []
	
	resetsettings: ->
		@visadjmatrix = null
		@visedge = []
		@visvertex = []
		@reset()
	
	setsettings: (settings) ->
		@resetsettings()
		commands = settings
		for i of commands
			command = commands[i][0]
			param = commands[i][1]
			if command == "adjmatrix"
				@visadjmatrix = param
			else if command == "highlightedge"
				@visedge = @visedge.concat(param.split("-"))
			else @visvertex = @visvertex.concat(param.split("-"))  if command == "highlightvertex"
		throw "Need vis-adjmatrix!"  if not @visadjmatrix?
		assert @visadjmatrix
	
	getinitstmt: ->
		retvars = @visadjmatrix
		vars = retvars.match(/[a-zA-Z][a-zA-Z0-9]*(?!\()/g)
		"var " + vars.join("=null,") + "=null;"
	
	getvaluesasparameter: ->
		ret = "{'visadjmatrix': " + @visadjmatrix
		ret + "}"
	
	needupdate: (values) ->
		ret = not deepCompare(@currentvalues, values)
		ret
	
	afterstmt: (values) ->
		@currentvalues = owl.deepCopy(values)  if values and values.hasOwnProperty("visadjmatrix") and values.visadjmatrix
	
	generateinput: ->
		console.log "Generating matrix"
		size = 4
		ret = [ [] ]
		line = []
		i = 0
		
		line = [0 for i in [0...size]]
		
		ret = [owl.deepCopy(line) for i in [0...size]]
		i = 0
		
		while i < size * size / 2
			continue  if Math.random() < 0.8
			first = Math.floor(Math.random() * (size))
			second = Math.floor(Math.random() * (size))
			continue  if first == second
			ret[first][second] = 1
			i++
		@positions = []
		ret
	
	render: ->
		values = @currentvalues
		if values?['visadjmatrix']?.length? > 0
			
		else
			console.log "undefinedrender"
			return
		context = @canvas[0].getContext("2d")
		w = @canvas.width()
		h = @canvas.height()
		@positions = renderer.render_graph(context, w, h, @positions, values.visadjmatrix)

class visualizer_class
	setup: (canvas) ->
		@canvas = canvas
		@resetcode()
	
	getinitstmt: ->
		initstmts = []
		for i of @visualizers
			initstmts.push @visualizers[i].getinitstmt()
		initstmts.join ";"
	
	getvaluesasparameter: ->
		valparams = []
		for i of @visualizers
			valparams.push @visualizers[i].getvaluesasparameter()
		"[" + valparams.join(",") + "]"
	
	generateinput: ->
		@visualizers[0].generateinput()
	
	clearcanvas: ->
		@canvas[0].width = @canvas[0].width
	
	nextstep: ->
		@clearcanvas()
	
	needupdate: (values) ->
		for i of @visualizers
			return true  if @visualizers[i].needupdate(values[i])
		false
	
	afterstmt: (values) ->
		for i of @visualizers
			@visualizers[i].afterstmt values[i]
	
	render: ->
		@clearcanvas()
		for i of @visualizers
			@visualizers[i].render()
	
	findcommands: (code) ->
		mycode = code
		visreg = /!vis-([a-zA-Z0-9]+): *([^;]*);/g
		matches = code.match(visreg)
		visreg = /!vis-([a-zA-Z0-9]+): *([^;]*);/i
		console.log "matches:" + matches
		commands = []
		for i of matches
			match = matches[i].match(visreg)
			commands.push [ match[1], match[2] ]
		console.log commands
		commands
	
	reset: ->
		for i of @visualizers
			@visualizers[i].reset()
	
	resetcode: ->
		@visualizers = []
	
	createvis: (vistype, viscommands) ->
		if vistype == "bar"
			newvis = new visualizer_bars()
			newvis.setup @canvas, [], viscommands
			@visualizers.push newvis
		else if vistype == "graph"
			newvis = new visualizer_graph()
			newvis.setup @canvas, [], viscommands
			@visualizers.push newvis
		else
			throw "No such vistype:" + vistype
	
	isready: ->
		return false unless @visualizers.length > 0
		for v of @visualizers
			return false  unless @visualizers[v].isready()
		return true
	
	setcode: (code) ->
		console.log "vis: Setting code"
		@resetcode()
		commands = @findcommands(code)
		curvis = null
		curcoms = []
		for i of commands
			command = commands[i][0]
			param = commands[i][1]
			if command == "type"
				if curvis?
					@createvis curvis, curcoms
					curvis = null
					curcoms = []
				curvis = param
			else
				throw "Must set vis-type before anything else!"  unless curvis?
				curcoms.push commands[i]
		@createvis curvis, curcoms  if curvis?

@visualizer = new visualizer_class()
