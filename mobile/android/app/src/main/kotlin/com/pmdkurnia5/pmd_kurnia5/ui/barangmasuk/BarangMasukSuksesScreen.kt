package com.pmdkurnia5.pmd_kurnia5.ui.barangmasuk

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pmdkurnia5.pmd_kurnia5.R
import com.pmdkurnia5.pmd_kurnia5.model.BarangMasuk
import com.pmdkurnia5.pmd_kurnia5.ui.components.OutlineButton
import com.pmdkurnia5.pmd_kurnia5.ui.components.PrimaryButton
import com.pmdkurnia5.pmd_kurnia5.ui.theme.GreenSuccess
import com.pmdkurnia5.pmd_kurnia5.ui.theme.GreenSuccessBg
import com.pmdkurnia5.pmd_kurnia5.ui.theme.PMDKurnia5Theme
import com.pmdkurnia5.pmd_kurnia5.ui.theme.SurfaceLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSecondary

/**
 * Layar 10: BarangMasukSuksesScreen
 * - Ikon centang hijau.
 * - Teks "Barang masuk tersimpan".
 * - Deskripsi "Stok Minyak Goreng 2 L bertambah 24 eceran." (dinamis).
 * - Tombol "Lihat Stok" & "Catat Lagi" (outline).
 */
@Composable
fun BarangMasukSuksesScreen(
    viewModel: BarangMasukViewModel,
    onLihatStokClick: () -> Unit,
    onCatatLagiClick: () -> Unit
) {
    val savedItem by viewModel.savedBarangMasuk.collectAsState()

    BarangMasukSuksesContent(
        savedItem = savedItem,
        onLihatStokClick = onLihatStokClick,
        onCatatLagiClick = {
            viewModel.resetForm()
            onCatatLagiClick()
        }
    )
}

@Composable
fun BarangMasukSuksesContent(
    savedItem: BarangMasuk?,
    onLihatStokClick: () -> Unit,
    onCatatLagiClick: () -> Unit
) {
    val produkNama = savedItem?.produkNama ?: "Produk"
    val jumlah = savedItem?.jumlah ?: 0
    val satuan = savedItem?.satuan ?: "eceran"

    val descText = stringResource(
        id = R.string.desc_sukses_format,
        produkNama,
        jumlah,
        satuan
    )

    Scaffold(
        containerColor = SurfaceLight
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            verticalArrangement = Arrangement.SpaceBetween,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // Icon Centang Hijau & Teks Sukses
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(horizontal = 32.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(88.dp)
                        .clip(CircleShape)
                        .background(GreenSuccessBg),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "Sukses",
                        tint = GreenSuccess,
                        modifier = Modifier.size(48.dp)
                    )
                }

                Spacer(modifier = Modifier.height(24.dp))

                Text(
                    text = stringResource(id = R.string.title_sukses_tersimpan),
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = descText,
                    fontSize = 15.sp,
                    color = TextSecondary,
                    textAlign = TextAlign.Center,
                    lineHeight = 22.sp
                )
            }

            // Tombol Aksi Bawah
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .padding(16.dp)
            ) {
                PrimaryButton(
                    text = stringResource(id = R.string.btn_lihat_stok),
                    onClick = onLihatStokClick
                )
                Spacer(modifier = Modifier.height(10.dp))
                OutlineButton(
                    text = stringResource(id = R.string.btn_catat_lagi),
                    onClick = onCatatLagiClick
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun BarangMasukSuksesScreenPreview() {
    PMDKurnia5Theme {
        BarangMasukSuksesContent(
            savedItem = BarangMasuk(
                id = 1,
                supplierId = 1,
                supplierNama = "PT Wilmar Nabati Indonesia",
                produkId = 1,
                produkNama = "Minyak Goreng 2 L",
                satuan = "eceran",
                jumlah = 24,
                hargaBeli = 32000.0,
                tanggal = "24 Nov 2026"
            ),
            onLihatStokClick = {},
            onCatatLagiClick = {}
        )
    }
}
