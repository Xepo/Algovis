function getpivotndx(myl, left, right)
{
	return Math.floor((right+left)/2);
}
function getpivotndxbestof3(myl, left, right)
{
	var mid = Math.floor((right+left)/2);
	var pvs = [left, mid, right];
	if (myl[pvs[0]] > myl[pvs[1]])
		swapinlist(pvs, 0, 1);
	if (myl[pvs[1]] > myl[pvs[2]])
		swapinlist(pvs, 1, 2);
	if (myl[pvs[0]] > myl[pvs[1]])
		swapinlist(pvs, 0, 1);

	return pvs[1];
}
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
	var pivotindex = getpivotndxbestof3(myl,left,right);
	var pivot = myl[pivotindex];
	var ml = left;
	var mr = right;
	swapinlist(myl, pivotindex, right);

	mr--;

	while (ml < mr)
	{
		while (myl[ml] <= pivot && ml < mr)
			ml++;
		while (myl[mr] > pivot)
			mr--;
		if (ml < mr)
			swapinlist(myl, ml, mr);
	}
	mr++;
	swapinlist(myl, mr, right);

	quicksorth(myl, left, mr-1);
	quicksorth(myl, mr+1, right);
}
function quicksort(l) 
{
	var vis = "!vis-type: bar; !vis-array: myl; !vis-index: ml,mr; !vis-indexrange: current left right; !vis-extrabar: pivot pivot;";

	var myl = l;
	quicksorth(myl, 0, myl.length-1);
	return myl;
}
quicksort(sortinglist);
