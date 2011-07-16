function isArray(obj) {
	//returns true is it is an array
	if (obj.constructor.toString().indexOf("Array") == -1)
		return false;
	else
		return true;
}
function isObject(obj) {
	//returns true is it is an array
	if (obj.constructor.toString().indexOf("Object") == -1)
		return false;
	else
		return true;
}
function genrandomlist(len, max)
{
	ret = []
	for(var i=0; i<len; i++)
	{
		var randomnumber=Math.floor(Math.random()*(max+1));
		ret.push(randomnumber);
	}
	return ret;
}
function deepCompare(obj1, obj2)
{
	if (!isvalid(obj1) != !isvalid(obj2))
		return false;
	if (!isvalid(obj1))
		return true;
	isarr1 = isArray(obj1);
	isarr2 = isArray(obj2);
	isobj1 = isObject(obj1);
	isobj2 = isObject(obj2);
	if (isarr1 != isarr2)
		return false;
	if (isobj1 != isobj2)
		return false;

	if (isarr1 && isarr2 && obj1.length != obj2.length)
		return false;
	else if (isarr1)
	{
		for(var i in obj1)
			if (!deepCompare(obj1[i], obj2[i]))
				return false;
		return true;
	}
	else if (isobj1)
	{
		for(var prop in obj1)
			if (!obj1.hasOwnProperty(prop) && !obj2.hasOwnProperty(prop))
				continue;
			else if (obj1.hasOwnProperty(prop) != obj2.hasOwnProperty(prop))
				return false;
			else if (!deepCompare(obj1[prop], obj2[prop]))
				return false;
		return true;
	}
	else
		return obj1 == obj2;
}
function valueOrDefault(val, def) {
    if (isvalid(val))
	    return val;
    return def;
}

