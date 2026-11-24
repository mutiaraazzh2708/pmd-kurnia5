package com.pmdkurnia5.pmd_kurnia5.ui.barangmasuk

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Inventory2
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pmdkurnia5.pmd_kurnia5.R
import com.pmdkurnia5.pmd_kurnia5.model.BarangMasuk
import com.pmdkurnia5.pmd_kurnia5.ui.components.AppHeader
import com.pmdkurnia5.pmd_kurnia5.ui.components.BottomNavBar
import com.pmdkurnia5.pmd_kurnia5.ui.components.PrimaryButton
import com.pmdkurnia5.pmd_kurnia5.ui.components.StatusBadge
import com.pmdkurnia5.pmd_kurnia5.ui.theme.GreenSuccess
import com.pmdkurnia5.pmd_kurnia5.ui.theme.NavyHeader
import com.pmdkurnia5.pmd_kurnia5.ui.theme.NavyPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.PMDKurnia5Theme
import com.pmdkurnia5.pmd_kurnia5.ui.theme.SurfaceLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSecondary

/**
 * Layar 06: BarangMasukListScreen
 * - Header "Barang Masuk"
 * - Filter chip: Semua, Hari ini, Minggu ini
 * - List kartu: ikon produk, nama produk, supplier + tanggal, jumlah (+24), badge "Selesai"
 * - Tombol bawah "+ Catat Barang Masuk" -> ke form
 */
@Composable
fun BarangMasukListScreen(
    viewModel: BarangMasukViewModel,
    onCatatBarangMasukClick: () -> Unit,
    onTabSelected: (String) -> Unit = {}
) {
    val items by viewModel.barangMasukList.collectAsState()
    val selectedFilter by viewModel.selectedFilter.collectAsState()

    BarangMasukListContent(
        items = items,
        selectedFilter = selectedFilter,
        onFilterSelected = { viewModel.setFilter(it) },
        onCatatBarangMasukClick = onCatatBarangMasukClick,
        onTabSelected = onTabSelected
    )
}

@Composable
fun BarangMasukListContent(
    items: List<BarangMasuk>,
    selectedFilter: String,
    onFilterSelected: (String) -> Unit,
    onCatatBarangMasukClick: () -> Unit,
    onTabSelected: (String) -> Unit = {}
) {
    val filterOptions = listOf(
        stringResource(id = R.string.filter_semua),
        stringResource(id = R.string.filter_hari_ini),
        stringResource(id = R.string.filter_minggu_ini)
    )

    Scaffold(
        topBar = {
            AppHeader(title = stringResource(id = R.string.title_barang_masuk))
        },
        bottomBar = {
            BottomNavBar(
                currentRoute = "barang_masuk_list",
                onTabSelected = onTabSelected
            )
        },
        containerColor = SurfaceLight
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Filter Chips Row
            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(filterOptions) { filter ->
                    val isSelected = filter == selectedFilter
                    FilterChip(
                        selected = isSelected,
                        onClick = { onFilterSelected(filter) },
                        label = {
                            Text(
                                text = filter,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                fontSize = 13.sp
                            )
                        },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = NavyPrimary,
                            selectedLabelColor = Color.White,
                            containerColor = Color.White,
                            labelColor = TextSecondary
                        ),
                        border = FilterChipDefaults.filterChipBorder(
                            enabled = true,
                            selected = isSelected,
                            borderColor = if (isSelected) NavyPrimary else Color(0FFE2E8F0)
                        )
                    )
                }
            }

            // List Kartu Barang Masuk
            LazyColumn(
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(items, key = { it.id }) { item ->
                    BarangMasukItemCard(item = item)
                }
            }

            // Tombol Utama Bawah "+ Catat Barang Masuk"
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .padding(16.dp)
            ) {
                PrimaryButton(
                    text = stringResource(id = R.string.btn_catat_barang_masuk),
                    onClick = onCatatBarangMasukClick
                )
            }
        }
    }
}

@Composable
fun BarangMasukItemCard(item: BarangMasuk) {
    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Ikon Produk
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(NavyHeader.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Inventory2,
                    contentDescription = null,
                    tint = NavyHeader,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            // Nama Produk, Supplier & Tanggal
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = item.produkNama,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${item.supplierNama} • ${item.tanggal}",
                    fontSize = 13.sp,
                    color = TextSecondary
                )
            }

            Spacer(modifier = Modifier.width(8.dp))

            // Jumlah & Badge Status Selesai
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = "+${item.jumlah}",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = GreenSuccess
                )
                Spacer(modifier = Modifier.height(4.dp))
                StatusBadge(statusText = item.status)
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun BarangMasukListScreenPreview() {
    PMDKurnia5Theme {
        BarangMasukListContent(
            items = listOf(
                BarangMasuk(
                    id = 1,
                    supplierId = 1,
                    supplierNama = "PT Wilmar Nabati Indonesia",
                    produkId = 1,
                    produkNama = "Minyak Goreng 2 L",
                    jumlah = 24,
                    hargaBeli = 32000.0,
                    tanggal = "24 Nov 2026",
                    status = "Selesai"
                ),
                BarangMasuk(
                    id = 2,
                    supplierId = 2,
                    supplierNama = "PT Indofood Sukses",
                    produkId = 2,
                    produkNama = "Tepung Terigu 1 kg",
                    jumlah = 50,
                    hargaBeli = 11000.0,
                    tanggal = "23 Nov 2026",
                    status = "Selesai"
                )
            ),
            selectedFilter = "Semua",
            onFilterSelected = {},
            onCatatBarangMasukClick = {}
        )
    }
}
