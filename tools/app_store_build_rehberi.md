# App Store Connect – Sürüm Derlemesi (Build) Bağlama Rehberi

## Yaşanan Problem
App Store Connect web arayüzünde yeni bir sürüm (örn: `1.0.1 Prepare for Submission`) oluşturulduğunda, **Build** bölümü boş kalıp `Upload your builds using one of several tools` uyarısı verebilir ve arayüzde `+ Add Build` butonu görünmeyebilir. `Add for Review` tıklandığında ise `You must choose a build` hatası döner.

## Çözüm: App Store Connect REST API ile Doğrudan Bağlama
Apple'ın web arayüzündeki bu bug/kilitlenme durumunda, `tools/attach_app_store_build.py` betiği çalıştırılarak en son geçerli derleme doğrudan ilgili sürüme bağlanır.

### Gerekli Kimlik Bilgileri
- **APP_STORE_CONNECT_KEY_ID:** `4U3CSYC7QK`
- **APP_STORE_CONNECT_ISSUER_ID:** `fd9e75e5-503b-4b43-9a30-15ff78d5219c`
- **Private Key (`.p8`):** `C:\Users\smhis\Desktop\Beyan_TestFlight_Secrets.txt` dosyasından okunur.

### Otomasyon Betiği
`tools/attach_app_store_build.py` dosyası projeye kalıcı olarak kaydedilmiştir:
```bash
python tools/attach_app_store_build.py
```
Bu betik:
1. JWT oluşturur.
2. `PREPARE_FOR_SUBMISSION` durumundaki sürümü ve `VALID` olan en son derlemeyi bulur.
3. `PATCH /v1/appStoreVersions/{version_id}/relationships/build` uç noktasına istek atarak derlemeyi bağlar (`HTTP 204 No Content`).
4. Tarayıcıda `F5` yapıldığında derleme seçilmiş olarak ekrana gelir.
