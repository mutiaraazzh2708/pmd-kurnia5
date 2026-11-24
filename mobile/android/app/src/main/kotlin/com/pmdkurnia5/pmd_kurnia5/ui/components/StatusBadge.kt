package com.pmdkurnia5.pmd_kurnia5.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pmdkurnia5.pmd_kurnia5.R
import com.pmdkurnia5.pmd_kurnia5.ui.theme.GreenSuccess
import com.pmdkurnia5.pmd_kurnia5.ui.theme.GreenSuccessBg

/**
 * Status Badge "Selesai" warna hijau sesuai Figma.
 */
@Composable
fun StatusBadge(
    statusText: String = stringResource(id = R.string.status_selesai),
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(6.dp))
            .background(GreenSuccessBg)
            .padding(horizontal = 8.dp, vertical = 4.dp)
    ) {
        Text(
            text = statusText,
            color = GreenSuccess,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold
        )
    }
}
