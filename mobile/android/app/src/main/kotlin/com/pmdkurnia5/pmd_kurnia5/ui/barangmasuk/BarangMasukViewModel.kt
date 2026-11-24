package com.pmdkurnia5.pmd_kurnia5.ui.barangmasuk

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.pmdkurnia5.pmd_kurnia5.model.BarangMasuk
import com.pmdkurnia5.pmd_kurnia5.model.Produk
import com.pmdkurnia5.pmd_kurnia5.model.Supplier
import com.pmdkurnia5.pmd_kurnia5.repository.BarangMasukRepository
import com.pmdkurnia5.pmd_kurnia5.repository.DummyBarangMasukRepository
import com.pmdkurnia5.pmd_kurnia5.util.FormatUtils
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

/**
 * State untuk Form Catat Barang Masuk.
 */
data class FormBarangMasukState(
    val selectedSupplier: Supplier? = null,
    val selectedProduk: Produk? = null,
    val jumlahText: String = "",
    val hargaBeliText: String = "",
    val tanggalText: String = FormatUtils.formatDateDisplay(),
    val satuanText: String = "eceran",
    val totalPembelianText: String = "Rp 0"
)

/**
 * State Error untuk Validasi Form.
 */
data class FormErrorState(
    val supplierError: String? = null,
    val produkError: String? = null,
    val jumlahError: String? = null,
    val hargaError: String? = null
)

/**
 * ViewModel untuk Fitur Barang Masuk (US-12).
 * Memakai StateFlow untuk mengelola state daftar, form, error, dan konfirmasi.
 */
