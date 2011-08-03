heapsort = (l) ->
  myl = l
  lastindex = myl.length - 1
  sortedend = myl.length
  heapify myl
  while sortedend > 0
    swapinlist myl, 0, sortedend
    sortedend--
    siftDown myl, 0, sortedend
heapify = (myl) ->
  start = myl.length / 2 - 1
  while start >= 0
    siftDown myl, start, myl.length
    start--
siftDown = (myl, start, end) ->
  root = start
  while root * 2 + 1 < end
    child = root * 2 + 1
    swap = root
    swap = child  if myl[child] > myl[swap]
    swap = child + 1  if child + 1 < end and myl[child + 1] > myl[swap]
    unless swap == root
      swapinlist myl, root, swap
      root = swap
    else
      return
vis = "!vis-type: bar; !vis-array: myl; !vis-index: root,child,swap; !vis-indexrange: sorted sortedend lastindex;"
heapsort sortinglist

