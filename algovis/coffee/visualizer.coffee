genrandomlist = (len, max) ->
	ret = []
	i = 0
	
	while i < len
		randomnumber = Math.floor(Math.random() * (max + 1))
		ret.push randomnumber
		i++
	ret
@highlightcolors = [ "rgb(255,50,50)", "rgb(50,255,50)", "rgb(50,50,255)" ]
class visualizer_bars
	resetsettings: ->
		@visarray = null
		@visindex = []
		@visindexranges = []
		@visextrabars = []

		@visarrayfunc = -> []
		@visindexfunc = []
		@visindexrangesfunc = []
		@visextrabarsfunc = []

	getrendervaluefcn: (expr) ->
		eval("a = function() { with (visualizer.currentrendervalues) { return (#{expr}); } }")

	setsettings: (settings) ->
		@resetsettings()
		commands = settings
		for i of commands
			command = commands[i][0]
			param = commands[i][1]
			if command == "array"
				@visarray = param
				@visarrayfunc = @getrendervaluefcn(param)
			else if command == "index"
				params = param.split(',')
				for i of params
					@visindex.push params[i]
					@visindexfunc.push @getrendervaluefcn(params[i])
			else if command == "indexrange"
				params = param.split(" ")
				irange = Object()
				irange.name = params[0]
				irange.lowrange = params[1]
				irange.highrange = params[2]

				frange = Object()
				frange.lowrange = @getrendervaluefcn(irange.lowrange)
				frange.highrange = @getrendervaluefcn(irange.highrange)
				@visindexranges.push irange
				@visindexrangesfunc.push frange
			else if command == "extrabar"
				params = param.split(" ")
				ibar = Object()
				ibar.name = params[0]
				ibar.value = params[1]
				@visextrabars.push ibar
				@visextrabarsfunc.push @getrendervaluefcn(ibar.value)
		assert @visarray

	setup: (canvas, rect, settings) ->
		@canvas = canvas
		@canvasrect = rect
		@resetsettings
		@setsettings settings
	
	isready: ->
		true
	
	getvars: ->
		retvars = @visarray
		for i of @visindex
			retvars += "," + @visindex[i] + ""
		for i of @visindexranges
			retvars += "," + @visindexranges[i].lowrange + "," + @visindexranges[i].highrange
		for i of @visextrabars
			retvars += "," + @visextrabars[i].value
		vars = retvars.match(/[a-zA-Z][a-zA-Z0-9]*(?!\()/g)
		vars
	
	initvaluesobj: (o) ->
		vars = @getvars()
		for i of vars
			o[vars[i]] = null


	generateinput: ->
		console.log "Generating input"
		genrandomlist 25,25
	
	render: (values) ->
		if values?[@visarray]?.length > 0
			
		else
			console.log "undefinedrender"
			return
		context = @canvas[0].getContext("2d")
		w = @canvas.width()
		h = @canvas.height()


		renarray = values[@visarray]

		renindex = []
		for i of @visindexfunc
			renindex.push @visindexfunc[i]()
		renindexranges = []
		for i of @visindexranges
			renindexranges.push [@visindexranges[i].name, @visindexrangesfunc[i].lowrange(), @visindexrangesfunc[i].highrange()]
		renextrabars = []
		for i of @visextrabars
			renextrabars.push [@visextrabars[i].name, @visextrabarsfunc[i]?()]

		renderer.render_bars context, w, h, renarray, renindex, renindexranges, renextrabars
	
	

class visualizer_graph
	setup: (canvas, rect, settings) ->
		@canvas = canvas
		@canvasrect = rect
		@setsettings settings
	
	isready: ->
		true
	
	
	resetsettings: ->
		@visadjmatrix = null
		@visedge = []
		@visvertex = []
	
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
		@valuesobj = {}
	
	reset: ->
		@valuesobj = {}
		@visualizers[0].initvaluesobj(@valuesobj)
	
	getvars: ->
		vars = @visualizers[0].getvars()
		for i of vars
			@valuesobj[vars[i]] = null
		vars

	generateinput: ->
		@visualizers[0].generateinput()
	
	clearcanvas: ->
		@canvas[0].width = @canvas[0].width
	
	nextstep: ->
		@clearcanvas()
	
	render: (values) ->
		@clearcanvas()
		@currentrendervalues = values
		for i of @visualizers
			@visualizers[i].render(values)
	
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
