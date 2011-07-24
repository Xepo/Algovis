swapinlist = (l, i1, i2) ->
	temp = l[i1]
	l[i1] = l[i2]
	l[i2] = temp
	true
assert = (condition) ->
	return true  if condition
	throw "Assertion failed."
comparearray = (ar1, ar2) ->
	return false  unless ar1.length == ar2.length
	i = 0
	
	while i < ar1.length
		return false  unless ar1[i] == ar2[i]
		i++
	true
window.assert = assert
toline = 0
newcode = ""
genlist_amttogenerate = 50
genlist_maxvalue = 50
coderunnerclass = ->
	canaddsurroundstatements = (line) ->
		canaddafterstatements(line) and line.indexOf("{") == -1 and line.indexOf("}") == -1 and line.search(/return/) == -1 and line.search(/;/) != -1 and line.search(/do/) == -1
	canaddbraces = (line) ->
		canaddsurroundstatements(line) and line.indexOf("var") == -1
	canaddafterstatements = (line) ->
		line.search(/for *\(/) == -1 and (line.search(/\{/) != -1 or line.search(/function/) == -1)
	normalizecode = (code) ->
		braceregex = /(\s|\n)*\{/g
		codestr = code
		codestr = codestr.replace(braceregex, "{")
		ifstmt = /^\s*if[^{]*$/g
		elsestmt = /^\s*else[^{]*$/g
		codestr = "function(sortinglist) {" + code + "; }"
		codestr = eval("(" + codestr + ")")
		codestr = codestr.toString()
		codestr = codestr.replace(braceregex, "{")
		ifmatches = codestr.match(ifstmt)
		elsematches = codestr.match(elsestmt)
		if ifmatches? or elsematches?
			s = ""
			if ifmatches?
				for own i of ifmatches
					s += "\n" + ifmatches[i]
			if elsematches?
				for own i of elsematches
					s += "\n" + elsematches[i]
			alert "If and else statements must have braces around them.\n" + s
			throw "Must have braces around if and else statements!"
		codestr
	@setup = (codeview, speedslider, gobutton, stopbutton, prevbutton, nextbutton, canvas) ->
		@codeview = codeview
		@codeview.linedtextarea()
		@speedslider = speedslider
		@speedslider.slider
			value: 100
			max: 201
			slide: (event, ui) =>
				this.updatespeed()
		
		@gobutton = gobutton
		@gobutton.bind "click", =>
			this.gobuttonclick()
		
		@stopbutton = stopbutton
		@stopbutton.bind "click", =>
			this.stoprun()
		
		@prevbutton = prevbutton
		@prevbutton.bind "click", =>
			this.nextstep -1
		
		@nextbutton = nextbutton
		@nextbutton.bind "click", =>
			this.nextstep 1
		
		@timer = $.timer()
		@canvas = canvas
		@onlypausewhenchanged = true
		if $("#showcoderunner")
			@showcoderunner = $("#showcoderunner")
			@showcoderunner.attr "checked", false
			@showcoderunner.bind "click", =>
				this.updatecodeview()
		else
			@showcoderunner = null
		@testcodedata = $("#testcodedata")  if $("#testcodedata")
		@wasshowingrunner = false
		@stack = []
		@state = "stopped"
		@updatespeed()
		@record = []
		@inputvalue = null
		visualizer.setup canvas
	
	@enablecodeview = (b) ->
		if b
			@codeview.removeAttr "disabled"
			@codeview.removeClass "codeviewdisabled"
		else
			@codeview.attr "disabled", "disabled"
			@codeview.addClass "codeviewdisabled"
	
	@updatecodeview = ->
		if @showcoderunner and @showcoderunner.attr("checked")
			@setcode @codeview.val()  if not @wasshowingrunner and @code != @codeview.val()
			@codeview.val @newcode
			@enablecodeview false
			@wasshowingrunner = true
		else
			@enablecodeview true
			@setcode @codeview.val()  if not @wasshowingrunner and @code != @codeview.val()
			@codeview.val @code
			if @state == "stopped"
				@enablecodeview true
			else
				@enablecodeview false
			@wasshowingrunner = false
		if @state == "playing"
			@gobutton.attr "value", "Pause"
		else if @state == "paused"
			@gobutton.attr "value", "Continue"
		else
			@gobutton.attr "value", "Go"
	
	@updatespeed = ->
		delay = @getdelay()
		return  if @lastdelay == delay
		@lastdelay = delay
		if delay <= -100
			@fastforward = true
		else
			@fastforward = false
		if delay < 0
			@runstep = -delay
		else
			@runstep = 1
		if delay <= 0
			timerdelay = 1
		else
			timerdelay = delay
		@timer.set time: timerdelay
		console.log "Set delay to " + delay + ", timerdelay to " + timerdelay + ", runstep to " + @runstep + ", fastforward: " + @fastforward
	
	@getdelay = ->
		curspeed = @speedslider.slider("value")
		if curspeed > 100
			-(curspeed - 100)
		else if curspeed == 201
			-100
		else
			1000 - Math.sqrt(Math.sqrt(curspeed)) * 312
	
	@getdepth = ->
		i = 0
		c = @getdepth.caller
		while c
			i++
			c = c.caller
	
	@beforeline = (highlightline) ->
		@stack.push highlightline
	
	@afterstmt = (visvalues, highlightline) ->
		@highlightline = highlightline
		needup = visualizer.needupdate(visvalues)
		visualizer.afterstmt visvalues
		throw "coderunner_pause"  unless @state == "playing"
		@updatespeed()
		return false  if @onlypausewhenchanged and not needup
		@ranlines++
		@record.push [ owl.deepCopy(@stack), owl.deepCopy(visvalues) ]  if @ranlines > @record.length
		return false  if @fastforward or @ranlines < @ranlinesmax
		throw "coderunner_pause"
	
	@afterline = (highlightline) ->
		@stack.pop()
	
	@doeval = ->
		_TopCodeRunNext_ = 0
		whoafinished = false
		try
			inputval2 = owl.deepCopy(@inputvalue)
			whoafinished = true  if @newcodef(inputval2) == "finished"
		catch er
			whoafinished = false
			unless er == "coderunner_pause"
				exer = "Got exception: " + er + "\n"
				exer += "\nStack trace: \n"  if @stack.length > 1
				for own v of @stack
					exer += "Line " + v + "\n"
				alert exer
				whoafinished = true
		whoafinished
	
	@nextstep = (amt) ->
		visualizer.nextstep()
		return  if @state != "playing" and @state != "paused"
		unless visualizer.isready()
			@stoprun()
			return
		amt = (if typeof (amt) != "undefined" then amt else @runstep)
		@queueup = @ranlinesmax
		@ranlinesmax = @ranlinesmax + amt
		if @record.length > @ranlinesmax
			@stack = owl.deepCopy(@record[@ranlinesmax][0])
			visualizer.afterstmt owl.deepCopy(@record[@ranlinesmax][1])
			finished = false
		else
			@inputvalue ?= visualizer.generateinput()
			console.log "Using input " + @inputvalue
			jumpto = @ranlinesmax + (@runstep * 10000)
			prevranlinesmax = @ranlinesmax
			@ranlinesmax = jumpto
			console.log "Currently " + prevranlinesmax + ", Recording to " + @ranlinesmax + ", currentl rec'd:" + @record.length
			rlength = @record.length
			@ranlines = 0
			@stack = []
			finished = @doeval()
			@ranlinesmax = prevranlinesmax
			@ranlinesmax = @record.length - 1  if @ranlinesmax >= @record.length
			rec = @record[@ranlinesmax]
			@stack = owl.deepCopy(rec[0])
			visualizer.afterstmt owl.deepCopy(rec[1])
			console.log "Now rec'd: " + @record.length
			console.log "Ranlinesmax:" + @ranlinesmax
			if rlength == @record.length
				finished = true
			else finished = false  if @ranlinesmax < @record.length
		$(".lineselect").removeClass "lineselect"
		$(".linecaller").removeClass "linecaller"
		$("#lineno-" + @highlightline).addClass "lineselect"
		visualizer.render()
		while @stack.length
			lineno = @stack.pop()
			$("#lineno-" + lineno).addClass "linecaller"  unless lineno == @highlightline
		if finished
			console.log "finished"
			@stoprun()
	
	@startrun = ->
		@timer.stop()
		@record = []
		@ranlinesmax = 0
		@ranlines = 0
		@startedtime = (new Date).getTime()
		@unpauserun()
	
	@restartrun = ->
		@stoprun()
		@startrun()
	
	@skiptoendofrun = ->
		@fastforward = true
	
	@gobuttonclick = ->
		if @state == "stopped"
			@inputvalue = null
			@startrun()
		else if @state == "playing"
			@pauserun()
		else @unpauserun()  if @state == "paused"
	
	@unpauserun = ->
		@timer = $.timer(
			action: =>
				this.nextstep()
			
			time: @getdelay()
		)
		@state = "playing"
		@updatecodeview()
		@timer.play()
	
	@pauserun = ->
		@state = "paused"
		@timer.stop()
		@updatecodeview()
	
	@stoprun = ->
		@pauserun()
		@state = "stopped"
		@ranlinesmax = 0
		@stoppedtime = (new Date).getTime()
		console.log "Time of run: " + (@stoppedtime - @startedtime)
		@updatecodeview()
	
	@updatehighlightlines = (code) ->
		lines = code.split("\n")
		i = 0
		while i < lines.length
			lineno = (i + 1).toString()
			if canaddsurroundstatements(lines[i])
				lines[i] = "coderunner.beforeline(%HighlightLine%); " + lines[i] + ";coderunner.afterline(%HighlightLine%);"
				lines[i] = "{" + lines[i] + "}"  if canaddbraces(lines[i])
			lines[i] = lines[i].replace(/%HighlightLine%/g, lineno)
			i++
		newcode = lines.join("\n")
		newcode = newcode.replace(/%VisualizerParameters%/g, visualizer.getvaluesasparameter())
		newcode
	
	@addafterstmts = (code) ->
		lines = code.split("\n")
		i = 0
		while i < lines.length
			lines[i] = lines[i].replace(/;/g, "; coderunner.afterstmt(%VisualizerParameters%, %HighlightLine%);")  if canaddafterstatements(lines[i])
			i++
		lines.join "\n"
	
	@setcode = (code) ->
		@code = code
		code += ";"
		visualizer.setcode code
		@code = normalizecode(code)
		console.log "Normalized code: " + @code
		@codeview.text @code
		@newcode = @code
		@newcode = @addafterstmts(@newcode)
		@newcode = "function(sortinglist) { " + visualizer.getinitstmt() + "cr_newf = " + @newcode + "; cr_newf(sortinglist); return 'finished'; }"
		@newcode = @updatehighlightlines(@newcode)
		@updatecodeview()
		@testcodedata.text @newcode
		@newcodef = eval("(" + @newcode + ")")
	this

coderunner = new coderunnerclass()
window.coderunner = coderunner
