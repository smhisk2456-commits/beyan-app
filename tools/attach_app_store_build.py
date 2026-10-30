import time
import jwt
import requests
import urllib3
import re
import sys

urllib3.disable_warnings()

SECRETS_FILE = r"C:\Users\smhis\Desktop\Beyan_TestFlight_Secrets.txt"

def load_credentials():
    with open(SECRETS_FILE, "r", encoding="utf-8") as f:
        text = f.read()

    m_key = re.search(r"4\. Secret Name: APP_STORE_CONNECT_PRIVATE_KEY\s+Value:\s+(-----BEGIN PRIVATE KEY-----.*?-----END PRIVATE KEY-----)", text, re.DOTALL)
    if not m_key:
        raise ValueError("APP_STORE_CONNECT_PRIVATE_KEY bulunamadı.")
    
    private_key = m_key.group(1).strip()
    key_id = "4U3CSYC7QK"
    issuer_id = "fd9e75e5-503b-4b43-9a30-15ff78d5219c"
    return key_id, issuer_id, private_key

def get_token(key_id, issuer_id, private_key):
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1"
    }
    headers = {
        "alg": "ES256",
        "kid": key_id,
        "typ": "JWT"
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)

def attach_latest_build(app_id="6820956134"):
    key_id, issuer_id, private_key = load_credentials()
    token = get_token(key_id, issuer_id, private_key)
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    print("1. İncelemeye hazırlanan sürüm taranıyor...")
    r_ver = requests.get(f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appStoreVersions", headers=headers, verify=False)
    versions = r_ver.json().get("data", [])
    
    target_version = None
    for v in versions:
        if v["attributes"]["appStoreState"] == "PREPARE_FOR_SUBMISSION":
            target_version = v
            break
            
    if not target_version:
        print("HATA: PREPARE_FOR_SUBMISSION durumunda bir sürüm bulunamadı!")
        return False
        
    v_id = target_version["id"]
    v_string = target_version["attributes"]["versionString"]
    print(f" -> Hedef sürüm bulundu: {v_string} (ID: {v_id})")

    print("2. En güncel geçerli build taranıyor...")
    r_builds = requests.get(f"https://api.appstoreconnect.apple.com/v1/builds?filter[app]={app_id}&sort=-uploadedDate&limit=5", headers=headers, verify=False)
    builds = r_builds.json().get("data", [])
    
    target_build = None
    for b in builds:
        if b["attributes"]["processingState"] == "VALID":
            target_build = b
            break
            
    if not target_build:
        print("HATA: VALID durumunda hiçbir derleme bulunamadı!")
        return False
        
    b_id = target_build["id"]
    b_version = target_build["attributes"]["version"]
    print(f" -> En son geçerli derleme: Build {b_version} (ID: {b_id})")

    print(f"3. Build {b_version}, {v_string} sürümüne bağlanıyor...")
    payload = {
        "data": {
            "id": b_id,
            "type": "builds"
        }
    }
    r_patch = requests.patch(
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{v_id}/relationships/build",
        headers=headers,
        json=payload,
        verify=False
    )
    
    if r_patch.status_code == 204:
        print(f"BAŞARILI! Build {b_version} doğrudan Sürüm {v_string}'e bağlandı. Tarayıcıda F5 yapabilirsiniz.")
        return True
    else:
        print(f"Hata oluştu ({r_patch.status_code}):", r_patch.text)
        return False

if __name__ == "__main__":
    attach_latest_build()
