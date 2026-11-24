package com.pmdkurnia5.pmd_kurnia5.ui.barangmasuk

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.pmdkurnia5.pmd_kurnia5.R
import com.pmdkurnia5.pmd_kurnia5.model.Produk
import com.pmdkurnia5.pmd_kurnia5.model.Supplier
import com.pmdkurnia5.pmd_kurnia5.ui.components.AppHeader
import com.pmdkurnia5.pmd_kurnia5.ui.components.AppTextField
import com.pmdkurnia5.pmd_kurnia5.ui.components.DropdownField
import com.pmdkurnia5.pmd_kurnia5.ui.components.PrimaryButton
import com.pmdkurnia5.pmd_kurnia5.ui.theme.PMDKurnia5Theme
import com.pmdkurnia5.pmd_kurnia5.ui.theme.SurfaceLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSecondary

/**
 * Layar 07 & 08: CatatBarangMasukScreen
 * - Header "Catat Barang Masuk" dengan tombol kembali.
 * - Form Supplier, Produk, Jumlah + Satuan, Harga Beli, Tanggal Masuk, Total Pembelian.
 * - State Validasi (border merah + error text).
 * - Tombol "Simpan" -> ke Layar Konfirmasi.
 */
@Composable
fun CatatBarangMasukScreen(
    viewModel: BarangMasukViewModel,
    onBackClick: () -> Unit,
    onNavigateToConfirmation: () -> Unit
) {
    val suppliers by viewModel.suppliers.collectAsState()
    val produkList by viewModel.produkList.collectAsState()
    val formState by viewModel.formState.collectAsState()
    val errorState by viewModel.errorState.collectAsState()

    CatatBarangMasukContent(
        suppliers = suppliers,
        produkList = produkList,
        formState = formState,
        errorState = errorState,
        onSupplierSelected = { viewModel.onSupplierSelected(it) },
        onProdukSelected = { viewModel.onProdukSelected(it) },
        onJumlahChanged = { viewModel.onJumlahChanged(it) },
        onHargaBeliChanged = { viewModel.onHargaBeliChanged(it) },
        onTanggalChanged = { viewModel.onTanggalChanged(it) },
        onBackClick = onBackClick,
        onSimpanClick = {
            if (viewModel.validateForm()) {
                onNavigateToConfirmation()
            }
        }
    )
}

@Composable
fun CatatBarangMasukContent(
    suppliers: List<Supplier>,
    produkList: List<Produk>,
    formState: FormBarangMasukState,
    errorState: FormErrorState,
    onSupplierSelected: (Supplier) -> Unit,
    onProdukSelected: (Produk) -> Unit,
    onJumlahChanged: (String) -> Unit,
    onHargaBeliChanged: (String) -> Unit,
    onTanggalChanged: (String) -> Unit,
    onBackClick: () -> Unit,
    onSimpanClick: () -> Unit
) {
    Scaffold(
        topBar = {
            AppHeader(
                title = stringResource(id = R.string.title_catat_barang_masuk),
                onBackClick = onBackClick
            )
        },
        containerColor = SurfaceLight
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp)
            ) {
                // Dropdown Supplier
                DropdownField(
                    label = stringResource(id = R.string.label_supplier),
                    items = suppliers,
                    selectedItem = formState.selectedSupplier,
                    itemLabel = { it.nama },
                    onItemSelected = onSupplierSelected,
                    placeholder = stringResource(id = R.string.placeholder_supplier),
                    errorMessage = errorState.supplierError
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Dropdown Produk
                DropdownField(
                    label = stringResource(id = R.string.label_produk),
                    items = produkList,
                    selectedItem = formState.selectedProduk,
                    itemLabel = { it.nama },
                    onItemSelected = onProdukSelected,
                    placeholder = stringResource(id = R.string.placeholder_produk),
                    errorMessage = errorState.produkError
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Jumlah & Satuan (Otomatis dari produk)
                Row(modifier = Modifier.fillMaxWidth()) {
                    AppTextField(
                        label = stringResource(id = R.string.label_jumlah),
                        value = formState.jumlahText,
                        onValueChange = onJumlahChanged,
                        placeholder = "0",
                        keyboardType = KeyboardType.Number,
                        errorMessage = errorState.jumlahError,
                        modifier = Modifier.weight(1.5f)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    AppTextField(
                        label = stringResource(id = R.string.label_satuan),
                        value = formState.satuanText,
                        onValueChange = {},
                        readOnly = true,
                        modifier = Modifier.weight(1f)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Harga Beli per satuan
                AppTextField(
                    label = stringResource(id = R.string.label_harga_beli),
                    value = formState.hargaBeliText,
                    onValueChange = onHargaBeliChanged,
                    placeholder = "0",
                    prefix = "Rp ",
                    keyboardType = KeyboardType.Number,
                    errorMessage = errorState.hargaError
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Tanggal Masuk (default hari ini, format "24 Nov 2026")
                AppTextField(
                    label = stringResource(id = R.string.label_tanggal_masuk),
                    value = formState.tanggalText,
                    onValueChange = onTanggalChanged,
                    readOnly = true,
                    suffixIcon = {
                        Icon(
                            imageVector = Icons.Default.CalendarToday,
                            contentDescription = "Tanggal",
                            tint = TextSecondary
                        )
                    }
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Total Pembelian (read-only = jumlah x harga)
                AppTextField(
                    label = stringResource(id = R.string.label_total_pembelian),
                    value = formState.totalPembelianText,
                    onValueChange = {},
                    readOnly = true
                )

                Spacer(modifier = Modifier.height(24.dp))
            }

            // Tombol Simpan
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .padding(16.dp)
            ) {
                PrimaryButton(
                    text = stringResource(id = R.string.btn_simpan),
                    onClick = onSimpanClick
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun CatatBarangMasukNormalPreview() {
    PMDKurnia5Theme {
        CatatBarangMasukContent(
            suppliers = listOf(Supplier(1, "PT Wilmar Nabati Indonesia")),
            produkList = listOf(Produk(1, "Minyak Goreng 2 L", "eceran", 32000.0, 48)),
            formState = FormBarangMasukState(
                jumlahText = "24",
                hargaBeliText = "32000",
                totalPembelianText = "Rp 768.000"
            ),
            errorState = FormErrorState(),
            onSupplierSelected = {},
            onProdukSelected = {},
            onJumlahChanged = {},
            onHargaBeliChanged = {},
            onTanggalChanged = {},
            onBackClick = {},
            onSimpanClick = {}
        )
    }
}

@Preview(showBackground = true)
@Composable
fun CatatBarangMasukErrorPreview() {
    PMDKurnia5Theme {
        CatatBarangMasukContent(
            suppliers = emptyList(),
            produkList = emptyList(),
            formState = FormBarangMasukState(),
            errorState = FormErrorState(
                supplierError = "Pilih supplier terlebih dahulu",
                jumlahError = "Jumlah harus lebih dari 0",
                hargaError = "Harga beli harus lebih dari 0"
            ),
            onSupplierSelected = {},
            onProdukSelected = {},
            onJumlahChanged = {},
            onHargaBeliChanged = {},
            onTanggalChanged = {},
            onBackClick = {},
            onSimpanClick = {}
        )
    }
}
