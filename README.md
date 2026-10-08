# Infrastruktur Aplikasi Sistem Pembayaran Sekolah (SPP) Terkontainerisasi

Repositori ini berisi berkas konfigurasi *Infrastructure-as-Code* (IaC) berbasis **Docker Compose** untuk *deployment* tingkat produksi dari sistem tata usaha keuangan sekolah (**Aplikasi SPP**). Infrastruktur ini dirancang dengan prinsip isolasi tinggi, keandalan asinkron, dan pengerasan keamanan jaringan tanpa mengekspos server lokal ke publik.

## Komponen & Arsitektur Kluster

Kluster sistem diatur ke dalam satu jaringan internal `sekolah_net` dengan komponen berikut:
1. **Core Database Server (`db_main`):** Menggunakan PostgreSQL 15 Alpine yang dioptimalkan untuk performa transaksi tinggi dan isolasi ketat terhadap modifikasi skema pembayaran.
2. **In-Memory Cache Cluster (`redis_cache`):** Mengelola sesi *cashier operator*, manajemen status *real-time*, serta menampung antrean transaksi masuk.
3. **Application Core Engine (`app_spp`):** Berjalan di atas **FrankenPHP (Worker Mode)** untuk mempercepat pemrosesan *request* HTTP dengan membiarkan aplikasi Laravel tetap menyala di memori server.
4. **Asynchronous Background Worker (`app_spp_worker`):** Bertugas menangani operasi berat di latar belakang secara asinkron, seperti pemrosesan antrean data massal dan pembuatan dokumen laporan PDF instan.
5. **Automated Tasks Scheduler (`spp_scheduler`):** Menjalankan *cron* internal Laravel secara periodik untuk otomatisasi pengecekan status keuangan dan rekapitulasi data berkala.
6. **Network Gateway Security Proxy (`cloudflared_tunnel`):** Gerbang penghubung terenkripsi keluar (*outbound*) menuju Cloudflare Edge Network.

## Alasan Menggunakan Cloudflare Tunnel (`cloudflared`)

Sistem administrasi sekolah mengelola data sensitif terkait identitas siswa dan rekapitulasi nominal dana pembayaran. Pemakaian Cloudflare Tunnel dipilih berdasarkan alasan fundamental berikut:
- **Menghilangkan Port Terbuka Masuk (Zero Inbound Firewall Ports):** Server tidak membuka port 80 atau 443 ke internet publik. Koneksi diinisiasi dari dalam Docker menuju Cloudflare secara keluar (*outbound*), menyembunyikan IP publik asli VPS dari serangan *scanning* port atau *brute force*.
- **Perlindungan Terhadap Ancaman Keamanan Data:** Semua akses harus divalidasi melalui Cloudflare Edge Network terlebih dahulu, memberikan perlindungan aktif dari serangan Layer 7 DDoS maupun bot berbahaya sebelum sempat menyentuh infrastruktur aplikasi utama.

## Langkah Instalasi & Menjalankan Sistem

1. Klon repositori ini ke dalam server lokal/VPS:
   ```bash
   git clone https://github.com
   cd school-spp-infrastructure
   ```
2. Salin berkas lingkungan dan isi variabel token serta kata sandi asli:
   ```bash
   cp .env.example .env
   nano .env
   ```
3. Posisikan file inisialisasi database awal pada `./init-dbs.sql`.
4. Jalankan seluruh ekosistem kontainer dalam mode latar belakang:
   ```bash
   docker compose up --build -d
   ```
5. Pantau indikator kesehatan layanan untuk memastikan FrankenPHP berjalan lancar:
   ```bash
   docker compose ps
   ```

---
**Author:** Lifani – *DevOps Engineer & System Administrator*
