/* Algovis
 * Author: Isaiah Damron <Isaiah+Algovis at Trifault dot net>
 */

var renderer = new function() {
	/* context - Context to draw to
	 * visarray - Array of heights to draw bars
	 * hlindices - Indices to highlight, [index1, index2, ...] 
	 * hlranges - Ranges to highlight, [[name1, low1, high1], [name2, low2, high2], ...]
	 * extrabars - Extra bars to draw, [[name1, height1], [name2, height2], ...]
	 */
	this.render_bars = function(context, w, h, visarray, hlindices, hlranges, extrabars) 
	{
		var l = visarray;
		var highlightindex = valueOrDefault(hlindices, []);
		var highlightindexrange = valueOrDefault(hlranges, []);
		var extrabars = valueOrDefault(extrabars, []);
		var barh = h - 50;

		totalbars = l.length;
		var left = 20;
		if (extrabars.length>0)
			totalbars += 2 + extrabars.length;
		var barw = (w - 20 - left) / totalbars;
		if (totalbars > l.length)
			left += (totalbars - l.length) * barw;

		var maxv = 0;
		for (i=0; i<l.length; i++)
			if (l[i] > maxv)
				maxv = l[i];
		var barhstep = ((barh-5) / maxv);

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
			if (!isvalid(extrabars[i]) || !isvalid(extrabars[i][0]) || !isvalid(extrabars[i][1]) || extrabars[i][1] == -1)
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

	/* 
	 * context, w, h
	 * positions -- List of positions for each node, [[x1, y1], [x2, y2], ...]
	 * adjmatrix -- Adjacency matrix [[0, 0, 1], [0,0,0], [0,0,0]] is a three vertex graph with node 0 connected to node 2
	 *
	 */
	this.render_graph = function(context, w, h, positions, adjmatrix) 
	{
		console.log("render_graph");
		if (positions.length == 0)
		{
			while (positions.length > 0)
				positions.pop();
			//Randomly generate position for each vertex in graph
			for(var i=0; i<adjmatrix.length; i++)
			{
				var x = Math.floor(w * Math.random());
				var y = Math.floor(h * Math.random());
				x = x - (x % 20);
				y = y - (y % 20);
				positions.push([x,y]);
			}
		}

		context.strokeStyle = "rgb(0,0,0)";

		//Draw vertices
		for(var i=0; i<adjmatrix.length; i++)
		{
			var pos = positions[i];
			context.arc(pos[0], pos[1], 3, 0, 2*Math.PI, 0);
		}
		context.stroke();

		//Draw edges
		context.strokeStyle = "rgb(25,25,25)";
		for(var i=0; i<adjmatrix.length; i++)
		{
			for(var j=0; j<adjmatrix.length; j++)
			{
				if (adjmatrix[i][j] > 0)
				{
					var posFrom = positions[i];
					var posTo = positions[j];
					context.moveTo(posFrom[0], posFrom[1]);
					context.lineTo(posTo[0], posTo[1]);
				}
			}
		}
		context.stroke();

		//Definitely not the best way to do this, but works for now.
		return positions;
	}
}
