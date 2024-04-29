import unittest
import main as tested_app
import json


class FlaskAppTests(unittest.TestCase):

    def setUp(self):
        tested_app.app.config['TESTING'] = True
        self.app = tested_app.app.test_client()

    def test_get_root_endpoint(self):
        r = self.app.get('/')
        self.assertEqual(json.loads(r.data.decode('utf-8')), {"result":"WELCOME!"})

    def test_post_root_endpoint(self):
        r = self.app.get('/')
        self.assertEqual(r.status_code, 200)

    def test_get_status_endpoint(self):
        r = self.app.get('/status')
        self.assertEqual(json.loads(r.data.decode('utf-8')), {'result': 'success'})

    def test_post_status_endpoint(self):
        r = self.app.get('/status')
        self.assertEqual(r.status_code, 200)


if __name__ == '__main__':
    unittest.main()