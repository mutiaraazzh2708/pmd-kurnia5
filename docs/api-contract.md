# Kontrak API (API Contract) - PMD Kurnia

Dokumen ini berisi spesifikasi endpoint, format request, dan response untuk integrasi tim Backend dan Mobile.

**Base URL:** `http://localhost:8000/api`  
**Default Headers:**
```http
Accept: application/json
Content-Type: application/json
```

---

## 1. Autentikasi

### 1.1 Login
* **Endpoint:** `POST /api/login`
* **Akses:** Publik
* **Request Body:**
```json
{
  "username": "pemilik1",
  "password": "password123",
  "role": "pemilik"
}
```
> Catatan: Pilihan `role` adalah `pemilik`, `kasir`, atau `karyawan_toko`.

* **Response Sukses (200 OK):**
```json
{
  "message": "Login berhasil",
  "token": "1|uKAjkt09fgk1VGKzTM7aFx...",
  "user": {
    "id": 1,
    "name": "Pemilik",
    "username": "pemilik1",
    "role": "pemilik"
  }
}
```

* **Response Gagal:**
  * `401 Unauthorized`: Password/username/role tidak cocok.
  * `422 Unprocessable Content`: Data kosong / tidak lengkap.

### 1.2 User Profile (Me)
* **Endpoint:** `GET /api/me`
* **Header:** `Authorization: Bearer <TOKEN>`
* **Response (200 OK):**
```json
{
  "id": 1,
  "name": "Pemilik",
  "username": "pemilik1",
  "email": null,
  "role": "pemilik"
}
```

### 1.3 Logout
* **Endpoint:** `POST /api/logout`
* **Header:** `Authorization: Bearer <TOKEN>`
* **Response (200 OK):**
```json
{
  "message": "Logout berhasil"
}
```

---

## 2. Produk

Semua endpoint produk memerlukan header:
```http
Authorization: Bearer <TOKEN>
```

### 2.1 Daftar Produk
* **Endpoint:** `GET /api/produk`
* **Akses:** Semua role yang sudah login (`pemilik`, `kasir`, `karyawan_toko`)
* **Response Sukses (200 OK):**
```json
[
  {
    "id": 1,
    "nama": "Gula pasir",
    "satuan_id": 1,
    "harga_beli": "12000.00",
    "harga_jual": "15000.00",
    "stok": 50,
    "created_at": "2026-10-21T00:30:00.000000Z",
    "updated_at": "2026-10-21T00:30:00.000000Z",
    "satuan": {
      "id": 1,
      "nama": "Kg"
    }
  }
]
```

---

### 2.2 Tambah Produk
* **Endpoint:** `POST /api/produk`
* **Akses:** Khusus role `pemilik`
* **Request Body:**
```json
{
  "nama": "Minyak Goreng 1L",
  "satuan_id": 1,
  "harga_beli": 14000,
  "harga_jual": 17000,
  "stok": 24
}
```
* **Response Sukses (201 Created):**
```json
{
  "id": 2,
  "nama": "Minyak Goreng 1L",
  "satuan_id": 1,
  "harga_beli": 14000,
  "harga_jual": 17000,
  "stok": 24,
  "created_at": "2026-10-21T00:35:00.000000Z",
  "updated_at": "2026-10-21T00:35:00.000000Z",
  "satuan": {
    "id": 1,
    "nama": "Kg"
  }
}
```
* **Response Validasi Gagal (422 Unprocessable Content):**
```json
{
  "message": "The nama field is required. (and 1 more error)",
  "errors": {
    "nama": ["The nama field is required."],
    "satuan_id": ["The selected satuan id is invalid."]
  }
}
```
* **Response Akses Ditolak (403 Forbidden):**
```json
{
  "message": "Tidak punya akses"
}
```

---

### 2.3 Edit / Update Produk
* **Endpoint:** `PUT /api/produk/{id}`
* **Akses:** Khusus role `pemilik`
* **Request Body:**
```json
{
  "nama": "Minyak Goreng 1L (Promo)",
  "satuan_id": 1,
  "harga_beli": 13500,
  "harga_jual": 16000,
  "stok": 30
}
```
* **Response Sukses (200 OK):**
```json
{
  "id": 2,
  "nama": "Minyak Goreng 1L (Promo)",
  "satuan_id": 1,
  "harga_beli": 13500,
  "harga_jual": 16000,
  "stok": 30,
  "created_at": "2026-10-21T00:35:00.000000Z",
  "updated_at": "2026-10-21T00:40:00.000000Z",
  "satuan": {
    "id": 1,
    "nama": "Kg"
  }
}
```
* **Response Data Tidak Ditemukan (404 Not Found):**
```json
{
  "message": "No query results for model [App\\Models\\Produk] 9999"
}
```

