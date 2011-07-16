var vis = "!vis-type: bar; !vis-array: myl; !vis-index: pivot,ml,mr; !vis-indexrange: current left right;";
function quicksorth(myl, left, right)
{
	if (right <= left)
		return;
	if (right - left == 1)
	{
		if (myl[left] > myl[right])
			swapinlist(myl, left, right);
		return;
	}
	var pivot = left;
	var mid = (left+right)/2;

	if ((myl[right] >= myl[left]) != (myl[right] >= myl[mid]))
		pivot = right;
	else if ((myl[mid] >= myl[left]) != (myl[mid] >= myl[right]))
		pivot = mid;

	var ml = left;
	var mr = right;

	swapinlist(myl, pivot, ml);

	pivot = ml++;

	while (ml < mr)
	{
		while (ml < mr && myl[ml] <= myl[pivot])
			ml++;
		while (ml < mr && myl[mr] >= myl[pivot])
			mr--;
		swapinlist(myl, ml, mr);
	}

	if (myl[ml] > myl[pivot])
		ml--;

	swapinlist(myl, ml, pivot);

	quicksorth(myl, left, ml-1);
	quicksorth(myl, ml+1, right);
}
function quicksort(l) 
{
	var myl = l;
	quicksorth(myl, 0, myl.length-1);
	return myl;
}
quicksort(sortinglist);