var highlightcolors = ['rgb(255,50,50)', 'rgb(50,255,50)', 'rgb(50,50,255)'];
var visualizer_bars = function()
{
	this.setup = function(canvas, rect, settings)
	{
		this.canvas = canvas;
		this.canvasrect = rect;
		this.setsettings(settings);
	}
	this.getinitstmt = function()
	{
		retvars = this.visarray;
		retvars += "," + this.visindex.join(',');
		for(var i in this.visindexranges)
			retvars += "," + this.visindexranges[i].lowrange + "," + this.visindexranges[i].highrange;
		for(var i in this.visextrabars)
			retvars += "," + this.visextrabars[i].value;
		retvars += ',';

		vars = retvars.match(/[a-zA-Z][a-zA-Z0-9]*(?!\()/g);

		return "var " + vars.join('=null,') + '=null;';
	}
	this.getvaluesasparameter = function() 
	{
		ret = "{'visarray': " + this.visarray;
		if (this.visindex.length > 0)
			ret += ", 'indexes': [" + this.visindex.join(',') + "]";
		if (this.visindexranges.length > 0)
		{
			var irange = [];
			for(var j in this.visindexranges)
			{
				thisrange = this.visindexranges[j];
				irange.push("['" + thisrange.name + "'," + thisrange.lowrange + "," + thisrange.highrange + "]");
			}
			ret += ", 'indexranges': [" + irange.join(",") + "]";
		}
		if (this.visextrabars.length > 0)
		{
			var ibar = [];
			for(var j in this.visextrabars)
			{
				thisbar = this.visextrabars[j];
				ibar.push("['" + thisbar.name + "'," + thisbar.value + "]");
			}
			ret += ", 'extrabars': [" + ibar.join(",") + "]";
		}
		return ret + "}";
	}
	this.generateinput = function()
	{
		console.log("Generating input");
		return genrandomlist(25, 25);
	}
	this.needupdate = function(values)
	{
		ret = !deepCompare(this.currentvalues, values);
		return ret;
	}
	this.afterstmt = function(values)
	{
		if (values && values.hasOwnProperty('visarray') && values.visarray)
			this.currentvalues = owl.deepCopy(values);
	}
	this.render = function()
	{
		var values = this.currentvalues;
		if (isvalid(values) && isvalid(values.visarray) && values.visarray.length > 0)
		{}
		else
		{
			console.log("undefinedrender");
			return;
		}

		var context = this.canvas[0].getContext('2d');
		var w = this.canvas.width(), h=this.canvas.height();
		var extrabars = valueOrDefault(values.extrabars, []);
		while (extrabars.length < this.visextrabars.length)
			extrabars.push(['', -1])
		renderer.render_bars(context, w, h, values.visarray, values.indexes, values.indexranges, extrabars);
	}
	this.reset = function()
	{
		this.currentvalues = {'visarray': []};
	}
	this.resetsettings = function()
	{
		this.visarray = null;
		this.visindex = [];
		this.visindexranges = [];
		this.visextrabars = [];
		this.reset();
	}
	this.setsettings = function(settings)
	{
		this.resetsettings();
		commands = settings;
		for (var i in commands)
		{
			command = commands[i][0];
			param = commands[i][1];
			if (command == 'array')
				this.visarray = param;
			else if (command == 'index')
				this.visindex = this.visindex.concat(param.split(','));
			else if (command == 'indexrange')
			{
				var params = param.split(' ');
				var irange = Object();
				irange.name = params[0];
				irange.lowrange = params[1];
				irange.highrange = params[2];
				this.visindexranges.push(irange);
			}
			else if (command == 'extrabar')
			{
				var params = param.split(' ');
				var ibar = Object();
				ibar.name = params[0];
				ibar.value = params[1];
				this.visextrabars.push(ibar);
			}
		}
		assert(this.visarray);
	}
}
var visualizer_graph = function()
{
	this.setup = function(canvas, rect, settings)
	{
		this.canvas = canvas;
		this.canvasrect = rect;
		this.setsettings(settings);
	}
	this.reset = function()
	{
		this.currentvalues = {'visarray': []};
	}
	this.resetsettings = function()
	{
		this.visadjmatrix = null;
		this.visedge = [];
		this.visvertex = [];
		this.reset();
	}
	this.setsettings = function(settings)
	{
		this.resetsettings();
		commands = settings;
		for (var i in commands)
		{
			command = commands[i][0];
			param = commands[i][1];
			if (command == 'adjmatrix')
				this.visadjmatrix = param;
			else if (command == 'highlightedge')
			{
				this.visedge = this.visedge.concat(param.split('-'));
			}
			else if (command == 'highlightvertex')
			{
				this.visvertex = this.visvertex.concat(param.split('-'));
			}
		}
		if (!isvalid(this.visadjmatrix))
			throw "Need vis-adjmatrix!";
		assert(this.visadjmatrix);
	}

	this.getinitstmt = function()
	{
		retvars = this.visadjmatrix;

		vars = retvars.match(/[a-zA-Z][a-zA-Z0-9]*(?!\()/g);

		return "var " + vars.join('=null,') + '=null;';
	}
	this.getvaluesasparameter = function() 
	{
		ret = "{'visadjmatrix': " + this.visadjmatrix;
		return ret + "}";
	}
	this.needupdate = function(values)
	{
		ret = !deepCompare(this.currentvalues, values);
		return ret;
	}
	this.afterstmt = function(values)
	{
		if (values && values.hasOwnProperty('visadjmatrix') && values.visadjmatrix)
			this.currentvalues = owl.deepCopy(values);
	}
	this.generateinput = function()
	{
		console.log("Generating matrix");
		var size=4;
		var ret = [[]];

		var line = [];
		for(var i=0; i<size; i++)
			line.push(0);

		for(var i=0; i<size; i++)
			ret.push(line);

		for(var i=0; i<size*size/2; i++)
		{
			if (Math.random() < 0.8)
				continue;

			var first=Math.floor(Math.random()*(size));
			var second=Math.floor(Math.random()*(size));
			if (first == second)
				continue;

			ret[first][second] = 1;
		}

		this.positions = [];

		return ret;
	}
	this.render = function()
	{
		var values = this.currentvalues;
		if (isvalid(values) && values.hasOwnProperty('visadjmatrix') && isvalid(values.visadjmatrix) && values.visadjmatrix.length > 0)
		{}
		else
		{
			console.log("undefinedrender");
			return;
		}

		var context = this.canvas[0].getContext('2d');
		var w = this.canvas.width(), h=this.canvas.height();

		this.positions = renderer.render_graph(context, w, h, this.positions, values.visadjmatrix);
	}
}
var visualizer = new function() 
{
	this.setup = function(canvas)
	{
		this.canvas = canvas;

		this.resetcode();
	}
	this.getinitstmt = function()
	{
		var initstmts = [];
		for(var i in this.visualizers)
			initstmts.push(this.visualizers[i].getinitstmt());
		return initstmts.join(';');
	}
	this.getvaluesasparameter = function() 
	{
		var valparams = [];
		for(var i in this.visualizers)
			valparams.push(this.visualizers[i].getvaluesasparameter());
		return '[' + valparams.join(',') + ']';
	}
	this.generateinput = function() 
	{
		return this.visualizers[0].generateinput();
	}
	this.clearcanvas = function() {
		this.canvas[0].width = this.canvas[0].width;
	}
	this.nextstep = function()
	{
		this.clearcanvas();
	}
	this.needupdate = function(values)
	{
		for(var i in this.visualizers)
			if (this.visualizers[i].needupdate(values[i]))
				return true;
		return false;
	}
	this.afterstmt = function(values)
	{
		for(var i in this.visualizers)
			this.visualizers[i].afterstmt(values[i]);
	}
	this.render = function()
	{
		this.clearcanvas();
		for (var i in this.visualizers)
			this.visualizers[i].render();
	}
	this.findcommands = function(code)
	{
		var mycode = code;
		visreg = /!vis-([a-zA-Z0-9]+): *([^;]*);/gi;
		var matches = code.match(visreg);
		visreg = /!vis-([a-zA-Z0-9]+): *([^;]*);/i;
		console.log("matches:" + matches);
		commands = []
		for (var i in matches)
		{
			var match = matches[i].match(visreg);
			commands.push([match[1], match[2]]);
		}
		console.log(commands);
		return commands;
	}
	this.reset = function()
	{
		for(var i in this.visualizers)
			this.visualizers[i].reset();
	}
	this.resetcode = function()
	{
		this.visualizers = []
	}
	this.createvis = function(vistype, viscommands)
	{
		if (vistype == 'bar')
		{
			var newvis = new visualizer_bars();
			newvis.setup(this.canvas, [], viscommands);
			this.visualizers.push(newvis);
		}
		else if (vistype == 'graph')
		{
			var newvis = new visualizer_graph();
			newvis.setup(this.canvas, [], viscommands);
			this.visualizers.push(newvis);
		}
		else
			throw "No such vistype:" + vistype;
	}
	this.setcode = function(code)
	{
		this.resetcode();
		commands = this.findcommands(code);
		var curvis = null;
		var curcoms = []
		for (var i in commands)
		{
			command = commands[i][0];
			param = commands[i][1];
			if (command == 'type')
			{
				if (curvis != null)
				{
					this.createvis(curvis, curcoms);
					curvis = null;
					curcoms = [];
				}
				curvis = param;
			}
			else
			{
				if (curvis == null)
					throw "Must set vis-type before anything else!";
				curcoms.push(commands[i]);
			}
		}

		if (curvis != null)
			this.createvis(curvis, curcoms);
	}
}
