var vis = "!vis-type: bar; !vis-array: myl; !vis-index: root,child,swap; !vis-indexrange: sorted sortedend lastindex;";
function heapsort(l)
{
	var myl = l;
	lastindex = myl.length-1;
	sortedend = myl.length;
	heapify(myl);

	while (sortedend > 0)
	{
		swapinlist(myl, 0, sortedend);
		sortedend--;
		siftDown(myl, 0, sortedend);
	}

}
function heapify(myl)
{
	start = myl.length/2-1;

	while (start >= 0)
	{
		siftDown(myl, start, myl.length);
		start--;
	}
}
function siftDown(myl, start, end)
{
	root = start;

	while (root*2+1 < end)
	{
		var child = root * 2 + 1;
		var swap = root;
		if (myl[child] > myl[swap])
			swap = child;
		if (child+1 < end && myl[child+1] > myl[swap])
			swap = child+1;
		if (swap != root)
		{
			swapinlist(myl, root, swap);
			root = swap;
		}
		else
			return;
	}
}
heapsort(sortinglist);
