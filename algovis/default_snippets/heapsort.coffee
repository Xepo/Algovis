heapsort = (l) ->
  myl = l
  heapify myl
  while sortedend > 0
    sortedend--
    swapinlist myl, 0, sortedend
    siftDown myl, 0, sortedend

heapify = (myl) ->
  start = Math.floor(myl.length / 2)
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
    return if swap == root

    swapinlist myl, root, swap
    root = swap

vis = "!vis-type: bar; !vis-array: myl; !vis-index: root,child,swap; !vis-indexrange: sorted sortedend lastindex;"
lastindex = sortinglist.length - 1
sortedend = sortinglist.length
heapsort sortinglist

