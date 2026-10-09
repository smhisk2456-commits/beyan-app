import base64
import os

p12_path = "beyan_distribution.p12"
app_prov_path = "Beyan_AppStore.mobileprovision"
widget_prov_path = "Beyan_Widget_AppStore.mobileprovision"
p8_path = r"C:\Users\smhis\Downloads\AuthKey_4U3CSYC7QK.p8"

with open(p12_path, "rb") as f:
    p12_b64 = base64.b64encode(f.read()).decode("utf-8")

with open(app_prov_path, "rb") as f:
    app_prov_b64 = base64.b64encode(f.read()).decode("utf-8")

with open(widget_prov_path, "rb") as f:
    widget_prov_b64 = base64.b64encode(f.read()).decode("utf-8")

with open(p8_path, "r") as f:
    p8_content = f.read()

out_file = r"C:\Users\smhis\Desktop\Beyan_TestFlight_Secrets.txt"
with open(out_file, "w", encoding="utf-8") as f:
    f.write("=== BEYAN TESTFLIGHT GITHUB SECRETS ===\n\n")
    f.write("Bu değerleri GitHub'da Repository > Settings > Secrets and variables > Actions > New repository secret kısmına ekleyeceğiz:\n\n")
    
    f.write("1. Secret Name: APP_STORE_CONNECT_KEY_ID\n")
    f.write("Value: 4U3CSYC7QK\n\n")
    
    f.write("2. Secret Name: APP_STORE_CONNECT_ISSUER_ID\n")
    f.write("Value: fd9e75e5-503b-4b43-9a30-15ff78d5219c\n\n")
    
    f.write("3. Secret Name: P12_PASSWORD\n")
    f.write("Value: beyan_password_2026\n\n")
    
    f.write("4. Secret Name: APP_STORE_CONNECT_PRIVATE_KEY\n")
    f.write("Value:\n" + p8_content.strip() + "\n\n")
    
    f.write("5. Secret Name: BUILD_CERTIFICATE_BASE64\n")
    f.write("Value:\n" + p12_b64 + "\n\n")
    
    f.write("6. Secret Name: BUILD_PROVISION_PROFILE_BASE64\n")
    f.write("Value:\n" + app_prov_b64 + "\n\n")
    
    f.write("7. Secret Name: WIDGET_PROVISION_PROFILE_BASE64\n")
    f.write("Value:\n" + widget_prov_b64 + "\n\n")

print("Created", out_file)
