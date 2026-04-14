import json, urllib.request
url = "https://hub.docker.com/v2/repositories/bitnami/pgpool/tags?page_size=10"
try:
    req = urllib.request.urlopen(url)
    res = json.loads(req.read().decode('utf-8'))
    for tag in res.get('results', []):
        print(tag['name'])
except Exception as e:
    print("Error:", e)