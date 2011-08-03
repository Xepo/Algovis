shellsort = (l) ->
  myl = l
  inc = Math.round(myl.length / 2)
  while inc > 0
    i = inc
    
    while i < myl.length
      temp = myl[i]
      j = i
      while j >= inc and myl[j - inc] > temp
        myl[j] = myl[j - inc]
        j = j - inc
      myl[j] = temp
      i++
    inc = Math.round(inc / 2.2)
vis = "!vis-type: bar; !vis-array: myl; !vis-index: i,i-inc,j;  !vis-extrabar: moving temp;"
shellsort sortinglist

