var vis = "!vis-type: bar; !vis-array: myl; !vis-index: i; !vis-index: i-1;";
function bubblesort(l)
{
	var swapped;
	var myl = l;
	do
	{
		swapped = false;
		for (var i = 1; i<myl.length; i++)
			if (myl[i-1] > myl[i])

			{
				swapinlist(myl, i-1, i);
				swapped = true;
			}
	} while(swapped);
}
bubblesort(sortinglist);
