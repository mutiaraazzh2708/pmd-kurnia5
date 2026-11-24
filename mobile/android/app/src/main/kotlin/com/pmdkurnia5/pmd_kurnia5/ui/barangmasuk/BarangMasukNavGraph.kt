package com.pmdkurnia5.pmd_kurnia5.ui.barangmasuk

import androidx.compose.runtime.Composable
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

object BarangMasukRoutes {
    const val LIST = "barang_masuk_list"
    const val CATAT = "catat_barang_masuk"
    const val KONFIRMASI = "konfirmasi_barang_masuk"
    const val SUKSES = "barang_masuk_sukses"
}

/**
 * Navigation Graph untuk Fitur Barang Masuk (US-12).
 * Navigasi antar 4 layar: List -> Catat Form -> Konfirmasi -> Sukses.
 */
@Composable
fun BarangMasukNavGraph(
    navController: NavHostController = rememberNavController(),
    viewModel: BarangMasukViewModel = viewModel(),
    onNavigateToStok: () -> Unit = {}
) {
    NavHost(
        navController = navController,
        startDestination = BarangMasukRoutes.LIST
    ) {
        // 1. BarangMasukListScreen (layar 06)
        composable(BarangMasukRoutes.LIST) {
            BarangMasukListScreen(
                viewModel = viewModel,
                onCatatBarangMasukClick = {
                    viewModel.resetForm()
                    navController.navigate(BarangMasukRoutes.CATAT)
                },
                onTabSelected = { route ->
                    if (route == "stok") {
                        onNavigateToStok()
                    }
                }
            )
        }

        // 2. CatatBarangMasukScreen (layar 07 dan 08)
        composable(BarangMasukRoutes.CATAT) {
            CatatBarangMasukScreen(
                viewModel = viewModel,
                onBackClick = { navController.popBackStack() },
                onNavigateToConfirmation = {
                    navController.navigate(BarangMasukRoutes.KONFIRMASI)
                }
            )
        }

        // 3. KonfirmasiBarangMasukScreen (layar 09)
        composable(BarangMasukRoutes.KONFIRMASI) {
            KonfirmasiBarangMasukScreen(
                viewModel = viewModel,
                onBackClick = { navController.popBackStack() },
                onSimpanSuccess = {
                    navController.navigate(BarangMasukRoutes.SUKSES) {
                        popUpTo(BarangMasukRoutes.LIST) { inclusive = false }
                    }
                }
            )
        }

        // 4. BarangMasukSuksesScreen (layar 10)
        composable(BarangMasukRoutes.SUKSES) {
            BarangMasukSuksesScreen(
                viewModel = viewModel,
                onLihatStokClick = {
                    onNavigateToStok()
                },
                onCatatLagiClick = {
                    navController.navigate(BarangMasukRoutes.CATAT) {
                        popUpTo(BarangMasukRoutes.LIST) { inclusive = false }
                    }
                }
            )
        }
    }
}
