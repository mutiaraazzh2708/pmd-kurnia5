package com.pmdkurnia5.pmd_kurnia5.repository

import com.pmdkurnia5.pmd_kurnia5.model.BarangMasuk
import com.pmdkurnia5.pmd_kurnia5.model.Produk
import com.pmdkurnia5.pmd_kurnia5.model.Supplier
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map

/**
 * Interface Repository Barang Masuk.
 * Disiapkan agar mudah di-switch ke Room DB / REST API backend.
 */
interface BarangMasukRepository {
    fun getBarangMasukList(filter: String): Flow<List<BarangMasuk>>
    fun getSuppliers(): Flow<List<Supplier>>
    fun getProdukList(): Flow<List<Produk>>
    suspend fun simpanBarangMasuk(barangMasuk: BarangMasuk): Result<BarangMasuk>
}

/**
 * Repository Dummy untuk prototype UI US-12.
 */
class DummyBarangMasukRepository : BarangMasukRepository {

    private val dummySuppliers = listOf(
        Supplier(id = 1, nama = "PT Indofood Sukses"),
        Supplier(id = 2, nama = "CV Sembako Jaya"),
        Supplier(id = 3, nama = "Distributor Berkas Bersama"),
        Supplier(id = 4, nama = "PT Wilmar Nabati Indonesia")
    )

    private val dummyProduk = listOf(
        Produk(id = 1, nama = "Minyak Goreng 2 L", satuan = "eceran", hargaBeliDefault = 32000.0, stokSekarang = 48),
        Produk(id = 2, nama = "Beras Pandan Wangi 5 kg", satuan = "karung", hargaBeliDefault = 68000.0, stokSekarang = 20),
        Produk(id = 3, nama = "Gula Pasir 1 kg", satuan = "bungkus", hargaBeliDefault = 14500.0, stokSekarang = 100),
        Produk(id = 4, nama = "Tepung Terigu 1 kg", satuan = "pcs", hargaBeliDefault = 11000.0, stokSekarang = 60)
    )

    private val dummyBarangMasuk = MutableStateFlow(
        listOf(
            BarangMasuk(
                id = 1,
                supplierId = 4,
                supplierNama = "PT Wilmar Nabati Indonesia",
                produkId = 1,
                produkNama = "Minyak Goreng 2 L",
                satuan = "eceran",
                jumlah = 24,
                hargaBeli = 32000.0,
                totalPembelian = 768000.0,
                tanggal = "24 Nov 2026",
                status = "Selesai",
                stokSebelum = 24,
                stokSetelah = 48
            ),
            BarangMasuk(
                id = 2,
                supplierId = 1,
                supplierNama = "PT Indofood Sukses",
                produkId = 4,
                produkNama = "Tepung Terigu 1 kg",
                satuan = "pcs",
                jumlah = 50,
                hargaBeli = 11000.0,
                totalPembelian = 550000.0,
                tanggal = "23 Nov 2026",
                status = "Selesai",
                stokSebelum = 10,
                stokSetelah = 60
            ),
            BarangMasuk(
                id = 3,
                supplierId = 2,
                supplierNama = "CV Sembako Jaya",
                produkId = 3,
                produkNama = "Gula Pasir 1 kg",
                satuan = "bungkus",
                jumlah = 100,
                hargaBeli = 14500.0,
                totalPembelian = 1450000.0,
                tanggal = "20 Nov 2026",
                status = "Selesai",
                stokSebelum = 0,
                stokSetelah = 100
            )
        )
    )

    override fun getBarangMasukList(filter: String): Flow<List<BarangMasuk>> {
        return dummyBarangMasuk.asStateFlow().map { list ->
            when (filter) {
                "Hari ini" -> list.filter { it.tanggal == "24 Nov 2026" }
                "Minggu ini" -> list // prototype: semua data minggu ini
                else -> list
            }
        }
    }

    override fun getSuppliers(): Flow<List<Supplier>> = MutableStateFlow(dummySuppliers)

    override fun getProdukList(): Flow<List<Produk>> = MutableStateFlow(dummyProduk)

    override suspend fun simpanBarangMasuk(barangMasuk: BarangMasuk): Result<BarangMasuk> {
        val currentList = dummyBarangMasuk.value.toMutableList()
        val newId = (currentList.maxOfOrNull { it.id } ?: 0) + 1
        val itemSaved = barangMasuk.copy(id = newId)
        currentList.add(0, itemSaved)
        dummyBarangMasuk.value = currentList
        return Result.success(itemSaved)
    }
}
