var vis = "!vis-type: bar; !vis-array: myl; !vis-index: i; !vis-index: j; !vis-indexrange: sorted 0 j; !vis-extrabar: inserting key;";
var selectionsort = function(l) 
{
	var myl = l;
	for(var j = 1; j < myl.length; j++) {
		var key = myl[j];
		var i = j - 1;
	 
		while(i >= 0 && myl[i] > key) {
			myl[i+1] = myl[i];
			i = i - 1;     
		}            
	 
		myl[i+1] = key;
	}

}
selectionsort(sortinglist);
