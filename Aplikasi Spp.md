<div align="center">
  
  # Sistem Informasi Manajemen Keuangan Sekolah (SPP)
  **Versi 1.0.5 - Enterprise Edition**
</div>

---

## Deskripsi Sistem
**Sistem Informasi Manajemen Keuangan Sekolah** adalah platform digital modern yang dirancang khusus untuk mendigitalisasi, mengamankan, dan mempercepat proses administrasi tata usaha keuangan institusi pendidikan. Dibangun di atas **Laravel 11** dan panel admin bertenaga **Filament v3 (TALL Stack)**, sistem ini menjamin akurasi pembukuan fiskal, mengeliminasi risiko kebocoran dana, serta menyediakan transparansi data secara beraliran *real-time*.

Arsitektur aplikasi memisahkan secara tegas antara **Back-Office Dashboard (Panel Staf Keuangan)** untuk manajemen internal dan **Public Gateway Portal** demi kemudahan pencarian informasi tagihan oleh wali murid tanpa perlu prosedur log masuk.

---

## Fitur-Fitur Unggulan Sistem

### 1. Sistem Manajemen Akademik & Otomatisasi Tagihan (Smart Billing)
* **Siklus Tahun Ajaran Dinamis:** Mesin aplikasi bekerja berdasarkan data Tahun Ajaran aktif (Juli - Juni), memastikan siklus tagihan berjalan sinkron secara otomatis dengan masa belajar siswa.
* **Bulk Invoice Generator:** Pembuatan ribuan komponen tagihan bulanan untuk seluruh siswa hanya dengan **1-Klik**, lengkap dengan penamaan kronologis otomatis (contoh: *"SPP Juli"*, *"SPP Agustus"*).
* **Historical Data Integrity:** Menyediakan fitur mutasi dan promosi kenaikan kelas yang aman, mengunci rekam jejak finansial masa lalu agar tidak mengalami perubahan nilai ketika siswa berpindah tingkatan kelas.

### 2. Modul Kasir & Transaksi Cerdik (Smart POS Dashboard)
* **Pencegah Kelebihan Bayar (Overpayment Protection):** Sistem memiliki validasi ketat yang memblokir otomatis input nominal transaksi jika jumlah bayar melebihi sisa hutang/tunggakan riil siswa.
* **Optimasi Dependent Dropdown:** Pilihan tagihan otomatis tersaring seketika berdasarkan entitas siswa yang dipilih, meminimalisir kesalahan input (*human error*) saat antrean pembayaran kasir sedang padat.
* **Skema Pembayaran Fleksibel:** Mendukung pencatatan pelunasan penuh, cicilan/parsial otomatis, serta pemberian potongan harga/diskon khusus (beasiswa/keringanan keuangan).

### 3. Portal Pencarian Mandiri Wali Murid (Public Frontend)
* **Cek Tagihan Instan Tanpa Autentikasi:** Orang tua dapat memeriksa sisa tunggakan anak kapan saja hanya menggunakan nomor **NISN** valid. Desain antarmuka dioptimalkan agar sepenuhnya responsif untuk diakses via perangkat genggam (*mobile web application*).

### 4. Enterprise Security, Logging & Audit Trail
* **CCTV Aplikasi (Comprehensive Audit Logs):** Setiap tindakan manipulasi data (Kreat, Baca, Perbarui, Hapus) direkam secara presisi (Pelaku, IP Address, Waktu, Data Asli vs Perubahan Data Baru).
* **Role-Based Access Control (RBAC):** Hak akses tingkat tinggi yang memisahkan otoritas fungsional pengguna secara mutlak antara peran `Super Admin`, `Kepala Sekolah`, `Bendahara`, dan `Operator`.
* **Anti-Hapus Permanen (Soft Deletes Architecture):** Penghapusan data penting keuangan tidak akan membuang rekaman dari *hard drive*, melainkan hanya disembunyikan untuk menjaga bukti audit forensik pembukuan.
* **Anti-Forgery Document Guard:** Semua ekspor berkas keuangan dikunci mati ke format **PDF (Read-Only)** secara asinkron guna mencegah manipulasi angka mentah sebelum dicetak.

### 5. Subsistem Pencetakan & Dokumen Terstandarisasi
* Cetak bukti kwitansi transaksi pembayaran (Mendukung Printer Thermal Bluetooth & Format PDF).
* Cetak Kartu Kendali SPP Siswa (Format cetak kertas A4 mencakup 2 Semester penuh).
* Pembuatan otomatis Surat Peringatan Tunggakan Tagihan untuk wali murid.
* Ekspor Laporan Rekapitulasi Piutang, Pemasukan, dan Pengeluaran kas sekolah dengan kustomisasi kop surat resmi instansi.

---

## Stack Teknologi Terapan

- **Backend Architecture:** PHP 8.3 & Framework Laravel 11.x
- **Administration Panel:** Filament v3 Framework (Tailwind CSS, Alpine.js, Laravel, Livewire)
- **Database Engine:** PostgreSQL 15 (Alpine Linux Distribution)
- **High-Performance Caching & Queues:** Redis Server (Untuk komputasi statistik dasbor secepat kilat & manajemen antrean)
- **Real-Time Communication:** Pusher WebSockets (Sinkronisasi trigger cetak printer otomatis)
- **Application Server Mode:** FrankenPHP (Berjalan pada high-performance worker mode bawaan)

---

## Infrastruktur Jaringan & Keamanan (Cloudflare Tunnel)

Infrastruktur dijalankan secara terisolasi penuh di dalam kluster jaringan Docker internal. Seluruh lalu lintas dari internet publik dijembatani menggunakan **Cloudflare Tunnel (`cloudflared`)**:
* **Zero Inbound Ports Opened:** Server tidak membuka port masuk tradisional (port 80 atau 443). Server bertindak sebagai *ghost infrastructure* karena tidak mengekspos IP publik asli VPS Hostinger ke internet, melindunginya secara total dari serangan *port scanning* atau *brute force SSH*.
* **Mitigasi Serangan DDoS Atas Akses Massal:** Lonjakan trafik yang masif saat ribuan orang tua atau operator mengakses sistem diredam langsung di server edge global Cloudflare sebelum sampai ke resource compute VPS.

---

## Manajemen & Alokasi Sumber Daya Kontainer

Setiap container dikunci kinerjanya menggunakan Docker Resource Limits untuk menjamin stabilitas OS induk dan mencegah kegagalan sistem (*Out-of-Memory kernel panics*):

| Nama Kontainer | Limit CPU | Limit Memori | Fungsi Operasional |
| :--- | :--- | :--- | :--- |
| `db_main` (PostgreSQL) | 1.50 Core | 4 GB | Pengelola basis data utama (`shared_buffers=1536MB`, `max_connections=200`) |
| `redis_cache` | 0.20 Core | 512 MB | Cache sesi, status, dan antrean transaksi cepat |
| `app_spp` (FrankenPHP) | 0.25 Core | 1 GB | Core engine aplikasi web (FrankenPHP Worker Mode) |
| `app_spp_worker` | 0.25 Core | 1 GB | Pemroses latar belakang asinkron (Ekspor PDF & Queue) |
| `spp_scheduler` | 0.10 Core | 250 MB | Runner tugas otomatis (Cron housekeeping & rekap) |
| `cloudflared_tunnel` | 0.10 Core | 128 MB | Daemon ringan gerbang ingress enkripsi Cloudflare |

---

**Author:** Lifani – *DevOps Engineer & Backend Developer*
