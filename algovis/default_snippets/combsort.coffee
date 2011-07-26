vis = "!vis-type: bar; !vis-array: myl; !vis-index: i,i+gap;"
combsort = (myl) ->
  gap = myl.length
  swapped = true
  while gap != 1 or swapped
    gap = Math.floor(gap / 1.24)
    gap = 1  if gap < 1
    swapped = false
    i = 0
    
    while i + gap < myl.length
      if myl[i] > myl[i + gap]
        swapinlist myl, i, i + gap
        swapped = true
      i++
combsort sortinglist
