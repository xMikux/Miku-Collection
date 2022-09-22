from flask import Flask, request
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)

class Heartbeat(Resource):
   def get(self):
      return { "heartbeat" : "OK" }

api.add_resource(Heartbeat, '/')

if __name__ == '__main__':
   app.run('0.0.0.0','80')
