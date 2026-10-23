import os
import glob

def build_bundle():
    base_dir = r"C:\Users\smhis\.gemini\antigravity\scratch\islamic_app"
    desktop_onedrive = r"C:\Users\smhis\OneDrive\Masaüstü\Beyan_Claude_Test_Paketi.md"
    desktop_direct = r"C:\Users\smhis\Desktop\Beyan_Claude_Test_Paketi.md"

    files_to_pack = []

    # 1. pubspec.yaml
    pubspec = os.path.join(base_dir, "pubspec.yaml")
    if os.path.exists(pubspec):
        files_to_pack.append(pubspec)

    # 2. lib/**/*.dart
    lib_darts = sorted(glob.glob(os.path.join(base_dir, "lib", "**", "*.dart"), recursive=True))
    files_to_pack.extend(lib_darts)

    # 3. test/**/*.dart
    test_darts = sorted(glob.glob(os.path.join(base_dir, "test", "**", "*.dart"), recursive=True))
    files_to_pack.extend(test_darts)

    lines = []
    lines.append("# Beyân Flutter Uygulaması - Tam Kaynak Kod ve Kapsamlı Bug-Audit Test Paketi\n\n")
    lines.append("Bu paket Claude tarafından tüm özelliklerin derinlemesine bug audit, güvenlik ve QA incelemesi için güncellenmiştir.\n\n")
    lines.append(f"Toplam Dosya Sayısı: {len(files_to_pack)}\n\n")
    lines.append("---\n\n")

    for fpath in files_to_pack:
        rel_path = os.path.relpath(fpath, base_dir).replace("\\", "/")
        ext = os.path.splitext(fpath)[1].replace(".", "")
        if ext == "yaml" or ext == "yml":
            lang = "yaml"
        elif ext == "dart":
            lang = "dart"
        else:
            lang = ""

        lines.append(f"## Dosya: {rel_path}\n\n```{lang}\n")
        with open(fpath, "r", encoding="utf-8", errors="replace") as f:
            lines.append(f.read())
        lines.append("\n```\n\n---\n\n")

    content = "".join(lines)

    for target in [desktop_onedrive, desktop_direct]:
        try:
            target_dir = os.path.dirname(target)
            if os.path.exists(target_dir):
                with open(target, "w", encoding="utf-8") as out:
                    out.write(content)
                print(f"Başarıyla kaydedildi: {target} ({len(content)} karakter)")
        except Exception as e:
            print(f"Hata ({target}): {e}")

if __name__ == "__main__":
    build_bundle()
