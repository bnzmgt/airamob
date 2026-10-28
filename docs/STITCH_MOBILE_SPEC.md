# AiNARA Mobile — Complete UI Screen Audit & Google Stitch Design Specification
**Version:** 2.0 (Crisp Minimalist / Anti-Slop / Flat Border-Driven Design)  
**Target Platform:** Mobile App (iOS / Android, Viewport 390x844 / 375x812 pt)  
**Design System Principles:** Strict Typography, Zero-Shadow Flat Surfaces, Controlled 2-Tone Color Discipline, High Contrast  

---

## 1. Design System Tokens (Stitch Foundation)

### A. Strict Color Palette (Zero Rainbow Clutter)
- **Primary Blue:** `#3490F9` (Core brand color, AppBars, primary CTAs, active indicators, interactive links).
- **Secondary Accent:** `#F7A81E` (Warm Tangerine / Amber — secondary CTAs, attention/pending states, unsubmitted warnings, appreciation actions).
- **Neutral Canvas Background:** `#F8FAFC` (Slate 50 — clean, crisp off-white canvas).
- **Card & Surface Background:** `#FFFFFF` (Solid flat white).
- **Subtle Surface Tint:** `#F1F5F9` (Slate 100 — form input fills, metadata tags, stepper track).
- **Typography & Ink:**
  - **Text Primary:** `#0F172A` (Slate 900 — high-contrast, razor-sharp).
  - **Text Secondary:** `#475569` (Slate 600 — clear supporting text).
  - **Text Muted:** `#94A3B8` (Slate 400 — labels, timestamps, placeholders).
- **Functional Semantics (Minimal & Restrained):**
  - **Success / Completed:** `#10B981` (Emerald dot / badge text on neutral card).
  - **Attention / Pending:** `#F7A81E` (Secondary Tangerine dot / border / badge text).
  - **Destructive / Error:** `#EF4444` (Clean red for logout / removal actions only).

### B. Anti-Slop Structural Rules (Zero Shadows, Razor-Sharp Borders)
1. **Zero Drop Shadows:** No fuzzy drop shadows, no ambient blur, no elevation slop (`box-shadow: none`, `elevation: 0`).
2. **Crisp 1px Border Architecture:** Every card, container, and input is defined by a clean, razor-sharp `1px solid #E2E8F0` stroke.
3. **Consistent Corner Radii:**
   - Cards & Dialogs: `14px`
   - Inputs & Buttons: `12px`
   - Pills & Badges: `9999px` (Full pill)
4. **Typography:** Clean sans-serif (`Plus Jakarta Sans` or `Inter`), strict weight hierarchy (Regular 400, Medium 500, SemiBold 600, Bold 700).

---

## 2. Executive Screen Inventory (13 Screens)

| No | Screen Name | File Path | Role | Dominant Tone | Description |
|:---|:---|:---|:---|:---|:---|
| 1 | **Auth Gate / Splash** | `lib/main.dart` | All | `#3490F9` (Primary Blue) | Session check & auto-router with clean blue indicator |
| 2 | **Login Screen** | `lib/screens/auth/login_screen.dart` | Guest | `#3490F9` (Primary Blue) | Flat authentication form, server modal, outlined LANTANG CTA |
| 3 | **Student Home** | `lib/screens/student/student_home_screen.dart` | Student | `#3490F9` & `#F7A81E` | Flat status card, LANTANG banner, recent history feed |
| 4 | **Submit Daily Report** | `lib/screens/student/submit_report_screen.dart` | Student | `#3490F9` (Primary Blue) | Clean study log inputs, reflection textareas, 1px dashed photo upload |
| 5 | **Edit Daily Report** | `lib/screens/student/edit_report_screen.dart` | Student | `#3490F9` (Primary Blue) | Pre-filled report editor, photo preview/replace, flat CTAs |
| 6 | **Student Reports List** | `lib/screens/student/student_reports_list_screen.dart` | Student | `#3490F9` (Primary Blue) | Infinite feed, clean status dot badges, floating action button |
| 7 | **Submit Incident (LANTANG)** | `lib/screens/student/submit_incident_screen.dart` | Student | `#3490F9` & `#F7A81E` | Anti-bullying report, anonymity toggle, secret ticket dialog |
| 8 | **Student Incident History** | `lib/screens/student/student_incident_history_screen.dart` | Student | `#3490F9` (Primary Blue) | Protected incident list, status pills, TPPK resolution callout |
| 9 | **Track Incident (Public)** | `lib/screens/safeguarding/track_incident_screen.dart` | Public/Guest | `#3490F9` (Primary Blue) | No-login ticket tracker, 4-stage flat stepper, committee notes |
| 10 | **Parent Home** | `lib/screens/parent/parent_home_screen.dart` | Parent | `#3490F9` & `#F7A81E` | Connected child cards, filter bar, flat PDF/CSV exports, praise CTA |
| 11 | **Child Reports Screen** | `lib/screens/parent/child_reports_screen.dart` | Parent | `#3490F9` (Primary Blue) | Dedicated child log archive, date filter, flat export buttons |
| 12 | **Report Detail Screen** | `lib/screens/reports/report_detail_screen.dart` | Dual | `#3490F9` & `#F7A81E` | Full notes, reflection callouts, photo lightbox, AI guidance, praise sheet |
| 13 | **Profile & Account** | `lib/screens/profile/profile_screen.dart` | Dual | `#3490F9` (Primary Blue) | Flat identity card, contact form, password change, logout alert |

