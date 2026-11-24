package com.pmdkurnia5.pmd_kurnia5.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Inventory
import androidx.compose.material.icons.filled.MoveToInbox
import androidx.compose.material.icons.filled.People
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pmdkurnia5.pmd_kurnia5.R
import com.pmdkurnia5.pmd_kurnia5.ui.theme.NavyPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSubtle

data class NavTabItem(
    val title: String,
    val icon: ImageVector,
    val route: String
)

/**
 * Bottom Navigation Bar 4 tab:
 * Beranda, Supplier, Masuk (aktif), Stok.
 */
@Composable
fun BottomNavBar(
    currentRoute: String = "barang_masuk_list",
    onTabSelected: (String) -> Unit = {}
) {
    val tabs = listOf(
        NavTabItem(stringResource(id = R.string.tab_beranda), Icons.Default.Home, "beranda"),
        NavTabItem(stringResource(id = R.string.tab_supplier), Icons.Default.People, "supplier"),
        NavTabItem(stringResource(id = R.string.tab_masuk), Icons.Default.MoveToInbox, "barang_masuk_list"),
        NavTabItem(stringResource(id = R.string.tab_stok), Icons.Default.Inventory, "stok")
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White)
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceAround,
        verticalAlignment = Alignment.CenterVertically
    ) {
        tabs.forEach { tab ->
            val isActive = tab.route == currentRoute
            val tintColor = if (isActive) NavyPrimary else TextSubtle

            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .clickable { onTabSelected(tab.route) }
                    .padding(horizontal = 12.dp, vertical = 4.dp)
            ) {
                Icon(
                    imageVector = tab.icon,
                    contentDescription = tab.title,
                    tint = tintColor
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = tab.title,
                    fontSize = 11.sp,
                    fontWeight = if (isActive) FontWeight.Bold else FontWeight.Medium,
                    color = tintColor
                )
            }
        }
    }
}
