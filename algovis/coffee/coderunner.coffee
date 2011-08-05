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
@assert = assert
toline = 0
newcode = ""
genlist_amttogenerate = 50
genlist_maxvalue = 50

class coderunner_class
	setup: (@codeview, @speedslider, @gobutton, @stopbutton, @prevbutton, @nextbutton, @canvas) ->
		@showerror()

		@codeview.makeCodeView()

		@speedslider.slider
			value: 100
			max: 201
			slide: (event, ui) =>
				this.updatespeed()
		
		@gobutton.bind "click", =>
			this.gobuttonclick()
		
		@stopbutton.bind "click", =>
			this.stoprun()
		
		@prevbutton.bind "click", =>
			this.nextstep -1
		
		@nextbutton.bind "click", =>
			this.nextstep 1
		
		@timer = $.timer()
		@canvas = canvas
		@onlypausewhenchanged = true
		if $("#showcoderunner")
			@showcoderunner = $("#showcoderunner")
			@showcoderunner.attr "checked", false
			@showcoderunner.bind "click", =>
				@updatecodeview()
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
	
	enablecodeview: (b) ->
		if b
			@codeview.removeAttr "disabled"
			@codeview.removeClass "codeviewdisabled"
		else
			@codeview.attr "disabled", "disabled"
			@codeview.addClass "codeviewdisabled"
	
	updatecodeview: ->
		if @showcoderunner and @showcoderunner.attr("checked")
			@setcode @codeview.val()  if not @wasshowingrunner and @code != @codeview.val()
			@codeview.val @newcode
			@enablecodeview false
			@wasshowingrunner = true
		else
			@enablecodeview true
			console.log "Setting code"
			@setcode @codeview.val()  if not @wasshowingrunner and @code != @codeview.val() and @newcode? and @newcodef?
			@codeview.val @code
			if @state == "stopped"
				@enablecodeview true
			else
				@enablecodeview false
			@wasshowingrunner = false
		if @state == "playing"
			@gobutton.attr "value", "Pause"
			@prevbutton.attr 'disabled', 'disabled'
			@nextbutton.attr 'disabled', 'disabled'
			@stopbutton.removeAttr 'disabled'
		else if @state == "paused"
			@gobutton.attr "value", "Continue"
			@prevbutton.removeAttr 'disabled'
			@nextbutton.removeAttr 'disabled'
			@stopbutton.removeAttr 'disabled'
		else
			@gobutton.attr "value", "Go"
			@prevbutton.attr 'disabled', 'disabled'
			@nextbutton.attr 'disabled', 'disabled'
			@stopbutton.attr 'disabled', 'disabled'
	
	updatespeed: ->
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
	
	getdelay: ->
		curspeed = @speedslider.slider("value")
		if curspeed > 100
			-(curspeed - 100)
		else if curspeed == 201
			-100
		else
			1000 - Math.sqrt(Math.sqrt(curspeed)) * 312
	
	getdepth: ->
		i = 0
		c = @getdepth.caller
		while c
			i++
			c = c.caller
	
	beforeline: (highlightline) ->
		@stack.push highlightline
	
	afterstmt: (visvalues, highlightline) ->
		@highlightline = highlightline
		needup = visualizer.needupdate(visvalues)
		visualizer.afterstmt visvalues
		throw "coderunner_pause"  unless @state == "playing"
		@updatespeed()
		return false  if @onlypausewhenchanged and not needup
		@ranlines++
		@record.push [ owl.deepCopy(@stack), @highlightline, owl.deepCopy(visvalues) ]  if @ranlines > @record.length
		return false  if @fastforward or @ranlines < @ranlinesmax
		throw "coderunner_pause"
	
	afterline: (highlightline) ->
		@stack.pop()
	
	doeval: ->
		_TopCodeRunNext_ = 0
		whoafinished = false
		try
			inputval2 = owl.deepCopy(@inputvalue)
			whoafinished = true  if @newcodef(inputval2) == "finished"
		catch er
			whoafinished = false
			unless er == "coderunner_pause"
				exer = "Exception on line #{@highlightline}: \n#{er}\n"
				exer += "\nStack trace: \n"  if @stack.length > 1
				for own v of @stack
					exer += "\tLine " + v + "\n"
				alert exer
				whoafinished = true
		whoafinished
	
	showerror: (msg) ->
		if msg?
			$('#errorparent').show()
			$('#errorparent').empty()
			$('#errorparent').append "<span class='error'>#{msg}</span>"
		else
			$('#errorparent').empty()
			$('.errorparent').hide()


	nextstep: (amt) ->
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
			@highlightline = @record[@ranlinesmax][1]
			visualizer.afterstmt owl.deepCopy(@record[@ranlinesmax][2])
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
			if rec?
				@stack = owl.deepCopy(rec[0])
				@highlightline = rec[1]
				visualizer.afterstmt owl.deepCopy(rec[2])
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
	
	startrun: ->
		@timer.stop()
		@record = []
		@ranlinesmax = 0
		@ranlines = 0
		@startedtime = (new Date).getTime()
		@unpauserun()
	
	restartrun: ->
		@stoprun()
		@startrun()
	
	skiptoendofrun: ->
		@fastforward = true
	
	#TODO: Count by lines when stepping, count by states when running.
	gobuttonclick: ->
		if @state == "stopped"
			@inputvalue = null
			try
				#TODO: Only call @setcode here, never in @updatecodeview
				@setcode @codeview.val()
				@startrun()
			catch error
				console.log "Couldn't Go"
		else if @state == "playing"
			@pauserun()
		else @unpauserun()  if @state == "paused"
	
	unpauserun: ->
		@timer = $.timer(
			action: =>
				this.nextstep()
			
			time: @getdelay()
		)
		@state = "playing"
		@updatecodeview()
		@timer.play()
	
	pauserun: ->
		@state = "paused"
		@timer.stop()
		@updatecodeview()
	
	stoprun: ->
		@pauserun()
		@state = "stopped"
		@ranlinesmax = 0
		@stoppedtime = (new Date).getTime()
		console.log "Time of run: " + (@stoppedtime - @startedtime)
		@updatecodeview()

	setcode: (@code) ->
		@showerror()
		@newcode = null
		@newcodef = null
		visualizer.setcode @code
		@codeview.val @code

		@testcodedata.text @code
		
		try
			CoffeeScript.compile(@code)
		catch error
			@showerror error
			@stoprun()
			throw error

		console.log @code
		try
			jscode = CoffeeScript.compile(@code, {'hook': 'coderunner.coffee_hook'})
		catch error
			alert "Internal Error!  Contact algovis developer.\n#{error}"
		lineno = -1
		visparam = visualizer.getvaluesasparameter()
		jscode = jscode.replace /coderunner.coffee_hook\(/g, (g0) -> g0 + visparam + ","

		jscode = "function(sortinglist , #{visualizer.getinitstmt()} ) { #{jscode}; return 'finished'; }"

		console.log "deux:" + jscode

		@newcode = jscode

		@updatecodeview()
		@testcodedata.text @newcode
		@newcodef = eval("(" + @newcode + ")")

	coffee_hook: (visvalues, eventtype, lineno, expression) ->
		@lastline = lineno if lineno?
		switch eventtype
			when "beforeexpression"
				@beforeline @lastline
				@highlightline = @lastline
			when "beforestatement"
				@highlightline = @lastline
			when "expression"
				@afterstmt(visvalues, @lastline)
				@afterline @lastline
		expression
@coderunner = new coderunner_class()