---

## 3. Screen-by-Screen Breakdown & Google Stitch Prompts

---

### SCREEN 01: Login Screen (Masuk Aplikasi)
- **Role / Target User:** Siswa, Orang Tua, dan Publik sebelum login.
- **Layout Structure:**
  - **App Canvas:** Flat `#F8FAFC`, zero shadow.
  - **Top Bar:** Transparent, subtle DNS settings icon button at top-right.
  - **Brand Hero Header:**
    - Minimalist rounded logo container (56x56px, flat white, `1px solid #E2E8F0` border, `14px` radius) with graduation cap icon in Primary Blue `#3490F9`.
    - App Title: "AiNARA Mobile" (Bold 24px, `#0F172A`).
    - Subtitle: "Daily Study Report & Family Connection" (13px, `#64748B`).
  - **Alert Banner (Conditional):**
    - Flat `#FEF6E8` container, `1px solid #FDE68A`, text `#92400E` for login warning messages.
  - **Form Controls:**
    1. `Alamat Email`: Flat white surface, `1px solid #E2E8F0` border, prefix email icon, rounded `12px`, placeholder `nama@sekolah.sch.id`.
    2. `Kata Sandi`: Flat white surface, `1px solid #E2E8F0` border, prefix lock icon, obscure text, rounded `12px`.
  - **Action Buttons:**
    - Primary CTA: "Masuk Aplikasi" (Solid Primary Blue `#3490F9`, bold white text, height 50px, zero shadow).
    - Safeguarding Action: "Lacak Tiket Aduan LANTANG (Tanpa Login)" (Flat white background, `1.5px solid #3490F9` border, text `#3490F9`, shield icon).
    - Server Indicator: Clean monospace text button at bottom: "Server: ainara.dstr.biz.id".
  - **Modal Dialog (Pengaturan Server Backend):**
    - Flat white dialog, `1px solid #E2E8F0`, zero shadow.
    - Preset chips: "Valet / Web", "Android Emulator", "Localhost:8000" in flat `#F1F5F9`.
    - Button: "Uji Respon Koneksi" (Outlined `#3490F9`).
    - Dialog actions: "Reset Default" (Text red) and "Simpan" (Solid `#3490F9`).

> **Google Stitch Prompt Narrative:**
> ```text
> Clean, modern mobile login screen for "AiNARA Mobile". Strict 2-tone minimalist EdTech design system, zero drop shadows, crisp 1px borders, mobile viewport 390x844. 
> Canvas background in clean off-white (#F8FAFC). 
> Minimal brand header: a sharp 56x56px white square container with 1px solid #E2E8F0 border and 14px radius, displaying a sharp Primary Blue graduation cap icon (#3490F9). Title "AiNARA Mobile" in 24px bold Slate-900 typography (#0F172A), subtitle "Daily Study Report & Family Connection" in muted slate (#64748B). 
> Form with 2 input fields: "Alamat Email" with email prefix icon and "Kata Sandi" with lock prefix icon, both with flat white backgrounds, crisp 1px solid #E2E8F0 borders, and 12px corners. 
> Primary full-width CTA button "Masuk Aplikasi" in solid Primary Blue (#3490F9), zero elevation, with bold white text. 
> Below it, a flat outlined button with shield icon: "Lacak Tiket Aduan LANTANG (Tanpa Login)" with 1.5px solid #3490F9 border and #3490F9 text. 
> Flat, anti-slop aesthetic, razor-sharp contrast, zero blur.
> ```

---