---

### 2.4 Hapus Produk
* **Endpoint:** `DELETE /api/produk/{id}`
* **Akses:** Khusus role `pemilik`
* **Response Sukses (200 OK):**
```json
{
  "message": "Produk berhasil dihapus"
}
```

---

## 3. Akun Uji Coba (Seeder)

| Username | Password | Role | Hak Akses Produk |
| :--- | :--- | :--- | :--- |
| `pemilik1` | `password123` | `pemilik` | Lihat, Tambah, Edit, Hapus (Full) |
| `kasir1` | `password123` | `kasir` | Hanya Lihat (`GET /api/produk`) |
| `karyawan1` | `password123` | `karyawan_toko` | Hanya Lihat (`GET /api/produk`) |


## 3. Autocomplete Produk (Kasir)

### 3.1 Cari Produk
* **Endpoint:** `GET /api/produk/autocomplete?q=<kata kunci>`
* **Akses:** `kasir`, `pemilik`
* **Query:** `q` wajib, minimal 2 huruf
* **Response Sukses (200 OK):** maksimal 10 produk, produk terhapus tidak tampil
```json
[
  {
    "id": 1,
    "nama": "Gula Pasir 1 kg",
    "satuan": "Kg",
    "harga_jual": "16500.00",
    "stok": 120
  }
]
```
* **Response Gagal:**
  * `422`: `q` kosong atau kurang dari 2 huruf
  * `403`: role `karyawan_toko`
  * `401`: tanpa token

---

## 4. Transaksi

Semua endpoint memerlukan `Authorization: Bearer <TOKEN>`.

### 4.1 Simpan Transaksi
* **Endpoint:** `POST /api/transaksi`
* **Akses:** `kasir`, `pemilik`
* **Request Body:**
```json
{
  "tipe_pembeli": "reseller",
  "metode_bayar": "tunai",
  "items": [
    { "produk_id": 1, "jumlah": 2 },
    { "produk_id": 3, "jumlah": 1 }
  ]
}
```
| Field | Aturan |
| :--- | :--- |
| `tipe_pembeli` | wajib, `umum` atau `reseller` |
| `metode_bayar` | wajib, `tunai`, `transfer`, atau `qris` |
| `items` | wajib, minimal 1 item |
| `items.*.produk_id` | wajib, harus ada, tidak boleh dobel |
| `items.*.jumlah` | wajib, bilangan bulat, minimal 1 |

> Total dan harga dihitung server dari `harga_jual` produk. Field `harga` atau `total` dari app diabaikan. Stok produk berkurang otomatis. Jika satu item gagal, seluruh transaksi dibatalkan.

* **Response Sukses (201 Created):**
```json
{
  "message": "Transaksi berhasil disimpan",
  "transaksi": {
    "id": 10,
    "user_id": 2,
    "tipe_pembeli": "reseller",
    "metode_bayar": "tunai",
    "total": "48000.00",
    "created_at": "2026-10-27 15:40:00",
    "updated_at": "2026-10-27 15:40:00"
  },
  "detail": [
    {
      "id": 21,
      "transaksi_id": 10,
      "produk_id": 1,
      "jumlah": 2,
      "harga": "16500.00",
      "subtotal": "33000.00"
    }
  ]
}
```
* **Response Validasi Gagal (422):**
```json
{
  "message": "Stok tidak cukup (tersisa 3)",
  "errors": {
    "items.0.jumlah": ["Stok tidak cukup (tersisa 3)"]
  }
}
```
Contoh pesan lain: `Keranjang tidak boleh kosong`, `Jumlah harus lebih dari 0`, `Metode bayar wajib dipilih`, `Produk tidak boleh dobel di keranjang`, `Produk tidak tersedia`. Kunci `errors` memakai posisi item (`items.0.jumlah`) supaya app bisa menandai baris yang salah.
* **Response Akses Ditolak:** `403` untuk `karyawan_toko`, `401` tanpa token.

### 4.2 Riwayat Transaksi
* **Endpoint:** `GET /api/transaksi`
* **Akses:** semua role yang login
* **Query opsional:** `metode_bayar`, `tanggal` (format `YYYY-MM-DD`)
* **Response (200 OK):** daftar transaksi terbaru lebih dulu, memuat `kasir` (`id`, `name`, `username`)

### 4.3 Detail Transaksi
* **Endpoint:** `GET /api/transaksi/{id}`
* **Akses:** semua role yang login
* **Response (200 OK):** transaksi lengkap dengan `kasir` dan `detail` (tiap baris memuat `produk` berisi `id` dan `nama`)
* **Response Gagal:** `404` jika id tidak ada
