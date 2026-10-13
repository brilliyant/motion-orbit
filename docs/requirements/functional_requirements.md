# FormFit AI — Functional Requirements Specification

## 5.1 Onboarding & Personal Profile

**Feature ID:** FTR-ONB

**Objective:** Mengumpulkan informasi minimum untuk mempersonalisasi pengalaman latihan tanpa membutuhkan login.

### User Inputs

- Display name (opsional).
- Date of birth atau age range (opsional).
- Height dalam cm (opsional).
- Initial body weight dalam kg (opsional).
- Fitness level: Beginner, Intermediate, Advanced.
- Primary goal: Build Muscle, Lose Fat, Improve Stamina, General Fitness.
- Training location: Home, Gym, Both.
- Available equipment: Bodyweight, Dumbbells, Barbell, Resistance Band.
- Preferred workout days.
- Preferred session duration.

### Business Rules

- Semua data disimpan lokal.
- Informasi tinggi dan berat tidak wajib untuk menggunakan workout tracker.
- Pengguna bisa mengubah profil kapan saja.
- Onboarding selesai setelah pengguna memilih fitness goal dan experience level.
- Tidak ada registrasi email atau password.
- Jika onboarding belum selesai, aplikasi mengembalikan pengguna ke langkah terakhir.
- Workout recommendation menggunakan informasi profil sebagai preferensi awal, bukan keputusan otomatis yang wajib diikuti.

### Acceptance Criteria

- Pengguna dapat menyelesaikan onboarding tanpa internet.
- Data profil tetap tersedia setelah aplikasi ditutup dan dibuka.
- Onboarding tidak muncul lagi setelah selesai kecuali pengguna melakukan reset.

---

## 5.2 Home Dashboard

**Feature ID:** FTR-HOM

### Components

1. Greeting & current date.
2. Fitness goal indicator.
3. Today's Workout Card.
4. Quick Start Workout.
5. Weekly workout statistics.
6. Current body weight (jika tersedia).
7. Recent workout summary.
8. Training consistency indicator.

### Business Rules

- Dashboard membaca data dari local database.
- Jika belum ada workout, tampilkan empty state dan CTA "Create Workout".
- Training streak dihitung berdasarkan hari latihan yang tercatat, bukan harus berlatih setiap hari.
- Rest day tidak boleh dianggap sebagai kegagalan latihan.
- Total workout duration hanya dihitung dari sesi valid yang selesai.
- Tidak menampilkan kalori terbakar seolah-olah pengukuran akurat; estimasi kalori tidak termasuk MVP.

---

## 5.3 Exercise Library

**Feature ID:** FTR-EXR

### Requirements

- Daftar exercise bawaan aplikasi.
- Search exercise berdasarkan nama.
- Filter berdasarkan muscle group, equipment, dan difficulty.
- Exercise detail berisi deskripsi, target muscle, instruksi, dan common mistakes.
- Penanda apakah exercise mendukung AI tracking.

### Initial Exercise Categories

- Chest
- Back
- Shoulders
- Arms
- Legs
- Core
- Full Body
- Cardio

### Initial Exercise Examples

- Push-up
- Squat
- Bicep Curl
- Plank
- Sit-up
- Lunges
- Pull-up
- Bench Press
- Shoulder Press
- Dumbbell Row
- Deadlift
- Running

### Rules

- Semua exercise tersedia offline.
- Exercise yang tidak mendukung AI tetap dapat dicatat secara manual.
- Metadata exercise menggunakan ID stabil.
- Update daftar exercise tidak boleh menghapus history lama.
- Exercise bawaan bersifat read-only pada MVP.

---

## 5.4 Workout Planner

**Feature ID:** FTR-PLN

### Requirements

Pengguna dapat:

- Membuat workout plan.
- Memberi nama plan.
- Menambahkan satu atau lebih exercise.
- Menentukan target set dan repetisi atau durasi.
- Menentukan target beban bila relevan.
- Mengurutkan exercise.
- Mengubah dan menghapus exercise.
- Menyalin workout plan.
- Menghapus workout plan.
- Memilih workout plan sebelum memulai sesi.

