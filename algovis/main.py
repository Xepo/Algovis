#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
defaultsnippets = [
		{'name': 'insertionsort',
			'code': """
//!vis-type: bar; !vis-array: myl; !vis-index: i; !vis-index: j; !vis-indexrange: sorted 0 j; !vis-extrabar: inserting key;
function insertionsort(l) {
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
insertionsort(sortinglist);
			"""},
		{'name': 'quicksort-bestof3',
			'code': """
function getpivotndx(myl, left, right) {
	return Math.floor((right+left)/2);
}
function getpivotndxbestof3(myl, left, right) {
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
function quicksorth(myl, left, right) {
	if (right <= left)
		return;
	if (right - left == 1) {
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

	while (ml < mr) {
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
function quicksort(l) {
	var vis = "!vis-type: bar; !vis-array: myl; !vis-index: ml,mr; !vis-indexrange: current left right; !vis-extrabar: pivot pivot;";

	var myl = l;
	quicksorth(myl, 0, myl.length-1);
	return myl;
}
quicksort(sortinglist);
"""}]


class CodeSnippet(db.Model):
	name = db.StringProperty()
	description = db.StringProperty(multiline=True)
	code = db.TextProperty()
	date = db.DateTimeProperty(auto_now_add=True)
	

class IndexHandler(webapp.RequestHandler):
    def get(self):
	self.response.out.write("<html><ul>")
	for cosni in CodeSnippet.all():
		self.response.out.write("<li><a href='/view?id=%s'>%s</a></li>" % (str(cosni.key()), cosni.name))
	self.response.out.write("</ul></html>")

class PreloadHandler(webapp.RequestHandler):
	def get(self):
		for s in defaultsnippets:
			cosni = CodeSnippet()
			cosni.name = s['name']
			cosni.description = s.get('description', '')
			cosni.code = s['code']
			cosni.put()

class ViewHandler(webapp.RequestHandler):
	def get(self):
		id = self.request.get('id')
		with open('visualize_mainview.html', 'r') as f:
			html = f.read()
		html = html.replace('%CODEURL%', '/codeview?id=%s' % (id))
		self.response.out.write(html)

class CodeViewHandler(webapp.RequestHandler):
	def get(self):
		id = self.request.get('id')
		cosni = CodeSnippet.get(id)
		self.response.out.write(cosni.code.strip())


def main():
    application = webapp.WSGIApplication([
	    ('/', IndexHandler),
	    ('/view', ViewHandler),
	    ('/codeview', CodeViewHandler),
	    ('/preload', PreloadHandler)
	    ], debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