class BarangMasukViewModel(
    private val repository: BarangMasukRepository = DummyBarangMasukRepository()
) : ViewModel() {

    // Filter Chip: "Semua", "Hari ini", "Minggu ini"
    private val _selectedFilter = MutableStateFlow("Semua")
    val selectedFilter: StateFlow<String> = _selectedFilter.asStateFlow()

    // Flow Daftar Barang Masuk
    val barangMasukList: StateFlow<List<BarangMasuk>> = combine(
        _selectedFilter
    ) { filterArray ->
        filterArray[0]
    }.combine(repository.getBarangMasukList("Semua")) { filter, list ->
        when (filter) {
            "Hari ini" -> list.filter { it.tanggal == FormatUtils.formatDateDisplay() || it.tanggal == "24 Nov 2026" }
            "Minggu ini" -> list
            else -> list
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Flow Master Data Supplier & Produk
    val suppliers: StateFlow<List<Supplier>> = repository.getSuppliers()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val produkList: StateFlow<List<Produk>> = repository.getProdukList()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // State Form & Error
    private val _formState = MutableStateFlow(FormBarangMasukState())
    val formState: StateFlow<FormBarangMasukState> = _formState.asStateFlow()

    private val _errorState = MutableStateFlow(FormErrorState())
    val errorState: StateFlow<FormErrorState> = _errorState.asStateFlow()

    // Result Barang Masuk setelah tersimpan
    private val _savedBarangMasuk = MutableStateFlow<BarangMasuk?>(null)
    val savedBarangMasuk: StateFlow<BarangMasuk?> = _savedBarangMasuk.asStateFlow()

    fun setFilter(filter: String) {
        _selectedFilter.value = filter
    }

    fun onSupplierSelected(supplier: Supplier) {
        _formState.update { it.copy(selectedSupplier = supplier) }
        _errorState.update { it.copy(supplierError = null) }
    }

    fun onProdukSelected(produk: Produk) {
        val hargaBeliFormatted = if (produk.hargaBeliDefault > 0) {
            produk.hargaBeliDefault.toLong().toString()
        } else ""

        _formState.update {
            it.copy(
                selectedProduk = produk,
                satuanText = produk.satuan,
                hargaBeliText = hargaBeliFormatted
            )
        }
        _errorState.update { it.copy(produkError = null) }
        recalculateTotal()
    }

    fun onJumlahChanged(jumlahStr: String) {
        _formState.update { it.copy(jumlahText = jumlahStr) }
        _errorState.update { it.copy(jumlahError = null) }
        recalculateTotal()
    }

    fun onHargaBeliChanged(hargaStr: String) {
        _formState.update { it.copy(hargaBeliText = hargaStr) }
        _errorState.update { it.copy(hargaError = null) }
        recalculateTotal()
    }

    fun onTanggalChanged(tanggal: String) {
        _formState.update { it.copy(tanggalText = tanggal) }
    }

    private fun recalculateTotal() {
        val jumlah = _formState.value.jumlahText.toDoubleOrNull() ?: 0.0
        val harga = _formState.value.hargaBeliText.toDoubleOrNull() ?: 0.0
        val total = jumlah * harga
        _formState.update {
            it.copy(totalPembelianText = FormatUtils.formatRupiah(total))
        }
    }

    /**
     * Validasi form sesuai aturan US-12:
     * - Supplier kosong -> "Pilih supplier terlebih dahulu"
     * - Produk kosong -> "Pilih produk terlebih dahulu"
     * - Jumlah <= 0 -> "Jumlah harus lebih dari 0"
     * - Harga <= 0 -> "Harga beli harus lebih dari 0"
     */
    fun validateForm(): Boolean {
        val current = _formState.value
        val supplierErr = if (current.selectedSupplier == null) "Pilih supplier terlebih dahulu" else null
        val produkErr = if (current.selectedProduk == null) "Pilih produk terlebih dahulu" else null

        val jumlahVal = current.jumlahText.toIntOrNull() ?: 0
        val jumlahErr = if (jumlahVal <= 0) "Jumlah harus lebih dari 0" else null

        val hargaVal = current.hargaBeliText.toDoubleOrNull() ?: 0.0
        val hargaErr = if (hargaVal <= 0) "Harga beli harus lebih dari 0" else null

        val errors = FormErrorState(
            supplierError = supplierErr,
            produkError = produkErr,
            jumlahError = jumlahErr,
            hargaError = hargaErr
        )
        _errorState.value = errors

        return supplierErr == null && produkErr == null && jumlahErr == null && hargaErr == null
    }

    /**
     * Membangun objek BarangMasuk untuk layar konfirmasi.
     */
    fun getBarangMasukConfirmation(): BarangMasuk {
        val form = _formState.value
        val produk = form.selectedProduk
        val jumlah = form.jumlahText.toIntOrNull() ?: 0
        val harga = form.hargaBeliText.toDoubleOrNull() ?: 0.0
        val stokSebelum = produk?.stokSekarang ?: 0

        return BarangMasuk(
            supplierId = form.selectedSupplier?.id ?: 0,
            supplierNama = form.selectedSupplier?.nama ?: "",
            produkId = produk?.id ?: 0,
            produkNama = produk?.nama ?: "",
            satuan = form.satuanText,
            jumlah = jumlah,
            hargaBeli = harga,
            totalPembelian = jumlah * harga,
            tanggal = form.tanggalText,
            status = "Selesai",
            stokSebelum = stokSebelum,
            stokSetelah = stokSebelum + jumlah
        )
    }

    /**
     * Menyimpan Barang Masuk ke Repository.
     */
    fun simpanBarangMasuk(onSuccess: () -> Unit) {
        val barangMasuk = getBarangMasukConfirmation()
        viewModelScope.launch {
            val result = repository.simpanBarangMasuk(barangMasuk)
            if (result.isSuccess) {
                _savedBarangMasuk.value = result.getOrNull()
                onSuccess()
            }
        }
    }

    /**
     * Reset form setelah pencatatan selesai / catat lagi.
     */
    fun resetForm() {
        _formState.value = FormBarangMasukState()
        _errorState.value = FormErrorState()
    }
}
