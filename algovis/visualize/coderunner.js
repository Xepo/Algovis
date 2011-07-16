toline = 0;
newcode = "";

genlist_amttogenerate = 50;
genlist_maxvalue = 50;

function swapinlist(l, i1, i2)
{
	temp = l[i1];
	l[i1] = l[i2];
	l[i2] = temp;
}
function isdefined( variable)
{
    return (typeof(window[variable]) == "undefined") ?  false: true;
}
function isvalid(variable)
{
	try {
		if (typeof variable == 'undefined')
			return false;
		else if (variable === null)
			return false;
		else if (variable || (variable.toString() && variable+1))
			return true;
		return false;
	}
	catch (er) {
		return false;
	}
}
function assert(condition)
{
	if (condition)
		return true;
	throw "Assertion failed.";
}
function comparearray(ar1, ar2)
{
	if (ar1.length != ar2.length)
		return false;
	for(var i = 0; i<ar1.length; i++)
		if (ar1[i] != ar2[i])
			return false;
	return true;
}
var coderunner = new function() 
{
	this.setup = function(codeview, speedslider, gobutton, stopbutton, prevbutton, nextbutton, canvas) {
		this.codeview = codeview;
		this.codeview.linedtextarea();
		this.speedslider = speedslider;
		this.speedslider.slider({
				value:100, 
				max:201, 
				slide: function (event, ui) { coderunner.updatespeed() }});
		this.gobutton = gobutton;
		this.gobutton.bind('click', function() { coderunner.gobuttonclick() });
		this.stopbutton = stopbutton;
		this.stopbutton.bind('click', function() { coderunner.stoprun() });
		this.prevbutton = prevbutton;
		this.prevbutton.bind('click', function() { coderunner.nextstep(-1); });
		this.nextbutton = nextbutton;
		this.nextbutton.bind('click', function() { coderunner.nextstep(1); });
		this.timer = $.timer();
		this.canvas = canvas;
		this.onlypausewhenchanged = true;
		if ($('#showcoderunner'))
		{
			this.showcoderunner = $('#showcoderunner');
			this.showcoderunner.attr('checked', false);
			this.showcoderunner.bind('click', function() { coderunner.updatecodeview(); });
		}
		else
			this.showcoderunner = null;
		this.wasshowingrunner = false;

		this.stack = [];
		this.state = "stopped";
		this.updatespeed();

		this.record = []

		visualizer.setup(canvas);
	};
	this.enablecodeview = function(b) {
		if (b)
		{
			this.codeview.removeAttr('disabled');
			this.codeview.removeClass('codeviewdisabled');
		}
		else
		{
			this.codeview.attr('disabled', 'disabled');
			this.codeview.addClass('codeviewdisabled');
		}
	}
	this.updatecodeview = function () {
		if (this.showcoderunner && this.showcoderunner.attr('checked'))
		{
			if (!this.wasshowingrunner && this.code != this.codeview.val())
				this.setcode(this.codeview.val());
			this.codeview.val(this.newcode);
			this.enablecodeview(false);
			this.wasshowingrunner = true;
		}
		else
		{
			this.enablecodeview(true);
			if (!this.wasshowingrunner && this.code != this.codeview.val())
				this.setcode(this.codeview.val());
			this.codeview.val(this.code);
			if (this.state == "stopped")
				this.enablecodeview(true);
			else
				this.enablecodeview(false);
			this.wasshowingrunner = false;
		}

		if (this.state == "playing")
			this.gobutton.attr('value', 'Pause');
		else if (this.state == "paused")
			this.gobutton.attr('value', 'Continue');
		else 
			this.gobutton.attr('value', 'Go');
	}
	this.updatespeed = function() {
		delay = this.getdelay();
		if (this.lastdelay == delay)
			return;
		this.lastdelay = delay;
		
		if (delay <= -100)
			this.fastforward = true;
		else
			this.fastforward = false;

		if (delay < 0)
			this.runstep = -delay;
		else
			this.runstep = 1;

		if (delay <= 0)
			timerdelay = 1;
		else
			timerdelay = delay;
		this.timer.set({time: timerdelay})
		console.log("Set delay to " + delay + ", timerdelay to " + timerdelay + ", runstep to " + this.runstep + ", fastforward: " + this.fastforward);
	}
	this.getdelay = function() {
		curspeed = this.speedslider.slider('value');
		if (curspeed > 100)
			return -(curspeed - 100);
		else if (curspeed == 201)
			return -100;
		else
			return (1000-Math.sqrt(Math.sqrt(curspeed))*312);
	}
	this.getdepth = function() {
		i = 0;
		c = this.getdepth.caller;
		while (c) 
		{
			i++;
			c = c.caller;
		}
	}
	this.beforeline = function(highlightline) {
		this.stack.push(highlightline);
	}
	this.afterstmt = function(visvalues, highlightline) {
		this.highlightline = highlightline;
		var needup = visualizer.needupdate(visvalues);
		visualizer.afterstmt(visvalues);
		if (this.state != "playing")
			throw "coderunner_pause";
		this.updatespeed();
		if (this.onlypausewhenchanged && !needup)
			return false;
		this.ranlines++;
		if (this.ranlines > this.record.length)
			this.record.push([owl.deepCopy(this.stack), owl.deepCopy(visvalues)]);

		if (this.fastforward || this.ranlines < this.ranlinesmax)
			return false;

		throw "coderunner_pause";
	};
	this.afterline = function(highlightline) {
		this.stack.pop();
	}
	this.doeval = function() {
		_TopCodeRunNext_ = 0;
		var whoafinished = false;
		try{
			var inputval2 = owl.deepCopy(this.inputvalue);
			if (this.newcodef(inputval2) == 'finished')
				whoafinished = true;
		}
		catch (er) {
			whoafinished = false;
			if (er != "coderunner_pause")
			{
				exer = "Got exception: " + er + "\n";
				if (this.stack.length > 1)
					exer += "\nStack trace: \n";
				for(var v in this.stack)
					exer += "Line " + v + "\n";
				alert(exer);
				whoafinished = true;
			}
		}
		return whoafinished;
	}
	this.nextstep = function (amt) {
		visualizer.nextstep();
		if (this.state != "playing" && this.state != 'paused')
			return;
		amt = typeof(amt) != 'undefined' ? amt : this.runstep;

		this.queueup = this.ranlinesmax;
		this.ranlinesmax = this.ranlinesmax+amt;
		if (this.record.length > this.ranlinesmax)
		{
			this.stack = owl.deepCopy(this.record[this.ranlinesmax][0]);
			visualizer.afterstmt(owl.deepCopy(this.record[this.ranlinesmax][1]));
			finished = false;
		}
		else
		{

			//console.log("Ranlinesmax = " + this.ranlinesmax);

			jumpto = this.ranlinesmax+(this.runstep*10000);
			prevranlinesmax = this.ranlinesmax;
			this.ranlinesmax = jumpto;
			console.log("Currently " + prevranlinesmax + ", Recording to " + this.ranlinesmax + ", currentl rec'd:" + this.record.length);

			rlength = this.record.length;

			this.ranlines = 0;
			this.stack = [];
			finished = this.doeval();


			this.ranlinesmax = prevranlinesmax;
			if (this.ranlinesmax >= this.record.length)
				this.ranlinesmax = this.record.length-1;
			rec = this.record[this.ranlinesmax];
			this.stack = owl.deepCopy(rec[0]);
			visualizer.afterstmt(owl.deepCopy(rec[1]));

			console.log("Now rec'd: " + this.record.length);
			console.log("Ranlinesmax:" + this.ranlinesmax);
			if (rlength == this.record.length)
				finished = true;
			else if (this.ranlinesmax < this.record.length)
				finished = false;
		}

		$(".lineselect").removeClass("lineselect");
		$(".linecaller").removeClass("linecaller");
		$("#lineno-" + this.highlightline).addClass("lineselect");
		visualizer.render();
		while (this.stack.length)
		{
			lineno = this.stack.pop();
			if (lineno != this.highlightline)
				$("#lineno-" + lineno).addClass("linecaller");
		}
		if (finished)
		{
			console.log("finished");
			this.stoprun();
		}
	}
	this.startrun = function () {
		this.timer.stop();
		this.inputvalue = visualizer.generateinput();
		this.record = [];
		this.ranlinesmax = 0;
		this.ranlines = 0;
		this.startedtime = (new Date).getTime();
		this.unpauserun();
	}
	this.restartrun = function () {
		this.stoprun();
		this.startrun();
	}
	this.skiptoendofrun = function() {
		this.fastforward = true;
	}
	this.gobuttonclick = function() {
		if (this.state == 'stopped')
			this.startrun();
		else if (this.state == 'playing')
			this.pauserun();
		else if (this.state == 'paused')
			this.unpauserun();
	}
	this.unpauserun = function() {
		this.timer = $.timer({
				action: function() { coderunner.nextstep() }, 
				time: this.getdelay()});
		this.state = "playing";
		this.updatecodeview();
		this.timer.play();
	}
	this.pauserun = function() {
		this.state = "paused";
		this.timer.stop();
		this.updatecodeview();
	}
	this.stoprun = function() {
		this.pauserun();
		this.state = "stopped";
		this.ranlinesmax = 0;

		this.stoppedtime = (new Date).getTime();
		console.log("Time of run: " + (this.stoppedtime - this.startedtime));

		this.updatecodeview();
	}
	this.updatehighlightlines = function(code) {
		lines = code.split('\n');
		for(i=0; i<lines.length; i++)
		{
			lineno = (i+1).toString();
			if (lines[i].indexOf('{') == -1 && lines[i].indexOf('}') == -1 && lines[i].search(/return/) == -1 && lines[i].search(/[^ ;]/) != -1)
				lines[i] = "coderunner.beforeline(%HighlightLine%); " + lines[i] + ";coderunner.afterline(%HighlightLine%);";
			lines[i] = lines[i].replace(/%HighlightLine%/g, lineno);
		}
		newcode = lines.join('\n');
		newcode = newcode.replace(/%VisualizerParameters%/g, visualizer.getvaluesasparameter())
		return newcode;
	}
	this.addafterstmts = function(code) {
		lines = code.split('\n');
		for(i=0; i<lines.length; i++)
		{
			if (lines[i].search(/for *\(/) == -1)
					lines[i] = lines[i].replace(/;/g, "; coderunner.afterstmt(%VisualizerParameters%, %HighlightLine%);");
			if (lines[i].search(/afterstmt/i) == -1)
				lines[i] += "; coderunner.afterstmt(%VisualizerParameters%, %HighlightLine%);";
		}
		return lines.join('\n');

	}
	this.setcode = function (code) {
		this.code = code;
		this.codeview.text(code);
		code += ';';

		visualizer.setcode(code);
		this.inputvalue = visualizer.generateinput();
		codestr = eval("function(sortinglist) {" + code + "; }").toString();
		this.code = codestr;
		this.codeview.text(codestr);
		this.newcode = codestr;
		this.newcode = this.addafterstmts(this.newcode);
		this.newcode = "function(sortinglist) { " + visualizer.getinitstmt() + "cr_newf = " + this.newcode + "; cr_newf(sortinglist); return 'finished'; }";
		this.newcode = this.updatehighlightlines(this.newcode);

		this.updatecodeview();

		this.newcodef = eval(this.newcode);
	};
}
