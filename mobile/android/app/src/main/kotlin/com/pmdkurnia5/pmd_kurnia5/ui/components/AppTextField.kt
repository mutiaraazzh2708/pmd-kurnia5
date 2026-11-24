package com.pmdkurnia5.pmd_kurnia5.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pmdkurnia5.pmd_kurnia5.ui.theme.BorderLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.ErrorRed
import com.pmdkurnia5.pmd_kurnia5.ui.theme.ErrorRedBorder
import com.pmdkurnia5.pmd_kurnia5.ui.theme.SurfaceLight
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextPrimary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSecondary
import com.pmdkurnia5.pmd_kurnia5.ui.theme.TextSubtle

/**
 * Reusable Custom AppTextField dengan dukungan:
 * - Label & Placeholder
 * - Prefix (misal "Rp")
 * - Suffix / Icon
 * - Read-only state (background abu-abu)
 * - State error (border merah & teks error kecil)
 */
@Composable
fun AppTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    prefix: String? = null,
    suffixIcon: @Composable (() -> Unit)? = null,
    readOnly: Boolean = false,
    errorMessage: String? = null,
    keyboardType: KeyboardType = KeyboardType.Text,
    onClick: (() -> Unit)? = null
) {
    val isError = errorMessage != null
    val borderColor = when {
        isError -> ErrorRed
        readOnly -> BorderLight
        else -> BorderLight
    }
    val backgroundColor = if (readOnly) SurfaceLight else Color.White

    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = label,
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium,
            color = TextSecondary
        )
        Spacer(modifier = Modifier.height(6.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(10.dp))
                .background(backgroundColor)
                .border(
                    width = if (isError) 1.5.dp else 1.dp,
                    color = borderColor,
                    shape = RoundedCornerShape(10.dp)
                )
                .then(
                    if (onClick != null) Modifier.clickable { onClick() }
                    else Modifier
                )
                .padding(horizontal = 14.dp, vertical = 14.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (prefix != null) {
                    Text(
                        text = prefix,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = TextPrimary
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    if (value.isEmpty() && placeholder.isNotEmpty()) {
                        Text(
                            text = placeholder,
                            fontSize = 15.sp,
                            color = TextSubtle
                        )
                    }
                    BasicTextField(
                        value = value,
                        onValueChange = onValueChange,
                        readOnly = readOnly || onClick != null,
                        enabled = !readOnly && onClick == null,
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
                        textStyle = TextStyle(
                            fontSize = 15.sp,
                            color = if (readOnly) TextSecondary else TextPrimary,
                            fontWeight = FontWeight.Normal
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                if (suffixIcon != null) {
                    suffixIcon()
                }
            }
        }
        if (errorMessage != null) {
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = errorMessage,
                color = ErrorRed,
                fontSize = 12.sp,
                fontWeight = FontWeight.Normal
            )
        }
    }
}
