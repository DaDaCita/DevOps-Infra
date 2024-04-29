import json
import os

from flask import Flask
from flask import request
app = Flask(__name__)

RESPONSE = RESPONSE = os.environ["RESPONSE"]

@app.route('/', methods=['GET'])
def root():
	welcome = {
		'result': 'WELCOME!'
	}

	return json.dumps(welcome)

@app.route("/status", methods=['GET'])
def status():
	ret = {
		'result': RESPONSE
	}

	return json.dumps(ret)

if __name__ == "__main__":
	app.run()
