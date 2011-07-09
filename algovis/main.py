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
import os
import logging
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from models import CodeSnippet
from mako.template import Template
from mako.lookup import TemplateLookup
import mako.exceptions
import new

def extend_codesnippet(cosni):
	def getvisurl(self):
		return '/view?id=%s' % (str(self.key()))
	def getcodeurl(self):
		return '/codeview?id=%s' % (str(self.key()))

	cosni.getvisurl = new.instancemethod(getvisurl, cosni, cosni.__class__)
	cosni.getcodeurl = new.instancemethod(getcodeurl, cosni, cosni.__class__)
	return cosni


mylookup = TemplateLookup(directories=[os.path.join('Templates')])
def rendertemplate(templatename, **kwargs):
	try:
		temp = mylookup.get_template(templatename)
		return temp.render(**kwargs)
	except:
		logging.error("Error while processing templates!")
		logging.error(mako.exceptions.text_error_template().render())
		raise



class IndexHandler(webapp.RequestHandler):
    def get(self):
	d = {'codesnippets': (extend_codesnippet(x) for x in CodeSnippet.all())}
	self.response.out.write(rendertemplate('viewindex.html', **d))

class PreloadHandler(webapp.RequestHandler):
	def get(self):
		defaultdir = os.path.join(os.path.dirname(__file__), 'default_snippets')
		jsfiles = [fn for fn in os.listdir(defaultdir) if fn.endswith('.js')]
		for fn in jsfiles:
			cosni = CodeSnippet()

			cosni.name = os.path.basename(fn)
			cosni.name = cosni.name[:-3] #Remove .js from name

			if CodeSnippet().all().filter('name =', cosni.name).count(limit=1):
				continue

			cosni.description = cosni.name

			with open(os.path.join(defaultdir, fn), 'r') as f:
				cosni.code = f.read()

			cosni.put()

class ViewHandler(webapp.RequestHandler):
	def get(self):
		id = self.request.get('id')
		codesnippet = CodeSnippet.get(db.Key(encoded=id))
		d = {
				'codesnippet': extend_codesnippet(codesnippet)
			}

		self.response.out.write(rendertemplate('viewvis.html', **d))

class CodeViewHandler(webapp.RequestHandler):
	def get(self):
		id = self.request.get('id')
		cosni = CodeSnippet.get(id)
		self.response.out.write(cosni.code.strip())


def main():
	logging.getLogger().setLevel(logging.DEBUG)
	application = webapp.WSGIApplication([
		('/', IndexHandler),
		('/view', ViewHandler),
		('/codeview', CodeViewHandler),
		('/preload', PreloadHandler)
		], debug=True)
	util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
