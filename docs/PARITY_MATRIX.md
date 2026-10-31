# AiNARA Backend-to-Mobile Parity Matrix

Dokumen ini adalah **Single Source of Truth** untuk melacak keselarasan (*parity*) antara backend Laravel (`AiraMod`) dan mobile client Flutter (`ainara_mobile`).

> **Status Legend:**
> - 🟢 **100% Selaras (Full Parity):** Endpoint terhubung, seluruh field JSON dirender dengan tepat di UI, dan enum selaras.
> - 🟡 **Parsial (Partial / Data Gap):** Endpoint terhubung, tetapi ada field JSON yang belum dirender atau enum mengalami fallback.
> - 🔴 **Belum Sinkron (Desync / Missing):** Endpoint backend sudah ada tetapi belum memiliki antarmuka di mobile client.

---

## 1. Modul Otentikasi & Sesi Pengguna

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/auth/login` | POST | `token`, `role`, `user { id, name, email, status }`, `profile` | `LoginScreen` | 🟢 100% Selaras | Multi-role routing: `student`, `parent`, `mentor`. Validasi status aktif terjaga. |
| `/api/v1/auth/me` | GET | `user`, `role`, `profile` | `LoginScreen` / `AppInit` | 🟢 100% Selaras | Verifikasi validitas token saat cold boot. |
| `/api/v1/auth/logout` | POST | `message` | `ProfileScreen` | 🟢 100% Selaras | Revoke token Sanctum & unregister FCM device token. |

---

## 2. Modul Profil Pengguna

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/profile` | GET | `id`, `name`, `email`, `role`, `phone_number`, `address`, `avatar_url`, `specialization`, `bio`, `student/parent data` | `ProfileScreen` | 🟢 100% Selaras | Menampilkan data spesifik role (NIS siswa, anak terhubung ortu, spesialisasi mentor). |
| `/api/v1/profile/contact` | POST | `phone_number`, `address`, `specialization`, `bio`, `avatar` (file) | `ProfileScreen` | 🟢 100% Selaras | Multipart upload avatar + update kontak. |
| `/api/v1/profile/password` | POST | `current_password`, `password`, `password_confirmation` | `ProfileScreen` | 🟢 100% Selaras | Validasi password lama sebelum ganti baru. |

---

## 3. Modul Siswa (Student Portal)

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/student/dashboard` | GET | `today_date`, `is_submitted`, `today_report`, `recent_reports` | `StudentHomeScreen` | 🟢 100% Selaras | Banner tanggal, status lapor hari ini, kartu snippet, & CTA lapor. |
| `/api/v1/student/reports` | GET | Paginated list: `id`, `report_date`, `content`, `happy_moment`, `frustrated_moment`, `photo_url`, `ai_tags`, `sentiment_level`, `submitted_at`, `appreciations` | `StudentReportsListScreen` | 🟡 Parsial | `sentiment_level` enum `'green'/'yellow'/'red'` perlu diselaraskan dari fallback lama `'Evaluasi Rutin'`. |
| `/api/v1/student/reports` | POST | Input: `content`, `happy_moment`, `frustrated_moment`, `photo` (file) | `SubmitReportScreen` | 🟢 100% Selaras | Kamera & galeri picker, pencegahan double submit hari yang sama. |
| `/api/v1/student/reports/{id}` | GET | Full report detail + `all_appreciations` | `ReportDetailScreen` | 🟡 Parsial | Photo lightbox pan-zoom & ai_tags sudah mantap; badge sentimen AI perlu sinkronisasi warna & label. |
| `/api/v1/student/reports/{id}` | PUT/POST | Update content & ganti foto | `EditReportScreen` | 🟢 100% Selaras | Form prefill, preview foto lama, dan penggantian foto baru. |
| `/api/v1/student/mentor-reports` | GET | List laporan bimbingan dari guru les: `mentor_name`, `session_date`, `subject`, `student_understanding`, `notes`, `photo_url` | `MentorService` | 🟢 100% Selaras | Terhubung via service client. |

---

## 4. Modul Perlindungan Siswa (LANTANG Safeguarding)

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/student/safeguarding/reports` | POST | `incident_type`, `incident_date`, `description`, `location`, `is_anonymous`, `photo` | `SubmitIncidentScreen` | 🟢 100% Selaras | Opsi Zero-Trace vs Protected identity + modal tiket rahasia `#SA-XXXX`. |
| `/api/v1/student/safeguarding/my-reports` | GET | List insiden pribadi: `tracking_code`, `incident_type`, `status`, `submitted_at`, `evidence_url` | `StudentIncidentHistoryScreen` | 🟢 100% Selaras | Status badge (`SUBMITTED`, `INVESTIGATING`, `ACTION_TAKEN`, `RESOLVED`). |
| `/api/v1/safeguarding/track/{ticket_code}` | GET | Tokenless public tracker: `tracking_code`, `status`, `status_label`, `submitted_at`, `notes` | `TrackIncidentScreen` | 🟢 100% Selaras | Pelacakan tiket publik tanpa login token. |