### Rules

- Plan harus memiliki nama dan minimum satu exercise.
- Setiap exercise wajib mempunyai tipe target yang valid.
- Exercise weight-based menggunakan set, reps, dan optional weight.
- Exercise duration-based menggunakan target duration.
- Mengubah plan tidak boleh mengubah completed workout history.
- Penghapusan plan membutuhkan konfirmasi.
- Workout history tetap ada walaupun plan asal sudah dihapus.

---

## 5.5 Active Workout

**Feature ID:** FTR-ACT

### Components

- Workout header.
- Elapsed session timer.
- Exercise list.
- Set tracker.
- Repetitions input.
- Weight input.
- Duration input.
- Set completion checkbox.
- Rest timer.
- Add set action.
- Skip exercise action.
- Finish workout action.
- Discard workout action.

### Rules

- Hanya satu active workout session per perangkat.
- Sesi disimpan sebagai IN_PROGRESS.
- Penyimpanan dilakukan setelah perubahan penting.
- Pengguna dapat melanjutkan sesi setelah aplikasi dibuka kembali.
- Saat workout selesai, data disimpan sebagai COMPLETED.
- Workout yang belum mempunyai completed set tidak dapat menjadi completed workout.
- Discard membutuhkan konfirmasi.
- Completed workout menjadi snapshot historis dan tidak berubah karena perubahan template.
- Input angka harus valid dan tidak negatif.
- Set tersimpan harus memiliki target atau hasil yang konsisten dengan exercise type.
- AI repetition result dapat dipindahkan ke set log, tetapi pengguna bisa mengoreksinya secara manual.

### Rest Timer

- Default rest duration dapat dikonfigurasi.
- Preset: 30, 60, 90, dan 120 detik.
- Manual Start, Pause, Resume, Skip.
- Timer menggunakan timestamp sehingga waktu tetap benar setelah aplikasi masuk background.
- Pengingat ketika rest selesai dapat menggunakan local notification jika diaktifkan.

---

## 5.6 AI Coach — Camera Form Analyzer

**Feature ID:** FTR-CAM

### MVP Supported Exercises

1. Bodyweight Squat
2. Push-up
3. Bicep Curl

### Camera Setup Requirements

- Pilih exercise.
- Pilih kamera depan/belakang jika tersedia.
- Tampilkan rekomendasi posisi kamera.
- Tampilkan skeleton preview.
- Pastikan bagian tubuh yang diperlukan terdeteksi.
- Tombol Start Analysis.
- Opsi kembali ke manual logging.

### Live Analysis Requirements

- Live camera preview.
- Pose landmark detection.
- Skeleton overlay.
- Auto repetition counter.
- Rep phase detection.
- Basic joint angle calculation.
- Range of motion indication.
- Feedback status: Tracking, Reposition Camera, Limited Visibility, atau Movement Detected.
- Pause, Resume, Stop.
- Counter reset melalui konfirmasi.
- Manual correction terhadap hasil counter.

### Exercise-Specific Rules

**Squat**

- Gunakan landmark hip, knee, dan ankle.
- Analisis perubahan sudut lutut dan posisi pinggul.
- Hitung repetisi ketika fase berdiri → turun → kembali berdiri terdeteksi secara valid.
- Jangan hitung repetisi ketika landmark tidak terlihat memadai.
- Gunakan hysteresis dan stabilisasi antar-frame.

**Push-up**

- Gunakan landmark shoulder, elbow, wrist, hip, dan ankle.
- Analisis perubahan sudut siku.
- Repetition cycle: posisi atas → posisi bawah → posisi atas.
- Gunakan panduan kamera dari samping.
- Kualitas alignment tubuh hanya ditampilkan sebagai indikasi.

**Bicep Curl**

