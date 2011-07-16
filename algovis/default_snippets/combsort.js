var vis = "!vis-type: bar; !vis-array: myl; !vis-index: i,i+gap;";
function combsort(l)
{
	var myl = l;
	var gap = l.length;
	var swapped = true;

	while (gap != 1 || swapped)
	{
		gap = Math.floor(gap / 1.24);
		if (gap < 1)
			gap = 1;

		swapped = false;
		for(var i=0; i+gap<l.length; i++)
			if (myl[i] > myl[i+gap])
			{
				swapinlist(myl, i, i+gap);
				swapped = true;
			}
	}
}
combsort(sortinglist);
