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
`_.isEqualNull = function(a, b) {
    // Check object identity.
    if (a === b) return true;
    if (_.isNull(a) && _.isNull(b)) return true;
    // Different types?
    var atype = typeof(a), btype = typeof(b);
    if (atype != btype) return false;
    // Basic equality test (watch out for coercions).
    if (a == b) return true;
    // One is falsy and the other truthy.
    if ((!a && b) || (a && !b)) return false;
    // Unwrap any wrapped objects.
    if (a._chain) a = a._wrapped;
    if (b._chain) b = b._wrapped;
    // One of them implements an isEqual()?
    if (a.isEqual) return a.isEqual(b);
    if (b.isEqual) return b.isEqual(a);
    // Check dates' integer values.
    if (_.isDate(a) && _.isDate(b)) return a.getTime() === b.getTime();
    // Both are NaN?
    if (_.isNaN(a) && _.isNaN(b)) return false;
    // Compare regular expressions.
    if (_.isRegExp(a) && _.isRegExp(b))
      return a.source     === b.source &&
             a.global     === b.global &&
             a.ignoreCase === b.ignoreCase &&
             a.multiline  === b.multiline;
    // If a is not an object by this point, we can't handle it.
    if (atype !== 'object') return false;
    // Check for different array lengths before comparing contents.
    if (a.length && (a.length !== b.length)) return false;
    // Nothing else worked, deep compare the contents.
    var aKeys = _.keys(a), bKeys = _.keys(b);
    // Different object sizes?
    if (aKeys.length != bKeys.length) return false;
    // Recursive comparison of contents.
    for (var key in a) if (!(key in b) || !_.isEqualNull(a[key], b[key])) return false;
    return true;
  };
  `

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
		@lastup = {}
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
			@lastup = {}
			visualizer.reset()
			inputval2 = owl.deepCopy(@inputvalue)
			whoafinished = true  if @newcodef(inputval2) == "finished"
		catch er
			whoafinished = false
			if er != "coderunner_interrupt"
				exer = "Exception on line #{@highlightline}: <br/><code style='padding-left:1em;'>#{er}</code><br/>"
				exer += "\nStack trace: <br/>"  if @stack.length > 1
				exer += "<code style='display:block; padding-left: 1em;'>"
				for v in @stack
					exer += "Line " + v + "<br/>\n"
				exer += "</code>"
				console.log exer
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

	nexttick: ->
		needup = false
		@ranticks++

		if @ranticks < @record.length and @highlightline != @record[@ranticks][1]
			console.log "Invalid tick ##{@ranticks}! line #{@highlightline} vs. #{@record[@ranticks][1]}\n"

		needup = not _.isEqualNull(@lastup, visualizer.valuesobj)

		if needup
			@lastup = owl.deepCopy(visualizer.valuesobj)
			@ranchanges++
			###if @record.length <= @changestoticks[@ranchanges]
				console.log "Changes to ticks is ahead of record"
			else if not deepCompare(@lastup, @record[@changestoticks[@ranchanges]][2])
				console.log "Invalid compare:\n#{@lastup.toSource()}\n" + @record[@changestoticks[@ranchanges]][2].toSource()###
			while @ranchanges >= @changestoticks.length
				@changestoticks.push @ranticks

		while @ranticks >= @record.length
			@record.push [owl.deepCopy(@stack), @highlightline, @lastup ]

		if @state != "playing" or @interruptattick? and @ranticks >= @interruptattick
			console.log "Interrupting for tick #{@ranticks} >= #{@interruptattick}"
			throw "coderunner_interrupt" unless @fastforward

		if @interruptatchange? and @ranchanges >= @interruptatchange
			console.log "Interrupting for change #{@ranchanges} >= #{@interruptatchange}"
			throw "coderunner_interrupt" unless @fastforward

		@updatespeed()

	fetchnewrecords: (@interruptattick, @interruptatchange) ->
		#Make sure we fetch a decent bit at one time
		if @recordedall
			return
		if @interruptattick - @record.length < 50*101
			@interruptattick = @record.length + 50*101
		if @interruptatchange - @changestoticks.length < 50
			@interruptatchange = @changestoticks.length + 50

		console.log "Evaling for new records"
		@stack = []
		@ranticks=0
		@lastup = {}
		@ranchanges=0
		@recordedall = false
		@recordedall = @doeval()

	refreshlinesdisplay: ->
		$(".lineselect").removeClass "lineselect"
		$(".linecaller").removeClass "linecaller"
		$("#lineno-" + @highlightline).addClass "lineselect"
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
			if changetick <= attick
				attick = changetick
				retchange = atchange

		ticktochange = @changestoticks.indexOf attick
		if ticktochange != -1
			retchange = ticktochange

		if attick >= @record.length
			attick = @record.length - 1
		else if attick < 0
			attick = 0


		@stack = owl.deepCopy(@record[attick][0])
		@highlightline = @record[attick][1]

		visualizer.render(@record[attick][2])
		@refreshlinesdisplay()

		return [attick, atchange]

	displaynext: (amtticks=null, amtchanges=@runstep) ->
		return  if @state != "playing" and @state != "paused"
		amtticks?=amtchanges*101

		@checksetup()

		shown = @display @showingtick+amtticks, @showingchange+amtchanges

		advancedticks = (shown?[0] ? @showingtick) - @showingtick
		advancedchanges = (shown?[1] ? @showingchange) - @showingchange

		if amtticks > 0 and advancedticks == 0 and @showingtick > 0
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

		console.log "vars:" + visualizer.getvars()
		console.log @code
		try
			jscode = CoffeeScript.compile(@code, {'hook': 'coderunner.coffee_hook', 'forceglobals': visualizer.getvars()})
		catch error
			alert "Internal Error!  Contact algovis developer.\n#{error}"

		jscode = "function(sortinglist) { with (visualizer.valuesobj) { #{jscode}; }; return 'finished'; }"

		console.log "deux:" + jscode

		@newcode = jscode

		@updatecodeview()
		@testcodedata.text @newcode
		@newcodef = eval("(" + @newcode + ")")

	getTimestamp: ->
		(new Date).getTime()

	coffee_hook: (eventtype, lineno, expression) ->
		@highlightline = lineno if lineno?
		@nexttick()
		switch eventtype
			when "beforeexpression"
				@stack.push @highlightline
			when "expression"
				@stack.pop()
			when "beforestatement"
				0 #Donothing
		expression

@coderunner = new coderunner_class()
