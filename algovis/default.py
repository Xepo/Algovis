default_snippets = {
		'bubblesort': """
vis = "!vis-type: bar; !vis-array: myl; !vis-index: i; !vis-index: i-1;"
bubblesort = (l) ->
	myl = l
	loop
		swapped = false
		for i in [1...myl.length]
			if myl[i - 1] > myl[i]
				swapinlist myl, i - 1, i
				swapped = true
		break unless swapped
bubblesort sortinglist
""",


'insertionsort': """
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
""",
'combsort': """
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
""",
'heapsort':"""
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
""",
'quicksort': """
quicksorth = (myl, left, right) ->
  return  if right <= left
  if right - left == 1
    swapinlist myl, left, right  if myl[left] > myl[right]
    return
  pivot = left
  mid = (left + right) / 2
  unless (myl[right] >= myl[left]) == (myl[right] >= myl[mid])
    pivot = right
  else pivot = mid  unless (myl[mid] >= myl[left]) == (myl[mid] >= myl[right])
  ml = left
  mr = right
  swapinlist myl, pivot, ml
  pivot = ml++
  while ml < mr
    while ml < mr and myl[ml] <= myl[pivot]
      ml++
    while ml < mr and myl[mr] >= myl[pivot]
      mr--
    swapinlist myl, ml, mr
  ml--  if myl[ml] > myl[pivot]
  swapinlist myl, ml, pivot
  quicksorth myl, left, ml - 1
  quicksorth myl, ml + 1, right
quicksort = (l) ->
  myl = l
  quicksorth myl, 0, myl.length - 1
  myl
vis = "!vis-type: bar; !vis-array: myl; !vis-index: pivot,ml,mr; !vis-indexrange: current left right;"
quicksort sortinglist
""",
'selectionsort': """
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
""",
'shellsort': """
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
""",

}



