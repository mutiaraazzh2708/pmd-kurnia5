package com.pmdkurnia5.pmd_kurnia5.util

import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Utility functions for formatting currency and dates.
 */
object FormatUtils {

    /**
     * Formats a double value to Indonesian Rupiah representation (e.g. "Rp 768.000").
     */
    fun formatRupiah(amount: Double): String {
        val localeID = Locale("id", "ID")
        val numberFormat = NumberFormat.getCurrencyInstance(localeID).apply {
            maximumFractionDigits = 0
            minimumFractionDigits = 0
        }
        val formatted = numberFormat.format(amount)
        // Adjust formatting from "Rp768.000,00" or "Rp768.000" to "Rp 768.000"
        return formatted.replace("Rp", "Rp ").trim()
    }

    /**
     * Formats date to display format "24 Nov 2026".
     */
    fun formatDateDisplay(date: Date = Date()): String {
        val localeID = Locale("id", "ID")
        val formatter = SimpleDateFormat("dd MMM yyyy", localeID)
        return formatter.format(date)
    }

    /**
     * Formats Date to ISO string "yyyy-MM-dd".
     */
    fun formatDateIso(date: Date = Date()): String {
        val formatter = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        return formatter.format(date)
    }
}
