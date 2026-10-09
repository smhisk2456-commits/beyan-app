import time
import jwt
import requests
import json
import base64
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

CERT_ID = "AT3HZ29FH2" # Apple Distribution: SEMIH ISKENDER
APP_BUNDLE_ID = "V43UYX48YW" # com.smhisk60.beyan
WIDGET_BUNDLE_ID = "TYA682R3B6" # com.smhisk60.beyan.BeyanWidget

def create_profile(name, bundle_id, filename):
    payload = {
        "data": {
            "type": "profiles",
            "attributes": {
                "name": name,
                "profileType": "IOS_APP_STORE"
            },
            "relationships": {
                "bundleId": {
                    "data": {"type": "bundleIds", "id": bundle_id}
                },
                "certificates": {
                    "data": [{"type": "certificates", "id": CERT_ID}]
                }
            }
        }
    }
    print(f"Creating profile '{name}' for bundle ID {bundle_id}...")
    r = requests.post("https://api.appstoreconnect.apple.com/v1/profiles", headers=headers, json=payload, verify=False)
    print("Status:", r.status_code)
    if r.status_code == 201:
        p_data = r.json()["data"]
        p_id = p_data["id"]
        p_content = p_data["attributes"]["profileContent"]
        raw_bytes = base64.b64decode(p_content)
        with open(filename, "wb") as f:
            f.write(raw_bytes)
        print(f"SUCCESS! Saved {filename} (ID: {p_id}, Size: {len(raw_bytes)} bytes)")
        return p_id
    else:
        print(r.text)
        return None

# 1. Main App Profile
create_profile("Beyan AppStore Profile", APP_BUNDLE_ID, "Beyan_AppStore.mobileprovision")

# 2. Widget Profile
create_profile("Beyan Widget AppStore Profile", WIDGET_BUNDLE_ID, "Beyan_Widget_AppStore.mobileprovision")
