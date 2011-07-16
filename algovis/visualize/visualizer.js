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
		this.render_bars(this.currentvalues);
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

	this.render_bars = function(values) 
	{
		if (isvalid(values) && isvalid(values.visarray) && values.visarray.length > 0)
		{}
		else
		{
			console.log("undefinedrender");
			return;
		}
		var l = values.visarray;
		var highlightindex = valueOrDefault(values.indexes, []);
		var highlightindexrange = valueOrDefault(values.indexranges, []);
		var extrabars = valueOrDefault(values.extrabars, []);
		var w = this.canvas.width();
		var h = this.canvas.height();
		var barh = h - 50;

		totalbars = l.length;
		var left = 20;
		if (this.visextrabars.length>0)
			totalbars += 2 + this.visextrabars.length;
		var barw = (w - 20 - left) / totalbars;
		if (totalbars > l.length)
			left += (totalbars - l.length) * barw;

		var maxv = 0;
		for (i=0; i<l.length; i++)
			if (l[i] > maxv)
				maxv = l[i];
		var barhstep = ((barh-5) / maxv);

		var context = this.canvas[0].getContext('2d');
		context.strokeStyle = "rgb(0,0,0)";
		for (var i=0; i<l.length; i++)
		{
			var highlightloc = highlightindex.indexOf(i);
			if (highlightloc != -1)
				context.fillStyle = highlightcolors[highlightloc];
			else
				context.fillStyle = "rgb(125,125,125)";
			context.fillRect(left+i*barw, barh-(barhstep*l[i]), barw, barhstep*l[i]);
			context.strokeRect(left+i*barw, barh-(barhstep*l[i]), barw, barhstep*l[i]);
		}
		var extraleft = barw;

		for (var i=0; i<extrabars.length; i++)
		{
			if (!isvalid(extrabars[i]) || !isvalid(extrabars[i][0]) || !isvalid(extrabars[i][1]))
				continue;
			var name = extrabars[i][0];
			var val = extrabars[i][1];
			context.fillStyle = "rgb(125,125,125)";
			context.fillRect(extraleft+i*barw, barh-(barhstep*val), barw, barhstep*val);
			context.strokeRect(extraleft+i*barw, barh-(barhstep*val), barw, barhstep*val);

			context.fillStyle = "rgb(0,0,0)";
			//context.font = "12px sans-serif";
			context.textAlign = "center";
			context.textBaseline = "top";
			context.fillText(name, extraleft+i*barw+barw/2., h-25);
		}

		h = this.canvas.height();

		for(var i in highlightindexrange)
		{
			var name = highlightindexrange[i][0];
			var low = highlightindexrange[i][1];
			var high = highlightindexrange[i][2];

			if (!isvalid(name) || !isvalid(low) || !isvalid(high))
				continue;

			if (low > high)
				continue;

			var l = left+low*barw;
			var r = left+high*barw+barw;
			var m = (l+r)/2;
			context.beginPath();
			context.moveTo(l, h - 45);
			context.lineTo(l, h - 35);
			context.lineTo(r, h - 35);
			context.lineTo(r, h - 45);
			context.moveTo(m, h - 35);
			context.lineTo(m, h - 30);

			context.stroke();

			//context.font = "12px sans-serif";
			context.textAlign = "center";
			context.textBaseline = "top";
			context.fillText(name, m, h-25);
		}
	}
}
var visualizer_graph = new function()
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
		var size=22;
		var ret = [[]];

		var line = [];
		for(var i=0; i<size; i++)
			line.push(0);

		for(var i=0; i<size; i++)
			ret.push(line);

		for(var i=0; i<size*size/2; i++)
		{
			if (Math.random() < 0.5)
				continue;

			var first=Math.floor(Math.random()*(size));
			var second=Math.floor(Math.random()*(size));

			ret[first][second] = 1;
		}

		this.positions = [];
	}
	this.render = function()
	{
		this.render_graph(this.currentvalues);
	}
	this.render_graph = function(values) 
	{
		if (isvalid(values) && isvalid(values.visadjmatrix) && values.visadjmatrix.length > 0)
		{}
		else
		{
			console.log("undefinedrender");
			return;
		}
		var adjmatrix = values.visadjmatrix;

		if (this.positions.length == 0)
		{
			//Randomly generate position for each vertex in graph
			for(var i=0; i<adjmatrix.length; i++)
			{
				var x = Math.floor(this.canvas.width() * Math.random()) % 10;
				var y = Math.floor(this.canvas.height() * Math.random()) % 10;
				this.positions.push([x,y]);
			}
		}

		var context = this.canvas[0].getContext('2d');
		context.strokeStyle = "rgb(0,0,0)";

		//Draw vertices
		for(var i=0; i<adjmatrix.length; i++)
		{
			var pos = this.positions[i];
			context.arc(pos[0], pos[1], 3, 0, 2*Math.PI, 0);
		}

		//Draw edges
		context.strokeStyle = "rgb(25,25,25)";
		for(var i=0; i<adjmatrix.length; i++)
		{
			for(var j=0; j<adjmatrix.length; j++)
			{
				if (adjmatrix[i][j] > 0)
				{
					var posFrom = this.positions[i];
					var posTo = this.positions[j];
					context.moveTo(posFrom[0], posFrom[1]);
					context.lineTo(posTo[0], posTo[1]);
				}
			}
		}
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
