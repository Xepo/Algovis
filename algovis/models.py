from google.appengine.ext import db

class CodeSnippet(db.Model):
	name = db.StringProperty()
	description = db.StringProperty(multiline=True)
	code = db.TextProperty()
	date = db.DateTimeProperty(auto_now_add=True)
