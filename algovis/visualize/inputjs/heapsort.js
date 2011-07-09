function heapsort(l)
{
	var vis = "!vis-type: bar; !vis-array: myl; !vis-index: root,child,swap; !vis-indexrange: sorted sortedend lastindex;";
	var myl = l;
	lastindex = myl.length-1;
	sortedend = myl.length;
	heapify(myl);

	while (sortedend > 0)
	{
		swapinlist(myl, 0, sortedend-1);
		sortedend--;
		siftDown(myl, 0, sortedend-1);
	}

}
function heapify(myl)
{
	start = myl.length/2-1;

	while (start >= 0)
	{
		siftDown(myl, start, myl.length-1);
		start--;
	}
}
function siftDown(myl, start, end)
{
	root = start;

	while (root*2+1 <= end)
	{
		child = root * 2 + 1;
		swap = root;
		if (myl[swap] < myl[child])
			swap = child;
		if (child+1 <= end && myl[swap] < myl[child+1])
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
