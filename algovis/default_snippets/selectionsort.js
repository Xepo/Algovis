var vis = "!vis-type: bar; !vis-array: myl; !vis-index: ipos, i, imin;  !vis-indexrange: sorted 0 ipos-1;";
function selectionsort(l)
{
	var myl = l;
	var ipos, imin;
	for(ipos = 0; ipos<myl.length; ipos++)
	{
		imin = ipos;
		for(var i=ipos+1; i<myl.length; i++)
			if (myl[i] < myl[imin])
				imin = i;
		if (imin != ipos)
			swapinlist(myl, imin, ipos);
	}
}
selectionsort(sortinglist);
