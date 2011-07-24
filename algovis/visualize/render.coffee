window.renderer = new ->
  @render_bars = (context, w, h, visarray, hlindices, hlranges, extrabars) ->
    l = visarray
    highlightindex = valueOrDefault(hlindices, [])
    highlightindexrange = valueOrDefault(hlranges, [])
    extrabars = valueOrDefault(extrabars, [])
    barh = h - 50
    totalbars = l.length
    left = 20
    totalbars += 2 + extrabars.length  if extrabars.length > 0
    barw = (w - 20 - left) / totalbars
    left += (totalbars - l.length) * barw  if totalbars > l.length
    maxv = 0
    i = 0
    while i < l.length
      maxv = l[i]  if l[i] > maxv
      i++
    barhstep = ((barh - 5) / maxv)
    context.strokeStyle = "rgb(0,0,0)"
    i = 0
    
    while i < l.length
      highlightloc = highlightindex.indexOf(i)
      unless highlightloc == -1
        context.fillStyle = highlightcolors[highlightloc]
      else
        context.fillStyle = "rgb(125,125,125)"
      context.fillRect left + i * barw, barh - (barhstep * l[i]), barw, barhstep * l[i]
      context.strokeRect left + i * barw, barh - (barhstep * l[i]), barw, barhstep * l[i]
      i++
    extraleft = barw
    i = 0
    
    while i < extrabars.length
      continue  if not extrabars?[i]? or not extrabars?[i]?[0]? or not extrabars?[i]?[1]? or extrabars?[i]?[1]? == -1
      name = extrabars[i][0]
      val = extrabars[i][1]
      context.fillStyle = "rgb(125,125,125)"
      context.fillRect extraleft + i * barw, barh - (barhstep * val), barw, barhstep * val
      context.strokeRect extraleft + i * barw, barh - (barhstep * val), barw, barhstep * val
      context.fillStyle = "rgb(0,0,0)"
      context.textAlign = "center"
      context.textBaseline = "top"
      context.fillText name, extraleft + i * barw + barw / 2.0, h - 25
      i++
    for i of highlightindexrange
      name = highlightindexrange[i][0]
      low = highlightindexrange[i][1]
      high = highlightindexrange[i][2]
      continue  if not name? or not low? or not high?
      continue  if low > high
      l = left + low * barw
      r = left + high * barw + barw
      m = (l + r) / 2
      context.beginPath()
      context.moveTo l, h - 45
      context.lineTo l, h - 35
      context.lineTo r, h - 35
      context.lineTo r, h - 45
      context.moveTo m, h - 35
      context.lineTo m, h - 30
      context.stroke()
      context.textAlign = "center"
      context.textBaseline = "top"
      context.fillText name, m, h - 25
  
  @render_graph = (context, w, h, positions, adjmatrix) ->
    console.log "render_graph"
    if positions.length == 0
      while positions.length > 0
        positions.pop()
      i = 0
      
      while i < adjmatrix.length
        x = Math.floor(w * Math.random())
        y = Math.floor(h * Math.random())
        x = x - (x % 20)
        y = y - (y % 20)
        positions.push [ x, y ]
        i++
    context.strokeStyle = "rgb(0,0,0)"
    i = 0
    
    while i < adjmatrix.length
      pos = positions[i]
      context.arc pos[0], pos[1], 3, 0, 2 * Math.PI, 0
      i++
    context.stroke()
    context.strokeStyle = "rgb(25,25,25)"
    i = 0
    
    while i < adjmatrix.length
      j = 0
      
      while j < adjmatrix.length
        if adjmatrix[i][j] > 0
          posFrom = positions[i]
          posTo = positions[j]
          context.moveTo posFrom[0], posFrom[1]
          context.lineTo posTo[0], posTo[1]
        j++
      i++
    context.stroke()
    positions
  this

