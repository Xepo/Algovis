function shellsort(l)
{
	var vis = "!vis-type: bar; !vis-array: myl; !vis-index: i,i-inc,j;  !vis-extrabar: moving temp;";
	var myl = l;
	var inc = Math.round(myl.length/2);
	while (inc > 0)
	{
		for (var i=inc; i < myl.length; i++)
		{
			var temp = myl[i];
			var j = i;
			while (j >= inc && myl[j-inc] > temp)
			{
				myl[j] = myl[j-inc];
				j = j-inc;
			}
			myl[j] = temp;
		}
		inc = Math.round(inc/2.2);
	}
}
shellsort(sortinglist);