### SCREEN 02: Student Home Screen (Beranda Siswa)
- **Role / Target User:** Siswa yang sudah login.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "AiNARA Siswa", actions: Profile icon, Logout icon. Flat elevation.
  - **Greeting Card:**
    - Flat white card, `1px solid #E2E8F0` border, `14px` radius, zero shadow.
    - Avatar with clean Primary Blue `#3490F9` ring, greeting "Assalamu’alaikum,", student name "[Nama Siswa]" (Bold 16px, `#0F172A`).
  - **Today's Report Status Card:**
    - Flat white card, `1px solid #E2E8F0` border, zero shadow.
    - Header: "Laporan Belajar Hari Ini" + Minimal Status Dot:
      - *Submitted:* Minimal green badge with dot `● Sudah Kirim` (`#10B981` text, `#F1F5F9` container).
      - *Unsubmitted:* Minimal secondary badge with dot `● Belum Lapor` (`#F7A81E` text, `#FEF6E8` container).
    - *Unsubmitted Content:* Informative text + Secondary CTA button "Isi Laporan Hari Ini" in solid Secondary Tangerine `#F7A81E` (zero shadow).
    - *Submitted Content:* Report snippet (3 lines) + Parent appreciation quote + Action row: Outlined button "Detail" + Solid button "Edit Laporan" (`#3490F9`).
  - **LANTANG Safeguarding Quick Card:**
    - Flat white card with `2px solid #3490F9` left accent border, `1px solid #E2E8F0` perimeter border, zero shadow.
    - Blue shield icon (`#3490F9`) + Title "Layanan Perlindungan LANTANG".
    - Description: "Mengalami atau melihat perundungan? Ceritakan secara aman, rahasia, atau anonim total."
    - Action Row: Primary Blue button "Buat Pengaduan" (`#3490F9`, flat white text) + Outlined button "Lacak Tiket" (`1px solid #3490F9`).
    - Link: "Lihat Riwayat Kasus Saya ›" in `#3490F9`.
  - **Recent History Feed Section:**
    - Header: "Riwayat Belajar Terakhir" + "Lihat Semua ›" link in `#3490F9`.
    - Flat white cards with `1px solid #E2E8F0` border: Book icon, title snippet, report date, chevron icon.

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile dashboard screen for "AiNARA - Student Home". Modern minimalist EdTech UI, zero shadows, sharp 1px borders, 390x844 viewport. 
> Flat Primary Blue top AppBar (#3490F9) with white title "AiNARA Siswa" and profile/logout action icons. 
> Body content on cool off-white canvas (#F8FAFC) with 16px padding:
> 1. Greeting Card: Flat white card with 1px solid #E2E8F0 border, avatar with Primary Blue ring (#3490F9), greeting "Assalamu’alaikum,", and student name "Ahmad Fauzan".
> 2. Daily Status Card: Flat white card with 1px solid #E2E8F0 border, header "Laporan Belajar Hari Ini", badge "● Belum Lapor" in clean tangerine badge (#FEF6E8 bg, #F7A81E text). Full-width flat CTA button "Isi Laporan Hari Ini" in solid Secondary Tangerine (#F7A81E), zero drop shadow.
> 3. Child Safeguarding Banner (LANTANG): Flat white card with 2px solid #3490F9 left border and 1px solid #E2E8F0 outline. Blue shield icon (#3490F9), title "Layanan Perlindungan LANTANG", subtitle about anti-bullying reporting, and two flat buttons: solid Primary Blue "Buat Pengaduan" (#3490F9) and outlined "Lacak Tiket".
> 4. Section "Riwayat Belajar Terakhir" with flat white list items showing dates, snippet text, and chevron arrows. No blur, no drop shadows.
> ```

---

### SCREEN 03: Submit Daily Report Screen (Isi Laporan Belajar Hari Ini)
- **Role / Target User:** Siswa mengisi laporan harian.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Isi Laporan Belajar Hari Ini" with back navigation.
  - **Form Fields (Flat White, `1px solid #E2E8F0` Border, Zero Shadow):**
    1. `Catatan Materi Belajar *`: 4-line textarea, placeholder "Tuliskan topik, materi, atau tugas yang dipelajari hari ini...".
    2. `Hal yang Membuat Senang 😊 (Opsional)`: 2-line textarea.
    3. `Kendala / Hal yang Membuat Jengkel 😤 (Opsional)`: 2-line textarea, label marked with subtle Secondary Tangerine `#F7A81E` dot.
    4. `Foto Bukti Belajar / Catatan 📷 (Opsional)`:
       - Empty state: 1px dashed border container in `#3490F9` with camera icon and text "Lampirkan Foto Catatan / Tugas".
       - Selected state: Flat white card showing image icon, filename, and clean delete icon.
  - **Submit Button:** Full-width flat button "Kirim Laporan Belajar" in solid Primary Blue `#3490F9`, zero shadow.

> **Google Stitch Prompt Narrative:**
> ```text
> Minimalist mobile form screen for "AiNARA - Submit Daily Study Report". Mobile viewport 390x844, zero shadows, clean 1px border architecture.
> Flat Primary Blue AppBar (#3490F9) with white text "Isi Laporan Belajar Hari Ini" and back arrow.
> Clean form on off-white background (#F8FAFC):
> 1. Label "Catatan Materi Belajar *" with a 4-line flat white textarea, 1px solid #E2E8F0 border, 12px corners, Slate-900 text.
> 2. Label "Hal yang Membuat Senang 😊 (Opsional)" with a 2-line textarea.
> 3. Label "Kendala / Hal yang Membuat Jengkel 😤 (Opsional)" with subtle tangerine accent (#F7A81E) and 2-line textarea.
> 4. Label "Foto Bukti Belajar / Catatan 📷 (Opsional)" with a flat 1px dashed Primary Blue upload box (#3490F9) and camera icon.
> Fixed bottom bar with a solid flat Primary Blue CTA button (#3490F9) labeled "Kirim Laporan Belajar" with bold white text, zero shadow.
> ```

---

### SCREEN 04: Edit Daily Report Screen (Edit Laporan Belajar)
- **Role / Target User:** Siswa mengoreksi laporan yang telah dikirim hari ini.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9` with title "Edit Laporan Belajar".
  - **Date Info Banner:** Flat `#F1F5F9` container, `1px solid #E2E8F0` border, calendar icon + "Tanggal Laporan: 2026-10-28".
  - **Content Input:** Flat white 5-line textarea with pre-filled content.
  - **Photo Evidence Management Card:**
    - Flat white card, `1px solid #E2E8F0` border, zero shadow.
    - Pre-loaded photo thumbnail (`height: 180px`, rounded 12px, border `1px solid #E2E8F0`).
    - Action Buttons: Outlined "Ganti Foto" (`1px solid #3490F9`, text `#3490F9`) + Outlined "Hapus Foto" (`1px solid #EF4444`, text `#EF4444`).
  - **Emotional Reflection Inputs:**
    - Flat textareas for happy moment 😊 and frustrated moment 😤.
  - **Submit Button:** Full-width flat button "Simpan Perubahan Laporan" in Primary Blue `#3490F9`.

> **Google Stitch Prompt Narrative:**
> ```text
> Clean mobile screen for "AiNARA - Edit Daily Study Report". Viewport 390x844, flat minimalist layout, zero drop shadows.
> AppBar in Primary Blue (#3490F9) with "Edit Laporan Belajar".
> Body:
> 1. Grey info banner (#F1F5F9) with 1px border showing "Tanggal Laporan: 2026-10-28".
> 2. Pre-filled 5-line text area with student study notes.
> 3. Flat Photo Card: Notebook image preview (180px height, 1px border) with two flat outlined buttons below: Primary Blue "Ganti Foto" (#3490F9) and red "Hapus Foto" (#EF4444).
> 4. Two clean reflection textareas for happy reflection and obstacles.
> 5. Full-width flat Primary Blue button "Simpan Perubahan Laporan" (#3490F9), zero elevation, high contrast.
> ```

---

### SCREEN 05: Student Reports List Screen (Semua Riwayat Belajar)
- **Role / Target User:** Siswa melihat seluruh arsip laporan terdahulu.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Semua Riwayat Belajar", refresh icon.
  - **Floating Action Button:** Flat pill button "+ Lapor Hari Ini" in solid Primary Blue `#3490F9` (`elevation: 0`, `border: 1px solid #2563EB`).
  - **Feed Stats Header:** "Total Laporan Terarsip: 42" • "Halaman 1 dari 5".
  - **Feed Cards (Flat White, `1px solid #E2E8F0` Border, Zero Shadow):**
    - Top row: Date with event note icon + Minimal Status Badge:
      - `● Positif` (`#10B981` dot, `#F1F5F9` background, `#0F172A` text).
      - `● Stabil` (`#3490F9` dot, `#F1F5F9` background).
      - `● Evaluasi` (`#F7A81E` dot, `#FEF6E8` background).
    - 2-line content excerpt.
    - Bottom row: Photo chip (`📷 Foto`) + Appreciation note + "Detail ›" link in `#3490F9`.

> **Google Stitch Prompt Narrative:**
> ```text
> Minimalist mobile feed screen for "AiNARA - Student Report History". Mobile viewport 390x844, zero shadows, flat 1px borders.
> Primary Blue top AppBar (#3490F9) with title "Semua Riwayat Belajar" and refresh icon.
> Floating action button at bottom right: flat pill-shaped Primary Blue button "+ Lapor Hari Ini" (#3490F9), zero blur.
> Feed header showing "Total Laporan Terarsip: 42" and "Halaman 1 dari 5".
> Vertical list of flat white cards with 14px radius and 1px solid #E2E8F0 border:
> Each card has:
> - Date "28 Okt 2026" on the left, and a minimal dot badge "● Positif" (#10B981 dot) on the right.
> - Two lines of study description text in Slate-900 (#0F172A).
> - Bottom metadata row with photo chip, appreciation snippet, and sharp Primary Blue "Detail ›" clickable link (#3490F9).
> Clean, disciplined, anti-slop visual style.
> ```

---

### SCREEN 06: Submit Incident Screen (Pengaduan LANTANG)
- **Role / Target User:** Siswa melaporkan insiden perundungan/kekerasan secara aman atau anonim.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "🛡️ Pengaduan LANTANG" with back button.
  - **Mode Kerahasiaan Toggle Card:**
    - Flat white card with `1.5px solid #3490F9` (Confidential) or `1.5px solid #F7A81E` (Anonymous).
    - Switch toggle with label "Mode: Anonim Total" vs "Mode: Kerahasiaan Terjaga".
    - Explainer text on database protection.
  - **Form Controls (Flat White, `1px solid #E2E8F0` Borders):**
    1. Radio list tiles: "Saya Korban" vs "Saya Saksi".
    2. Dropdown: "Kategori Insiden" (`Verbal`, `Fisik`, `Sosial/Relasional`, `Cyber`).
    3. Dropdown: "Lokasi Kejadian" (Kantin, Ruang Kelas, Lapangan, dll.).
    4. Date picker tile with calendar icon.
    5. Checkbox: "Mengetahui Identitas / Ciri Pelaku?" + Conditional text field.
    6. Textarea: "Ceritakan Kronologi Kejadian *" (5 lines).
    7. Photo upload outline button.
  - **Submit Button:** Full-width flat button "Kirim Pengaduan LANTANG" in solid Primary Blue `#3490F9`.
  - **Success Modal Dialog:**
    - Flat white dialog with `1px solid #E2E8F0` border.
    - Title: "Laporan LANTANG Terkirim".
    - Monospace ticket code box (`#SA-9821`) in bold `#3490F9` + Copy button.
    - Actions: "Selesai" (Text) vs "Lacak Kasus" (Solid `#3490F9`).

> **Google Stitch Prompt Narrative:**
> ```text
> Clean, protective mobile form screen for "AiNARA - LANTANG Child Safeguarding Report". Viewport 390x844, zero drop shadows, razor-sharp 1px borders.
> Flat Primary Blue AppBar (#3490F9) with shield emoji and title "Pengaduan LANTANG".
> Confidentiality Card: Flat white card with 1.5px solid #F7A81E border, title "Mode: Anonim Total" with a tangerine toggle switch (#F7A81E), and concise privacy assurance text.
> Form sections with 1px solid #E2E8F0 borders and 12px corners:
> 1. Radio selector for reporter role: "Saya Korban" or "Saya Saksi".
> 2. Dropdown field "Kategori Insiden" with value "Ejekan / Celaan / Verbal".
> 3. Dropdown field "Lokasi Kejadian" showing "Kantin Sekolah".
> 4. Date selector tile "2026-10-28".
> 5. Checkbox "Mengetahui Identitas / Ciri Pelaku?" with perpetrator text field.
> 6. 5-line textarea "Ceritakan Kronologi Kejadian *".
> 7. Flat photo upload button with camera outline icon.
> Bottom full-width flat Primary Blue CTA button (#3490F9) labeled "Kirim Pengaduan LANTANG", zero elevation.
> ```

---

### SCREEN 07: Student Incident History Screen (Riwayat Aduan LANTANG)
- **Role / Target User:** Siswa memantau kasus-kasus yang pernah dilaporkan dengan identitas terlindungi.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Riwayat Aduan LANTANG", refresh button.
  - **Floating Action Button:** Red flat pill button "+ Buat Aduan" (`#EF4444`, zero shadow).
  - **Anonymous Policy Banner:** Flat `#FEF6E8` container with `1px solid #FDE68A` border, explainer text + Outlined button "Lacak Tiket Bebas (#SA)" in `#F7A81E`.
  - **Incident Cards (Flat White, `1px solid #E2E8F0` Border, Zero Shadow):**
    - Header: Monospace ticket badge `#SA-4821` + Clean status tag (e.g., `● Investigasi` with `#3490F9` dot).
    - Category chip in `#F1F5F9` with `#3490F9` text: "Kategori: Ejekan / Verbal".
    - Excerpt of report description.
    - Resolution callout: Flat `#F8FAFC` box with `1px solid #E2E8F0` border and `Catatan Guru BK: Tim mediasi telah menjadwalkan konseling...`.
    - Footer: Location info + "Lihat Penanganan ›" link in `#3490F9`.

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile screen for "AiNARA - Student Incident History". Mobile viewport 390x844, zero drop shadows, crisp 1px borders.
> Primary Blue AppBar (#3490F9) with "Riwayat Aduan LANTANG".
> Floating action button in flat red (#EF4444) with shield icon and label "Buat Aduan", zero elevation.
> Body:
> 1. Amber info banner (#FEF6E8) with 1px solid #FDE68A border and a flat tangerine button "Lacak Tiket Bebas (#SA)" (#F7A81E).
> 2. Incident Card in flat white with 1px solid #E2E8F0 border:
> - Header: Monospace ticket badge "#SA-4821" and clean status badge "● Investigasi" with Primary Blue dot (#3490F9).
> - Category tag in flat grey chip with blue text "Kategori: Ejekan / Verbal" and date.
> - Report description snippet.
> - Callout box in flat #F8FAFC with 1px border: "Catatan Guru BK: Tim mediasi telah menjadwalkan konseling bersama...".
> - Footer showing "Lokasi: Kantin Sekolah" and sharp Primary Blue link "Lihat Penanganan ›" (#3490F9).
> ```

---

### SCREEN 08: Track Incident Screen (Lacak Kasus LANTANG Tanpa Login)
- **Role / Target User:** Publik atau siswa yang melapor secara anonim total.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Lacak Kasus LANTANG" with back navigation.
  - **Search Box Card:**
    - Flat white card with `1px solid #E2E8F0` border, zero shadow.
    - Title: "Cek Progres Tindak Lanjut".
    - Input row: Monospace text field with ticket icon + Flat Primary Blue button "Lacak" (`#3490F9`).
  - **Tracking Results Card:**
    - Header: Ticket code `#SA-8319` + Status tag "Tindakan".
    - 4-Stage Flat Stepper:
      - Step 1: `Laporan Masuk` (Solid Blue circle `#3490F9`).
      - Step 2: `Investigasi` (Solid Blue circle `#3490F9`).
      - Step 3: `Tindakan` (Active, Secondary Tangerine circle `#F7A81E`).
      - Step 4: `Selesai` (Pending, Slate grey circle `#CBD5E1`).
    - Committee Notes: Flat `#F8FAFC` container with `1px solid #E2E8F0` border showing TPPK official notes.

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile screen for "AiNARA - Track Safeguarding Ticket". Mobile viewport 390x844, flat minimalist layout, zero drop shadows.
> Primary Blue AppBar (#3490F9) with title "Lacak Kasus LANTANG".
> 1. Search Card in flat white with 1px solid #E2E8F0 border: Title "Cek Progres Tindak Lanjut", text input with ticket placeholder "#SA-XXXX", and flat Primary Blue button "Lacak" (#3490F9).
> 2. Result Card below:
> - Header: Ticket code "#SA-8319" in bold monospace with a clean status pill "Tindakan".
> - A modern horizontal 4-step progress tracker: [1. Laporan Masuk] -> [2. Investigasi] -> [3. Tindakan (Active in #F7A81E)] -> [4. Selesai (Pending in #CBD5E1)], with completed steps in Primary Blue (#3490F9) and active step in Secondary Tangerine (#F7A81E).
> - Clean callout box showing "Catatan dari Tim Guru BK / TPPK: Mediasi orang tua siswa telah dilaksanakan secara tertutup." in a flat 1px bordered grey container.
> ```

---

### SCREEN 09: Parent Home Screen (Beranda Orang Tua)
- **Role / Target User:** Orang tua / wali murid yang memiliki 1 atau lebih anak terdaftar.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "AiNARA Parent", action buttons: Refresh, Profile, Logout.
  - **Greeting Card:** Flat white card, `1px solid #E2E8F0` border, family icon, "Bapak / Ibu," + Parent Name.
  - **Connected Children Section:**
    - Header: "Ananda yang Terhubung" + Counter badge "2 Siswa".
    - Child Cards (Flat White, `1px solid #E2E8F0` Border, Zero Shadow):
      - Student initials icon, student name (Bold 15px), class & NIS.
      - Status indicator:
        - `● Sudah Lapor` (`#10B981` dot, `#F1F5F9` container).
        - `● Belum Lapor` (`#F7A81E` dot, `#FEF6E8` container).
      - Chevron link "Riwayat & Rekap ›" in `#3490F9`.
  - **Filter & Export Toolbox Card:**
    - Flat white card, `1px solid #E2E8F0` border.
    - Student Selector Dropdown + Date Range Pickers ("Dari Tanggal" - "Sampai Tanggal").
    - Export Buttons Row:
      - Flat Outlined Button: "Cetak PDF" (`1px solid #EF4444`, text `#EF4444`).
      - Flat Outlined Button: "Export CSV" (`1px solid #3490F9`, text `#3490F9`).
  - **Unified Feed Laporan Belajar (Activity Stream):**
    - Header: "Feed Laporan Belajar" + "X Laporan".
    - Flat white cards with `1px solid #E2E8F0` border:
      - Student name + date.
      - 3-line excerpt of study report.
      - Tag chips in flat `#F1F5F9` with `#3490F9` text: `#Matematika`, `#Tajwid`.
      - Appreciation status:
        - *If sent:* Flat `#F1F5F9` badge with reaction emoji & parent note.
        - *If not yet:* Outlined button "Beri Apresiasi" (`1px solid #F7A81E`, text `#F7A81E`).
      - Action link: "Detail & AI ›" in `#3490F9`.

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile screen for "AiNARA - Parent Home & Monitoring". Mobile viewport 390x844, zero shadows, flat 1px border architecture.
> Primary Blue AppBar (#3490F9) with title "AiNARA Parent" and icons for refresh, profile, and logout.
> Body:
> 1. Parent Welcome Card in flat white with 1px solid #E2E8F0 border, family avatar icon and text "Bapak / Ibu, Hendra Wijaya".
> 2. "Ananda yang Terhubung" section displaying 2 student cards in flat white:
> - Child 1: "Aisyah Nurul" (Kelas 8A), minimal dot badge "● Sudah Lapor" with green dot, link "Riwayat & Rekap ›".
> - Child 2: "Faris Al-Fatih" (Kelas 7B), minimal dot badge "● Belum Lapor" with tangerine dot (#F7A81E).
> 3. Filter & Export Card: Dropdown selector "Semua Ananda", two date picker buttons, and two flat outlined export buttons: red "Cetak PDF" (#EF4444) and blue "Export CSV" (#3490F9).
> 4. Feed Laporan Belajar: Flat white cards showing daily logs with clean grey tag chips with blue text (#F1F5F9 bg, #3490F9 text), flat outlined tangerine button "Beri Apresiasi" (#F7A81E), and blue "Detail & AI ›" link. Zero blur, zero shadows.
> ```

---

### SCREEN 10: Child Reports Screen (Arsip Laporan Spesifik 1 Anak)
- **Role / Target User:** Orang tua memantau dan mengekspor rekap 1 anak tertentu secara mendalam.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Riwayat Laporan [Nama Ananda]" + Refresh button.
  - **Student Banner Card:**
    - Flat white card with `1px solid #E2E8F0` border, zero shadow.
    - Large initials monogram ("AN") in Primary Blue circle `#3490F9`.
    - Child name (Bold 16px), Class and NIS.
    - Badge: "Total Terarsip: 28 Laporan" in flat `#F1F5F9`.
  - **Filter & Export Card:**
    - Two date picker buttons + Reset button.
    - Export buttons: Outlined "Cetak PDF" (`#EF4444`) & Outlined "Export CSV" (`#3490F9`).
  - **Paginated Reports List:**
    - Flat white cards with `1px solid #E2E8F0` border, Indonesian formatted date ("Senin, 28 Oktober 2026"), study text summaries, blue keyword chips, and parent reaction badge.
    - Bottom pagination controls: Previous arrow, "Halaman 1 dari 3", Next arrow.

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile screen for "AiNARA - Child Report History (Parent View)". Mobile viewport 390x844, zero drop shadows, crisp 1px borders.
> Primary Blue AppBar (#3490F9) with title "Riwayat Laporan Aisyah Nurul".
> Body:
> 1. Child Profile Banner in flat white card: Circular monogram avatar "AN" in solid Primary Blue (#3490F9), child name "Aisyah Nurul", class "Kelas 8A • Kode: 2024-0821", and badge on right "Total Terarsip: 28 Laporan" in clean slate container.
> 2. Filter & Export Card: Two date pickers and two flat outlined buttons ("Cetak PDF" in red, "Export CSV" in Primary Blue #3490F9).
> 3. Vertical list of historical report cards with 1px solid #E2E8F0 borders, study text summaries, clean keyword chips with blue text, and parent reaction badges.
> 4. Bottom pagination row with prev/next arrows and text "Halaman 1 dari 3". Flat, razor-sharp styling.
> ```

---

### SCREEN 11: Report Detail Screen (Detail Laporan, AI & Apresiasi)
- **Role / Target User:** Dual-role screen (Siswa & Orang Tua).
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Detail Laporan Belajar", edit note icon (for students only), refresh icon.
  - **Header Card:**
    - Flat white card with `1px solid #E2E8F0` border, zero shadow.
    - Student avatar, name, class, report date, submitted timestamp.
    - Minimal Sentiment Tag: `● Kondisi Positif` (`#10B981` dot on `#F1F5F9`) or `● Perlu Perhatian` (`#F7A81E` dot).
  - **AI Auto-Tags Section:**
    - Sparkle icon in `#3490F9` + "Topik / Tag Belajar Terdeteksi (AI)".
    - Clean `#F1F5F9` pill chips with `#3490F9` text: `#Aljabar`, `#TajwidSurah`, `#Pancasila`.
  - **Materi & Catatan Belajar Card:**
    - Flat white card with `1px solid #E2E8F0` border, full study text.
  - **Emotional Reflection Cards:**
    - Flat white card with `1px solid #E2E8F0` border: `😊 Hal yang Membuat Senang:` + student reflection text.
    - Flat white card with `1px solid #E2E8F0` border: `😤 Kendala Belajar / Hal yang Mengganjal:` + student reflection text.
  - **Photo Documentation Card with Zoom Lightbox:**
    - Camera icon + "Dokumentasi Foto Belajar".
    - Clean photo preview with `1px solid #E2E8F0` border and "Sentuh untuk Zoom" overlay badge.
    - Lightbox Dialog with pinch-to-zoom (`InteractiveViewer`).
  - **AI Parent Guidance Card:**
    - Flat white card with `3px solid #3490F9` left accent border and `1px solid #E2E8F0` outline, zero shadow.
    - Psychology icon in `#3490F9` + "💡 Panduan Apresiasi Orang Tua (AI)".
    - Actionable coaching tips for the parent.
  - **Received Appreciations Card:**
    - Flat white card with `1px solid #E2E8F0` border showing reaction emoji, label, parent name, and note.
  - **Sticky Bottom Navigation Bar (Parent View only):**
    - Full-width flat button: "Beri Apresiasi ke Anak" in solid Secondary Tangerine `#F7A81E` (zero shadow).
  - **Modal BottomSheet (Apresiasi Laporan Anak):**
    - Flat white sheet with reaction selector: 🤲 Barakallah, ❤️ Bangga, 👍 Keren, 💪 Semangat.
    - Message input textarea.
    - Solid button "Kirim Apresiasi" in `#3490F9`.

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile screen for "AiNARA - Report Detail & AI Insights". Mobile viewport 390x844, zero drop shadows, crisp 1px borders, anti-slop design.
> Primary Blue AppBar (#3490F9) with title "Detail Laporan Belajar".
> Body:
> 1. Header Card in flat white with 1px solid #E2E8F0 border, student meta, date "28 Oktober 2026", and a minimal sentiment dot badge "● Kondisi Positif" (#10B981 dot).
> 2. AI Tags Section: Clean slate chips (#F1F5F9) with Primary Blue text (#3490F9): #Al-Quran, #Matematika, #Fisika.
> 3. Content Card in flat white displaying full study summary paragraph.
> 4. Two Flat Reflection Cards with 1px solid #E2E8F0 borders: one for smiling emoji 😊 and one for obstacle emoji 😤.
> 5. Photo Evidence Card: High quality photo of a student notebook with 1px border and a small "Sentuh untuk Zoom" badge.
> 6. AI Parent Coaching Card in flat white with a 3px solid Primary Blue left border (#3490F9): "💡 Panduan Apresiasi Orang Tua (AI)" offering concise psychological guidance for the parent.
> 7. Appreciations Card in flat white displaying parent praise note.
> Sticky bottom bar with a prominent flat Secondary Tangerine CTA button "Beri Apresiasi ke Anak" (#F7A81E), zero drop shadow.
> ```

---

### SCREEN 12: Profile & Account Screen (Profil & Akun Saya)
- **Role / Target User:** Siswa dan Orang Tua mengelola identitas profil dan keamanan akun.
- **Layout Structure:**
  - **Top App Bar:** Primary Blue `#3490F9`, title "Profil & Akun Saya", logout icon at top right.
  - **Header Identity Card:**
    - Flat white card, `1px solid #E2E8F0` border, zero shadow.
    - Circular Avatar (88x88px) with clean camera badge overlay.
    - User Full Name (Bold 18px, `#0F172A`) + Email.
    - Minimal Role pill badge: `Siswa` or `Orang Tua / Wali` with `#3490F9` text + `🟢 Aktif` badge.
    - *For Students:* Divider + NIS code & Class name info tiles.
  - **Contact & Address Form Card:**
    - Flat white card, `1px solid #E2E8F0` border.
    - Title: "Informasi Kontak & Alamat".
    - Input: "Nomor WhatsApp / HP" with phone icon prefix.
    - Input: "Alamat Domisili" with home icon prefix (2 lines).
    - Button: "Simpan Perubahan Kontak" (Solid Primary Blue `#3490F9`, zero shadow).
  - **Change Password Form Card:**
    - Flat white card, `1px solid #E2E8F0` border.
    - Title: "Ganti Kata Sandi".
    - Inputs: "Kata Sandi Saat Ini", "Kata Sandi Baru", "Konfirmasi Kata Sandi Baru" with eye toggle icons.
    - Button: "Perbarui Kata Sandi" (Solid Slate `#0F172A`, zero shadow).
  - **Logout Action Card:**
    - Flat white card with outlined red button "Keluar dari Akun" (`1px solid #EF4444`, text `#EF4444`).
    - Triggers confirmation alert dialog ("Batal" / "Keluar").

> **Google Stitch Prompt Narrative:**
> ```text
> High-fidelity mobile screen for "AiNARA - Profile & Account Settings". Mobile viewport 390x844, zero drop shadows, clean 1px borders.
> Primary Blue AppBar (#3490F9) with title "Profil & Akun Saya" and a white logout icon button.
> Body:
> 1. Profile Header Card in flat white with 1px solid #E2E8F0 border: Centered circular profile picture with a small camera badge, user name "Faris Al-Fatih", email "faris@ainara.id", and clean role badge "Siswa" in Primary Blue (#3490F9). Info row below shows NIS "2024-0821" and "Kelas 7B".
> 2. Contact Information Card: Two flat white input fields with 1px borders ("Nomor WhatsApp / HP" and "Alamat Domisili"), and a solid Primary Blue button "Simpan Perubahan Kontak" (#3490F9).
> 3. Security Card: Three password fields with eye toggle icons and a dark slate button "Perbarui Kata Sandi" (#0F172A).
> 4. Logout Card with a flat outlined red button "Keluar dari Akun" (#EF4444).
> Crisp, flat, high contrast, zero shadow slop.
> ```

---

## 4. Cara Penggunaan di Google Stitch

1. **Gunakan Design System Tokens di Stitch:**
   Masukkan token warna:
   - Primary: `#3490F9` (Primary Blue)
   - Secondary: `#F7A81E` (Warm Tangerine)
   - Neutrals: `#0F172A` (Text Slate 900), `#F8FAFC` (Canvas), `#FFFFFF` (Surface), `#E2E8F0` (Borders)
   - Rule: `elevation: 0`, `box-shadow: none`, `border: 1px solid #E2E8F0`
2. **Eksekusi Pembuatan Screen per Screen:**
   Copy-paste blok prompt **Google Stitch Prompt Narrative** di atas ke tool Stitch `generate_screen_from_text` satu per satu untuk mendapatkan layout mobile yang konsisten, modern, dan bebas dari tampilan *slop/rainbow*.
