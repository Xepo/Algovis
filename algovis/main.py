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
from models import CodeSnippet
import os

class IndexHandler(webapp.RequestHandler):
    def get(self):
	self.response.out.write("<html><ul>")
	for cosni in CodeSnippet.all():
		self.response.out.write("<li><a href='/view?id=%s'>%s</a></li>" % (str(cosni.key()), cosni.name))
	self.response.out.write("</ul></html>")

class PreloadHandler(webapp.RequestHandler):
	def get(self):
		defaultdir = os.path.join(os.path.dirname(__file__), 'default_snippets')
		jsfiles = [fn for fn in os.listdir(defaultdir) if fn.endswith('.js')]
		for fn in jsfiles:
			cosni = CodeSnippet()

			cosni.name = os.path.basename(fn)
			cosni.name = cosni.name[:-3] #Remove .js from name

			cosni.description = cosni.name

			with open(os.path.join(defaultdir, fn), 'r') as f:
				cosni.code = f.read()

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
