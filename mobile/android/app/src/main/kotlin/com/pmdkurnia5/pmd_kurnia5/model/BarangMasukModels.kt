package com.pmdkurnia5.pmd_kurnia5.model

/**
 * Model Data Supplier sesuai schema ERD backend.
 */
data class Supplier(
    val id: Int,
    val nama: String
)

/**
 * Model Data Produk sesuai schema ERD backend.
 */
data class Produk(
    val id: Int,
    val nama: String,
    val satuan: String, // misal "eceran", "kg", "pcs", "liter"
    val hargaBeliDefault: Double,
    val stokSekarang: Int
)

/**
 * Model Data Barang Masuk (US-12) sesuai ERD backend.
 */
data class BarangMasuk(
    val id: Int = 0,
    val supplierId: Int,
    val supplierNama: String = "",
    val produkId: Int,
    val produkNama: String = "",
    val satuan: String = "eceran",
    val jumlah: Int,
    val hargaBeli: Double,
    val totalPembelian: Double = jumlah * hargaBeli,
    val tanggal: String, // format "24 Nov 2026"
    val status: String = "Selesai",
    val stokSebelum: Int = 0,
    val stokSetelah: Int = stokSebelum + jumlah
)
