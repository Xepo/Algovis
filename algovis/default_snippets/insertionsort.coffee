vis = "!vis-type: bar; !vis-array: myl; !vis-index: i; !vis-index: j; !vis-indexrange: sorted 0 j; !vis-extrabar: inserting key;"
insertionsort = (l) ->
  myl = l
  j = 1
  
  while j < myl.length
    key = myl[j]
    i = j - 1
    while i >= 0 and myl[i] > key
      myl[i + 1] = myl[i]
      i = i - 1
    myl[i + 1] = key
    j++

insertionsort sortinglist

