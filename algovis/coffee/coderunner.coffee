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
			@displaynext -1
		
		@nextbutton.bind "click", =>
			@displaynext 1
		
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
		@clearrecord()
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
	
	doeval: ->
		_TopCodeRunNext_ = 0
		whoafinished = false
		try
			inputval2 = owl.deepCopy(@inputvalue)
			whoafinished = true  if @newcodef(inputval2) == "finished"
		catch er
			whoafinished = false
			unless er == "coderunner_interrupt"
				exer = "Exception on line #{@highlightline}: <br/><code style='padding-left:1em;'>#{er}</code><br/>"
				exer += "\nStack trace: <br/>"  if @stack.length > 1
				exer += "<code style='display:block; padding-left: 1em;'>"
				for v in @stack
					exer += "Line " + v + "<br/>\n"
				exer += "</code>"
				@showerror exer
				whoafinished = true
		whoafinished
	
	showerror: (msg) ->
		if msg?
			$('#errorparent').show()
			$('#errorparent').empty()
			$('#errorparent').append "<div class='error'>#{msg}</div>"
		else
			console.log $('#errorparent')
			$('#errorparent').empty()
			$('#errorparent').hide()


	checksetup: ->
		if @inputvalue?
			return
		@clearrecord()
		@inputvalue = visualizer.generateinput()
		console.log "Using input " + @inputvalue

	clearrecord: ->
		@record = []
		@changestoticks = []
		@recordedall = false

	nexttick: (visvalues) ->
		needup = false
		@ranticks++

		if visvalues?
			needup = visualizer.needupdate(visvalues)

			if needup
				visualizer.update visvalues
				@ranchanges++
				if @ranchanges >= @changestoticks.length
					@changestoticks.push @ranticks

		if @ranticks >= @record.length
			if visvalues?
				@record.push [ owl.deepCopy(@stack), @highlightline, owl.deepCopy(visvalues) ]
			else
				@record.push [ owl.deepCopy(@stack), @highlightline, {} ]

		if @state != "playing" or @interruptattick? and @ranticks >= @interruptattick or @interruptatchange? and @ranchanges >= @interruptatchange
			throw "coderunner_interrupt" unless @fastforward

		@updatespeed()

	fetchnewrecords: (@interruptattick, @interruptatchange) ->
		#Make sure we fetch a decent bit at one time
		if @recordedall
			return
		if @interruptattick - @record.length < 200
			@interruptattick = @record.length + 200
		if @interruptatchange - @changestoticks.length < 50
			@interruptatchange = @changestoticks.length + 50

		console.log "Evaling for new records"
		@stack = []
		@ranticks=0
		@ranchanges=0
		@recordedall = false
		@recordedall = @doeval()

	refreshlinesdisplay: ->
		$(".lineselect").removeClass "lineselect"
		$(".linecaller").removeClass "linecaller"
		$("#lineno-" + @highlightline).addClass "lineselect"
		visualizer.render()
		while @stack.length
			lineno = @stack.pop()
			$("#lineno-" + lineno).addClass "linecaller"  unless lineno == @highlightline

	display: (attick, atchange) ->
		#visualizer.nextstep()
		if not visualizer.isready()
			@stoprun()
			return

		retchange = null
		alreadyhaverecord = attick? and attick < @record.length or atchange? and atchange < @changestoticks.length and (not attick? or @changestoticks[atchange] < attick?)

		if not alreadyhaverecord
			@fetchnewrecords attick, atchange

		if atchange? and @changestoticks.length > atchange
			changetick = @changestoticks[atchange]
			attick ?= changetick
			if changetick < attick
				console.log "Choosing change #{atchange} at #{changetick}"
				attick = changetick
				retchange = atchange

		if attick >= @record.length
			attick = @record.length - 1
		else if attick < 0
			attick = 0


		@stack = owl.deepCopy(@record[attick][0])
		@highlightline = @record[attick][1]
		visualizer.update owl.deepCopy(@record[attick][2])

		visualizer.render()
		@refreshlinesdisplay()

		return [attick, atchange]

	displaynext: (amtticks=null, amtchanges=@runstep) ->
		return  if @state != "playing" and @state != "paused"
		amtticks?=amtchanges*17

		@checksetup()

		shown = @display @showingtick+amtticks, @showingchange+amtchanges

		advancedticks = (shown?[0] ? @showingtick) - @showingtick
		advancedchanges = (shown?[1] ? @showingchange) - @showingchange

		if amtticks > 0 and advancedticks == 0
			console.log "Didn't advance, stopping run at tick #{@showingtick}"
			@stoprun()

		@showingtick += advancedticks
		@showingchange += advancedchanges

		if @recordedall and @showingtick >= @record.length
			console.log "finished"
			@stoprun()
	
	startrun: ->
		@timer.stop()

		@clearrecord()

		@showingtick = 0
		@showingchange = 0

		@startedtime = @getTimestamp()
		@unpauserun()
	
	restartrun: ->
		@stoprun()
		@startrun()
	
	skiptoendofrun: ->
		@fastforward = true
	
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
		else @unpauserun()	if @state == "paused"
	
	unpauserun: ->
		act = =>
			@displaynext()
		@timer = $.timer(
			action: act
			
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
		@interruptattick = 0
		@interruptatchange = 0
		@changestoticks = {}
		@stoppedtime = (new Date).getTime()
		console.log "Time of run: " + (@stoppedtime - @startedtime)
		@updatecodeview()

	setcode: (@code) ->
		@showerror()
		@newcode = null
		@newcodef = null
		@clearrecord()
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
		visparam = visualizer.getvaluesasparameter()
		jscode = jscode.replace /coderunner.coffee_hook\(/g, (g0) -> g0 + visparam + ","

		jscode = "function(sortinglist , #{visualizer.getinitstmt()} ) { #{jscode}; return 'finished'; }"

		console.log "deux:" + jscode

		@newcode = jscode

		@updatecodeview()
		@testcodedata.text @newcode
		@newcodef = eval("(" + @newcode + ")")

	getTimestamp: ->
		(new Date).getTime()

	coffee_hook: (visvalues, eventtype, lineno, expression) ->
		@highlightline = lineno if lineno?
		@nexttick visvalues
		switch eventtype
			when "beforeexpression"
				@stack.push @highlightline
			when "expression"
				@stack.pop()
			when "beforestatement"
				0 #Donothing
		expression

@coderunner = new coderunner_class()
