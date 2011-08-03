selectionsort = (l) ->
  myl = l
  
  ipos = 0
  while ipos < myl.length
    imin = ipos
    i = ipos + 1
    
    while i < myl.length
      imin = i  if myl[i] < myl[imin]
      i++
    swapinlist myl, imin, ipos  unless imin == ipos
    ipos++
vis = "!vis-type: bar; !vis-array: myl; !vis-index: ipos, i, imin;  !vis-indexrange: sorted 0 ipos-1;"
selectionsort sortinglist