---

## 5. Modul Orang Tua (Parent Portal)

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/parent/dashboard` | GET | `children [] { id, name, student_code, class_name, is_submitted, today_report }` | `ParentHomeScreen` | 🟢 100% Selaras | Banner status anak hari ini, snippet laporan, direct action apresiasi. |
| `/api/v1/parent/reports` | GET | Unified feed across children | `ChildReportsScreen` | 🟢 100% Selaras | Filter multi-anak & filter rentang tanggal. |
| `/api/v1/parent/students/{id}/reports` | GET | Riwayat laporan anak spesifik | `ChildReportsScreen` | 🟢 100% Selaras | Infinite scroll pagination & tag subjek AI. |
| `/api/v1/parent/reports/{id}` | GET | Detail laporan + `ai_parent_guidance` + `my_appreciation` + `all_appreciations` | `ReportDetailScreen` | 🟡 Parsial | Kartu "Panduan Apresiasi AI" tampil; badge level sentimen AI perlu penyelarasan enum. |
| `/api/v1/parent/reports/{id}/appreciations` | POST | `reaction_type`, `message` (maks 250 kar) | Modal Apresiasi / Sheet | 🟢 100% Selaras | Emoji 1-klik (Barakallah, Bangga, Keren, Semangat) + pesan catatan orang tua. |
| `/api/v1/parent/reports/export/pdf` & `/csv` | GET | Streamed Binary / CSV UTF-8 BOM | `ChildReportsScreen` | 🟢 100% Selaras | Download langsung ke storage HP. |
| `/api/v1/parent/students/{id}/mentor-reports` | GET | Riwayat les privat anak dari mentor | `ChildReportsScreen` (Tab Les Privat) | 🟢 100% Selaras | Kartu materi ajar, pemahaman materi, catatan guru les & foto. |

---

## 6. Modul Mentor & Les Privat (Phase 17)

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/mentor/dashboard` | GET | `mentor_name`, `specialization`, `total_students`, `total_reports`, `recent_reports` | `MentorHomeScreen` | 🟢 100% Selaras | Ringkasan metrik bimbingan & daftar laporan les terkini. |
| `/api/v1/mentor/students` | GET | List siswa bimbingan aktif | `MentorHomeScreen` & `SubmitMentorReportScreen` | 🟢 100% Selaras | Digunakan di dropdown pilihan siswa les. |
| `/api/v1/mentor/available-students` | GET | Pencarian siswa sekolah yang belum dibimbing | `AttachStudentScreen` | 🟢 100% Selaras | Searchable input kode siswa / nama. |
| `/api/v1/mentor/students` | POST | `student_id` | `AttachStudentScreen` | 🟢 100% Selaras | Hubungkan siswa bimbingan baru. |
| `/api/v1/mentor/students/{id}` | DELETE | Detach siswa bimbingan | `MentorHomeScreen` | 🟢 100% Selaras | Putus bimbingan dengan konfirmasi dialog. |
| `/api/v1/mentor/reports` | GET / POST | Input materi, pemahaman, catatan, foto | `MentorHomeScreen` & `SubmitMentorReportScreen` | 🟢 100% Selaras | Submit laporan les privat multimodal. |
| `/api/v1/mentor/reports/{id}` | GET / PUT | Detail & edit laporan les | `MentorReportDetailScreen` | 🟢 100% Selaras | Pan-zoom photo lightbox & detail materi. |

---

## 7. Modul Device Token & Notifikasi Push

| Endpoint Backend | Method | Payload / Data Dikirim | Screen Mobile | Status | Catatan Keselarasan |
| :--- | :---: | :--- | :--- | :---: | :--- |
| `/api/v1/devices/token` | POST | `fcm_token`, `device_name` | `NotificationService` | 🟢 100% Selaras | Sinkronisasi token FCM ke backend saat login. |
| `/api/v1/devices/token` | DELETE | `fcm_token` | `NotificationService` | 🟢 100% Selaras | Hapus token saat logout akun. |

---

## Rangkuman Prioritas Aksi (Action Items)

1. **Sinkronisasi Enum AI Sentiment (`sentiment_level`):**
   * Di [`report_detail_screen.dart`](file:///Users/maaswick/workspace/ainara_mobile/lib/screens/reports/report_detail_screen.dart) dan [`student_reports_list_screen.dart`](file:///Users/maaswick/workspace/ainara_mobile/lib/screens/student/student_reports_list_screen.dart), tambahkan dukungan langsung untuk `'green'`, `'yellow'`, dan `'red'`.
2. **Pasang In-App Data Inspector:**
   * Memudahkan vibe coder menginspeksi payload JSON mentah vs rendered state langsung dari HP.
3. **Automated Schema Parity Test:**
   * Pasang `test/schema_parity_test.dart` untuk menguji drift kontrak data otomatis.
