import requests

HOST = '0.0.0.0'
PORT = '8080'
PATH = '/kv'
URL = 'http://'+HOST+':'+PORT+PATH
HEADER = {'Content-Type': 'application/json'}


def test_handle_post_and_get():
	KEY = 'My_name1'
	VALUE = {"age": 30, "pass":"IDI"}
	data = {"key": KEY, "value": VALUE}

	r = requests.post(URL, headers = HEADER, json=data)
	assert r.status_code == 200
	assert r.json() == [KEY, VALUE]

	r = requests.get(URL+'/'+KEY)
	assert r.status_code == 200
	assert r.json() == [KEY, VALUE]

	r = requests.get(URL+'/'+"NOT_EXISTED_KEY")
	assert r.status_code == 404

	r = requests.post(URL, headers = HEADER, json=data)
	assert r.status_code == 409 # existed key


def test_handle_post_and_delete():
	KEY = 'My_name2'
	VALUE = {"age": 30, "pass":"IDI"}
	data = {"key": KEY, "value": VALUE}

	r = requests.post(URL, headers = HEADER, json=data)
	assert r.status_code == 200
	assert r.json() == [KEY, VALUE]

	r = requests.delete(URL + "/" + KEY)
	assert r.status_code == 200
	assert r.json() == [KEY, VALUE]

	r = requests.delete(URL+'/'+"NOT_EXISTED_KEY")
	assert r.status_code == 404


def test_handle_post_and_put():
	KEY = 'My_name3'
	VALUE = {"age": 30, "pass":"IDI"}
	UPDATED_VALUE = {"age": 31, "pass":"SOS"}
	data = {"key": KEY, "value": VALUE}
	upd_data = {"value": UPDATED_VALUE}

	r = requests.post(URL, headers = HEADER, json=data)
	assert r.status_code == 200
	assert r.json() == [KEY, VALUE]

	r = requests.put(URL + "/" + KEY, headers = HEADER, json=upd_data)
	assert r.status_code == 200
	assert r.json() == [KEY, UPDATED_VALUE]

	r = requests.get(URL+'/'+KEY)
	assert r.status_code == 200
	assert r.json() == [KEY, UPDATED_VALUE]

	r = requests.put(URL+'/'+"NOT_EXISTED_KEY", json=upd_data)
	assert r.status_code == 404

	r = requests.put(URL+'/'+"INVALID_JSON", json="invalid_JSON")
	assert r.status_code == 400
