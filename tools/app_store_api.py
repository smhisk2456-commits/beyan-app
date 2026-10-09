import time
import jwt
import requests
import json
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

KEY_ID = "4U3CSYC7QK"
ISSUER_ID = "fd9e75e5-503b-4b43-9a30-15ff78d5219c"
KEY_PATH = r"C:\Users\smhis\Downloads\AuthKey_4U3CSYC7QK.p8"

with open(KEY_PATH, "r") as f:
    PRIVATE_KEY = f.read()

def get_token():
    now = int(time.time())
    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT"
    }
    payload = {
        "iss": ISSUER_ID,
        "exp": now + 20 * 60,
        "aud": "appstoreconnect-v1"
    }
    return jwt.encode(payload, PRIVATE_KEY, algorithm="ES256", headers=headers)

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

token = get_token()
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

print("=== CHECKING APPS ===")
r = requests.get("https://api.appstoreconnect.apple.com/v1/apps", headers=headers, verify=False)
print("Status:", r.status_code)
if r.status_code == 200:
    apps = r.json().get("data", [])
    for a in apps:
        print(f"App: {a['attributes']['name']} (Bundle ID: {a['attributes']['bundleId']})")
else:
    print(r.text)

print("\n=== CHECKING CERTIFICATES ===")
r = requests.get("https://api.appstoreconnect.apple.com/v1/certificates", headers=headers, verify=False)
print("Status:", r.status_code)
if r.status_code == 200:
    certs = r.json().get("data", [])
    print(f"Found {len(certs)} certificates.")
    for c in certs:
        print(f"Cert: {c['attributes']['name']} - Type: {c['attributes']['certificateType']} - Expiry: {c['attributes']['expirationDate']}")
else:
    print(r.text)

print("\n=== CHECKING BUNDLE IDS ===")
r = requests.get("https://api.appstoreconnect.apple.com/v1/bundleIds", headers=headers, verify=False)
print("Status:", r.status_code)
if r.status_code == 200:
    bundles = r.json().get("data", [])
    print(f"Found {len(bundles)} bundle IDs.")
    for b in bundles:
        print(f"Bundle ID: {b['attributes']['identifier']} - Name: {b['attributes']['name']}")
else:
    print(r.text)

print("\n=== CHECKING PROFILES ===")
r = requests.get("https://api.appstoreconnect.apple.com/v1/profiles", headers=headers, verify=False)
print("Status:", r.status_code)
if r.status_code == 200:
    profiles = r.json().get("data", [])
    print(f"Found {len(profiles)} profiles.")
    for p in profiles:
        print(f"Profile: {p['attributes']['name']} - Type: {p['attributes']['profileType']} - State: {p['attributes']['profileState']}")
else:
    print(r.text)
