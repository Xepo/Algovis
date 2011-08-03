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

