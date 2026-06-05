# 🦆 BUKU KEHIDUPAN PORTVOICE — Asuhan Kak Opus

> Buku terpisah dari Buku Orkestra Web (xiaopinpinmusic.com).
> Dibuat dari 0 oleh Kak Opus, 4 Juni 2026, atas mandat Conductor Ko Pinpin:
> "bikin buku terpisah mulai dari 0, serap semua di repo deploy portvoice."

---

## 1. IDENTITAS & MISI

**PortVoice** = aplikasi macOS aksesibilitas. Saat device eksternal
(USB / iPhone / HDMI / SSD / audio interface / card reader) connect atau
disconnect, Mac LANGSUNG BICARA (TTS) — biar pengguna tau tanpa harus lihat
layar / buka Finder / tanya orang.

**Lahir dari keresahan nyata Ko Pinpin** (tunet): "kenapa Mac bisa nunjukin
visual kalau device connect, tapi gak bisa langsung BICARA?" — ORIGIN.md.

**Misi (ala Om Steve & Om Jony):** teknologi untuk SEMUA orang. Lahir dari
pengalaman tunet, tapi berguna universal — musisi (audio interface), kreator
(card reader/SSD), power user, keluarga, siapapun yang mau konfirmasi tanpa
melihat layar.

- **Creator (nama publik):** Xiao Pinpin
- **Maskot:** Bekcil, si bebek kecil ceria 🦆 (the cheerful little duck helper)
- **Lisensi:** MIT, Copyright (c) 2026 Xiao Pinpin
- **Slogan keluarga:** "Made with patience. Finished with peace." Soli Deo Gloria.

---

## 2. LOKASI & PEMISAHAN (ANTI-LALI — PENTING!)

- **PortVoice:** /Volumes/Xiao Pinpin Music/Software Claude/portvoice/
  (folder "Software Claude" — PAKAI SPASI)
- **Repo Orkestra Web:** /Volumes/Xiao Pinpin Music/Software/Claude/
  (folder "Software/Claude" — PAKAI SLASH)
- JANGAN TUKAR/BINGUNG. Dua repo git TERPISAH, masing-masing punya .git sendiri.
- PortVoice JANGAN digabung fisik ke repo orkestra (nested git = kacau).
  PortVoice = "project asuhan Kak Opus" — dirawat terpisah, repo sendiri.

---

## 3. STATUS SEKARANG (per 4 Juni 2026)

- **Versi:** v0.7.1 Internal Alpha
- **Confirmed jalan:** launch via `swift run`, launch sebagai PortVoice.app,
  DMG installer bisa dibuat, interface aksesibel VoiceOver, USB connect/
  disconnect announce, storage volume detection + named announce
  (contoh: "Cadangan connected").
- **Build DMG:** dist/PortVoice-0.x.x.dmg
- **Sudah ada:** About PortVoice window, menu bar mode, branding Bekcil.

---

## 4. ARSITEKTUR KODE (10 file Swift, ~454 baris)

- **USBMonitor.swift** (115) — IOKit IONotification, deteksi USB connect/
  disconnect (handleUSBConnected/Disconnected, drain, callback).
- **StorageMonitor.swift** (70) — monitor volume storage (checkVolumes,
  currentVolumeNames), named announce.
- **SpeechService.swift** (14) — AVSpeechSynthesizer (TTS speak).
- **AppState.swift** (28) — @Published isEnabled, statusMessage,
  notificationMode (enum NotificationMode).
- **NotificationCoordinator.swift** — routing event device → speech.
- **MenuBarController.swift** — UI menu bar.
- **ContentView.swift** — window SwiftUI aksesibel (toggle enable/disable).
- **AppDelegate.swift** + **PortVoiceApp.swift** — entry point app.
- **AboutWindowController.swift** — About window (versi, creator, Bekcil).

**Stack:** Swift + Swift Package Manager (Package.swift), target .macOS(.v14)
Sonoma+, Apple Silicon. IOKit (USB) + NSWorkspace (storage) + AVSpeech (TTS)
+ SwiftUI + menu bar.

**Scripts/:** build-app.sh (bikin .app), build-dmg.sh (bikin DMG),
uninstall-portvoice.sh.

---

## 5. RENCANA HARGA & DISTRIBUSI (mandat Ko Pinpin 4 Juni 2026)

Tahap 1 — **bagi GRATIS ke keluarga & temen dekat dulu** (uji + berkat).

Model harga publik nanti:
- 🎁 **Gratis** — keluarga & teman dekat
- 💝 **Rp 25.000** — orang dekat yang mau support
- 💰 **Rp 50.000** — umum (apresiasi), **update lifetime**
- ⏱️ **Trial 15 hari** — coba sebelum beli

Filosofi harga: bukan cari kaya, tapi APRESIASI + bisa terus dirawat.
Selaras "bintang 5 harga kaki 5".

---

## 6. ROADMAP

Sudah lewat: V0.5 alpha DMG → V0.6 app mode → V0.7 menu bar + About window.

Berikutnya menuju publik:
1. Stabilkan fitur inti (USB/storage/HDMI/iPhone announce) + uji tunet nyata.
2. **Apple notarization + code signing** (WAJIB sebelum sebar publik).
3. Sistem trial 15 hari + lisensi (25k/50k).
4. Halaman web download (nanti, setelah notarize) — mungkin
   xiaopinpinmusic.com/portvoice/.

---

## 7. ⚠️ CATATAN KRITIS MAINTENANCE (Kak Opus WAJIB ingat)

1. **APPLE GATEKEEPER:** Sebelum sebar ke umum/web, app WAJIB di-sign +
   notarize (butuh Apple Developer account ~$99/thn). Kalau tidak, macOS
   blok "developer tak dikenal" — TEMBOK BESAR buat tunet. Jangan sebar
   DMG publik sebelum notarize (RELEASE_STRATEGY.md: "Do not upload DMG
   as public unrestricted download yet").
2. **Kerja LOKAL** via Macos:Shell / Desktop Commander. JANGAN create_file
   (container). Sama seperti aturan orkestra.
3. **Repo terpisah** — commit ke git PortVoice sendiri, JANGAN ke repo web.
4. **Masih digarap bareng Pak GPT** — Kak Opus rawat/bantu, tapi hormati
   kerja yang sudah ada. Cek git log dulu sebelum ubah.
5. **VoiceOver-first:** tiap perubahan UI WAJIB tetap aksesibel VoiceOver
   (ini app TUNET, aksesibilitas = nyawa, bukan fitur tambahan).

---

## 8. SOP SESI BARU (kalau Kak Opus rawat PortVoice)

1. Baca buku ini (HANDOFF_OPUS_Buku_Kehidupan_PortVoice.md).
2. cd ke /Volumes/Xiao Pinpin Music/Software Claude/portvoice/
3. Cek git log + status (lihat kerja terbaru Pak GPT/Ko).
4. Baca STATUS.md + NEXT.md + release notes terbaru.
5. Baru kerja, per movement (investigasi → eksekusi → verify → commit).

---

*Dibuat dengan kasih oleh Kak Opus (Concertmaster) untuk Conductor Ko Pinpin.*
*PortVoice — biar tiap colokan kebaca, tiap tunet tak perlu menebak.*
*Bekcil 🦆 siap membantu. Soli Deo Gloria.*
