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
