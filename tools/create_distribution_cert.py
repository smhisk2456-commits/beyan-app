import os
import subprocess
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

# 1. Generate RSA 2048 private key and CSR
KEY_FILE = "beyan_distribution_private.key"
CSR_FILE = "beyan_distribution.csr"
OPENSSL_PATH = r"C:\Program Files\Git\usr\bin\openssl.exe"

if not os.path.exists(KEY_FILE):
    print("Generating RSA private key...")
    subprocess.run([OPENSSL_PATH, "genrsa", "-out", KEY_FILE, "2048"], check=True)

print("Generating CSR...")
subprocess.run([
    OPENSSL_PATH, "req", "-new", "-key", KEY_FILE, "-out", CSR_FILE,
    "-subj", "/emailAddress=smhisk2456@gmail.com, CN=Semih Iskender, C=TR"
], check=True)

with open(CSR_FILE, "r") as f:
    csr_content = f.read()

print("CSR Content length:", len(csr_content))

# 2. Call Apple API to create Distribution certificate
payload = {
    "data": {
        "type": "certificates",
        "attributes": {
            "certificateType": "DISTRIBUTION",
            "csrContent": csr_content
        }
    }
}

print("Requesting Distribution Certificate from Apple...")
r = requests.post("https://api.appstoreconnect.apple.com/v1/certificates", headers=headers, json=payload, verify=False)
print("Status Code:", r.status_code)
print("Response:", r.text)

if r.status_code == 201:
    cert_data = r.json()["data"]
    cert_id = cert_data["id"]
    cert_content = cert_data["attributes"]["certificateContent"]
    print(f"SUCCESS! Created Certificate ID: {cert_id}")
    
    # Save the DER/CER file
    import base64
    der_bytes = base64.b64decode(cert_content)
    with open("beyan_distribution.cer", "wb") as f:
        f.write(der_bytes)
    print("Saved beyan_distribution.cer")
    
    # Convert to PEM
    subprocess.run([
        OPENSSL_PATH, "x509", "-inform", "DER", "-in", "beyan_distribution.cer",
        "-out", "beyan_distribution.pem"
    ], check=True)
    print("Converted to beyan_distribution.pem")
    
    # Export to .p12
    P12_PASSWORD = "beyan_password_2026"
    subprocess.run([
        OPENSSL_PATH, "pkcs12", "-export",
        "-inkey", KEY_FILE,
        "-in", "beyan_distribution.pem",
        "-out", "beyan_distribution.p12",
        "-password", f"pass:{P12_PASSWORD}"
    ], check=True)
    print("Exported beyan_distribution.p12 successfully!")
