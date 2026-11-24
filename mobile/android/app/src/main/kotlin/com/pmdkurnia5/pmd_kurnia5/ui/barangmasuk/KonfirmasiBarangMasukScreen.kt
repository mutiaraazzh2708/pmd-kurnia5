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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pmdkurnia5.pmd_kurnia5.R
import com.pmdkurnia5.pmd_kurnia5.model.BarangMasuk
import com.pmdkurnia5.pmd_kurnia5.ui.components.AppHeader
import com.pmdkurnia5.pmd_kurnia5.ui.components.OutlineButton
import com.pmdkurnia5.pmd_kurnia5.ui.components.PrimaryButton
import com.pmdkurnia5.pmd_kurnia5.ui.theme.BorderLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.GreenSuccess
import com.pmdkurnia5.pmd_kurnia5.ui.theme.NavyPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.PMDKurnia5Theme
import com.pmdkurnia5.pmd_kurnia5.ui.theme.SurfaceLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSecondary
import com.pmdkurnia5.pmd_kurnia5.util.FormatUtils

/**
 * Layar 09: KonfirmasiBarangMasukScreen
 * - Header "Konfirmasi"
 * - Kartu Ringkasan: Produk, Supplier, Jumlah, Harga Beli, Total Pembelian, Stok Setelah Masuk (48 -> 72).
 * - Tombol "Ya, simpan" (utama) & "Periksa lagi" (outline).
 */
@Composable
fun KonfirmasiBarangMasukScreen(
    viewModel: BarangMasukViewModel,
    onBackClick: () -> Unit,
    onSimpanSuccess: () -> Unit
) {
    val barangMasuk = viewModel.getBarangMasukConfirmation()

    KonfirmasiBarangMasukContent(
        barangMasuk = barangMasuk,
        onBackClick = onBackClick,
        onYaSimpanClick = {
            viewModel.simpanBarangMasuk(onSuccess = onSimpanSuccess)
        },
        onPeriksaLagiClick = onBackClick
    )
}

@Composable
fun KonfirmasiBarangMasukContent(
    barangMasuk: BarangMasuk,
    onBackClick: () -> Unit,
    onYaSimpanClick: () -> Unit,
    onPeriksaLagiClick: () -> Unit
) {
    Scaffold(
        topBar = {
            AppHeader(
                title = stringResource(id = R.string.title_konfirmasi),
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
                Text(
                    text = stringResource(id = R.string.label_ringkasan),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(12.dp))

                // Kartu Ringkasan
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = barangMasuk.produkNama,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = barangMasuk.supplierNama,
                            fontSize = 14.sp,
                            color = TextSecondary
                        )

                        Spacer(modifier = Modifier.height(12.dp))
                        HorizontalDivider(color = BorderLight)
                        Spacer(modifier = Modifier.height(12.dp))

                        RingkasanRow(
                            label = "Jumlah Masuk",
                            value = "${barangMasuk.jumlah} ${barangMasuk.satuan}"
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        RingkasanRow(
                            label = "Harga Beli per Satuan",
                            value = FormatUtils.formatRupiah(barangMasuk.hargaBeli)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        RingkasanRow(
                            label = "Total Pembelian",
                            value = FormatUtils.formatRupiah(barangMasuk.totalPembelian),
                            isBold = true
                        )

                        Spacer(modifier = Modifier.height(12.dp))
                        HorizontalDivider(color = BorderLight)
                        Spacer(modifier = Modifier.height(12.dp))

                        // Stok Setelah Masuk (misal: 48 -> 72)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = stringResource(id = R.string.label_stok_setelah_masuk),
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium,
                                color = TextSecondary,
                                modifier = Modifier.weight(1f)
                            )
                            Text(
                                text = "${barangMasuk.stokSebelum} → ${barangMasuk.stokSetelah} ${barangMasuk.satuan}",
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                color = GreenSuccess
                            )
                        }
                    }
                }
            }

            // Tombol Aksi Bawah
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .padding(16.dp)
            ) {
                PrimaryButton(
                    text = stringResource(id = R.string.btn_ya_simpan),
                    onClick = onYaSimpanClick
                )
                Spacer(modifier = Modifier.height(10.dp))
                OutlineButton(
                    text = stringResource(id = R.string.btn_periksa_lagi),
                    onClick = onPeriksaLagiClick
                )
            }
        }
    }
}

@Composable
fun RingkasanRow(
    label: String,
    value: String,
    isBold: Boolean = false
) {
    Row(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = label,
            fontSize = 14.sp,
            color = TextSecondary,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = value,
            fontSize = 14.sp,
            fontWeight = if (isBold) FontWeight.Bold else FontWeight.Medium,
            color = if (isBold) NavyPrimary else TextPrimary
        )
    }
}

@Preview(showBackground = true)
@Composable
fun KonfirmasiBarangMasukScreenPreview() {
    PMDKurnia5Theme {
        KonfirmasiBarangMasukContent(
            barangMasuk = BarangMasuk(
                id = 1,
                supplierId = 1,
                supplierNama = "PT Wilmar Nabati Indonesia",
                produkId = 1,
                produkNama = "Minyak Goreng 2 L",
                satuan = "eceran",
                jumlah = 24,
                hargaBeli = 32000.0,
                totalPembelian = 768000.0,
                tanggal = "24 Nov 2026",
                stokSebelum = 48,
                stokSetelah = 72
            ),
            onBackClick = {},
            onYaSimpanClick = {},
            onPeriksaLagiClick = {}
        )
    }
}
