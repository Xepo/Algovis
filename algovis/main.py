#!/usr/bin/env python
# Algovis
# Author: Isaiah Damron <Isaiah+Algovis at Trifault dot net>

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

def getvisurl(cosni):
	return '/view?id=%s' % (cosni.key())
def getcodeurl(cosni):
	return '/codeview?id=%s' % (cosni.key())
def getindexurl():
	return '/'
def geturlfcns():
	return {'getvisurl': getvisurl,
			'getcodeurl': getcodeurl,
			'getindexurl': getindexurl
			}

mylookup = TemplateLookup(directories=[os.path.join('Templates')])
def rendertemplate(templatename, **kwargs):
	try:
		kwargs.update(geturlfcns())
		temp = mylookup.get_template(templatename)
		return temp.render(**kwargs)
	except:
		logging.error("Error while processing templates!")
		logging.error(mako.exceptions.text_error_template().render())
		raise



class IndexHandler(webapp.RequestHandler):
    def get(self):
	d = {'codesnippets': CodeSnippet.all()}
	self.response.out.write(rendertemplate('viewindex.html', **d))

class PreloadHandler(webapp.RequestHandler):
	def get(self):
		defaultdir = os.path.join(os.path.dirname(__file__), 'default_snippets')
		jsfiles = [fn for fn in os.listdir(defaultdir) if fn.endswith('.js')]
		for fn in jsfiles:
			cosni = CodeSnippet()

			cosni.name = os.path.basename(fn)
			cosni.name = cosni.name[:-3] #Remove .js from name
			cosni.description = cosni.name

			for storedcosni in CodeSnippet().all().filter('name =', cosni.name):
				self.response.out.write("Deleting %s<br/>" % (cosni.name))
				storedcosni.delete()

			with open(os.path.join(defaultdir, fn), 'r') as f:
				cosni.code = f.read()

			self.response.out.write("Storing %s<br/>" % (cosni.name))
			cosni.put()

class ViewHandler(webapp.RequestHandler):
	def get(self):
		id = self.request.get('id')
		codesnippet = CodeSnippet.get(db.Key(encoded=id))
		d = {
				'codesnippet': codesnippet
			}

		self.response.out.write(rendertemplate('viewvis.html', **d))

class CodeViewHandler(webapp.RequestHandler):
	def get(self):
		id = self.request.get('id')
		cosni = CodeSnippet.get(id)
		self.response.out.write(cosni.code.strip())

class TestViewHandler(webapp.RequestHandler):
	def post(self):
		d = { 
				'testcode': self.request.get('testcode', '"No code given"')
				}
		self.response.out.write(rendertemplate('viewtestcode.html', **d))


def main():
	logging.getLogger().setLevel(logging.DEBUG)
	application = webapp.WSGIApplication([
		('/', IndexHandler),
		('/view', ViewHandler),
		('/codeview', CodeViewHandler),
		('/preload', PreloadHandler),
		('/testcode', TestViewHandler),
		], debug=True)
	util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
