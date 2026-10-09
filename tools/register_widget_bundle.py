import time
import jwt
import requests
import json
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

KEY_ID = "4U3CSYC7QK"
ISSUER_ID = "fd9e75e5-503b-4b43-9a30-15ff78d5219c"
KEY_PATH = r"C:\Users\smhis\Downloads\AuthKey_4U3CSYC7QK.p8"

with open(KEY_PATH, "r") as f:
    PRIVATE_KEY = f.read()

def get_token():
    now = int(time.time())
    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    payload = {"iss": ISSUER_ID, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, PRIVATE_KEY, algorithm="ES256", headers=headers)

token = get_token()
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

# 1. Register Widget Bundle ID if not exists
payload = {
    "data": {
        "type": "bundleIds",
        "attributes": {
            "identifier": "com.smhisk60.beyan.BeyanWidget",
            "name": "Beyan Widget",
            "platform": "UNIVERSAL"
        }
    }
}

print("Registering Widget Bundle ID...")
r = requests.post("https://api.appstoreconnect.apple.com/v1/bundleIds", headers=headers, json=payload, verify=False)
print("Status:", r.status_code)
if r.status_code in [201, 409]:
    print("Widget Bundle ID registered (or already exists).")
    if r.status_code == 201:
        widget_bundle_id = r.json()["data"]["id"]
        print("Created Widget Bundle ID:", widget_bundle_id)
else:
    print(r.text)
