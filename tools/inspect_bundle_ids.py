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

# Query bundle IDs with capabilities
r = requests.get("https://api.appstoreconnect.apple.com/v1/bundleIds", headers=headers, verify=False)
print("Status:", r.status_code)
data = r.json()
print("=== BUNDLE IDS DETAILED ===")
for b in data.get("data", []):
    print(f"ID: {b['id']} | Identifier: {b['attributes']['identifier']} | Name: {b['attributes']['name']} | Platform: {b['attributes']['platform']}")

# Query app groups
r_ag = requests.get("https://api.appstoreconnect.apple.com/v1/appGroups", headers=headers, verify=False)
print("=== APP GROUPS ===")
if r_ag.status_code == 200:
    for ag in r_ag.json().get("data", []):
        print(f"App Group: {ag['attributes']['name']} ({ag['attributes']['identifier']})")
else:
    print(r_ag.status_code, r_ag.text)