- Gunakan shoulder, elbow, dan wrist.
- Analisis perubahan sudut siku.
- Repetition cycle: extension → flexion → extension.
- Jika dua lengan terdeteksi, tentukan lengan tracking sebelum sesi.
- Hindari penghitungan ganda akibat gerakan berulang di sekitar threshold.

### Detection Engine Rules

- Semua inference dijalankan pada perangkat.
- Gunakan single-person tracking pada MVP.
- Tidak perlu menyimpan raw camera frames.
- Frame yang sedang diproses tidak boleh menyebabkan queue terus membesar.
- Landmark dengan kualitas rendah diabaikan.
- Repetition state ditahan atau ditandai uncertain jika tracking hilang.
- Parameter sudut dan jumlah frame stabil harus dapat dikonfigurasi berdasarkan exercise.
- Tidak menyatakan hasil sebagai penilaian medis atau jaminan keamanan teknik latihan.

### Session Summary

- Exercise name.
- Detected repetitions.
- Manually corrected repetitions.
- Session duration.
- Tracking quality summary.
- Basic motion indicators.
- Ability to save into active workout.
- Ability to discard AI session.

---

## 5.7 Progress Tracking

**Feature ID:** FTR-PRG

### Body Measurements

- Body weight (kg).
- Waist circumference (cm).
- Chest circumference (cm).
- Upper arm circumference (cm).
- Thigh circumference (cm).
- Hip circumference (cm).

### Strength Progress

- Historical weight lifted.
- Completed repetitions.
- Total training volume untuk weight-based sets.
- Personal best untuk exercise yang relevan.

### Fitness Progress

- Workout sessions completed.
- Total training minutes.
- Weekly training frequency.
- Workout consistency.
- Trend berdasarkan tanggal.

### Rules

- Setiap measurement mempunyai timestamp.
- Measurement bisa diedit atau dihapus.
- Input harus berada dalam batas numerik yang masuk akal.
- Chart tidak menggabungkan unit berbeda.
- Berat badan awal boleh kosong.
- Body fat dan muscle mass measurement tidak wajib dan tidak dihitung dari kamera.
- Minimum chart period: 7 days, 30 days, 90 days, All Time.
- Empty state harus informatif apabila history belum tersedia.

---

## 5.8 Workout History

**Feature ID:** FTR-HIS

### Requirements

- Daftar workout terdahulu.
- Search/filter berdasarkan tanggal dan jenis latihan.
- Detail exercise, sets, repetitions, weights, dan duration.
- Total workout duration.
- Manual maupun AI-recorded exercise ditampilkan bersama.
- Duplicate workout as new plan.
- Delete session dengan konfirmasi.

### Rules

- Menghapus session memperbarui progress aggregates.
- Deleted workout tidak boleh masih dihitung pada dashboard.
- Workout history tidak berubah ketika exercise library metadata diperbarui.
- Repeated taps pada Finish tidak boleh menghasilkan dua completed sessions.

---

## 5.9 Profile & Settings

**Feature ID:** FTR-SET

### Settings

- Personal profile.
- Default rest timer.
- Weight unit preference.
- Measurement unit preference.
- Camera selection preference.
- Skeleton overlay on/off.
- Sound/vibration feedback.
- Notification preference.
- Privacy information.
- App version.
- Clear local data.

### Data Management

- Export data sebagai JSON atau CSV: post-MVP.
- Import backup: post-MVP.
- Full reset data dengan konfirmasi bertingkat.
- Tidak ada background upload.
- Data yang hilang akibat uninstall tidak dapat dipulihkan tanpa backup.

---

## 5.10 Error & Empty States

Semua feature wajib menangani:

- No data.
- Invalid user input.
- Storage read/write failure.
- Missing camera permission.
- Camera initialization failure.
- Camera device unavailable.
- Pose not detected.
- Partial body visibility.
- Unsupported exercise for AI.
- Interrupted or incomplete workout.
- Corrupted or incompatible locally stored data.

Error harus disampaikan dengan bahasa yang mudah dipahami dan menyediakan aksi recovery yang relevan.