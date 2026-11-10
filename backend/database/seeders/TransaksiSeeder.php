<?php

namespace Database\Seeders;

use App\Models\DetailTransaksi;
use App\Models\Produk;
use App\Models\Retur;
use App\Models\Transaksi;
use App\Models\User;
use Illuminate\Database\Seeder;

class TransaksiSeeder extends Seeder
{
    public function run(): void
    {
        $kasir = User::where('role', 'kasir')->first() ?? User::first();
        if (!$kasir) {
            return;
        }

        $minyak = Produk::where('nama', 'like', '%Minyak%')->first();
        $gula   = Produk::where('nama', 'like', '%Gula%')->first();
        $beras  = Produk::where('nama', 'like', '%Beras%')->first();

        if (!$minyak || !$gula) {
            return;
        }

        // Transaksi 1: Pembeli Umum (Minyak + Gula)
        $subtotal1 = $minyak->harga_jual * 2;
        $subtotal2 = $gula->harga_jual * 3;
        $total1    = $subtotal1 + $subtotal2;

        $trx1 = Transaksi::create([
            'user_id'      => $kasir->id,
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'total'        => $total1,
            'created_at'   => now()->subHours(3),
            'updated_at'   => now()->subHours(3),
        ]);

        DetailTransaksi::create([
            'transaksi_id' => $trx1->id,
            'produk_id'    => $minyak->id,
            'jumlah'       => 2,
            'harga'        => $minyak->harga_jual,
            'subtotal'     => $subtotal1,
            'created_at'   => now()->subHours(3),
            'updated_at'   => now()->subHours(3),
        ]);

        DetailTransaksi::create([
            'transaksi_id' => $trx1->id,
            'produk_id'    => $gula->id,
            'jumlah'       => 3,
            'harga'        => $gula->harga_jual,
            'subtotal'     => $subtotal2,
            'created_at'   => now()->subHours(3),
            'updated_at'   => now()->subHours(3),
        ]);

        // Retur untuk transaksi 1: 1 buah Gula Pasir diretur karena kemasan bocor
        Retur::create([
            'transaksi_id' => $trx1->id,
            'produk_id'    => $gula->id,
            'jumlah'       => 1,
            'alasan'       => 'Kemasan bocor / cacat',
            'created_at'   => now()->subHours(1),
            'updated_at'   => now()->subHours(1),
        ]);

        // Transaksi 2: Pembeli Reseller (Beras / Minyak)
        if ($beras) {
            $subtotalBeras = $beras->harga_jual * 1;
            $trx2 = Transaksi::create([
                'user_id'      => $kasir->id,
                'tipe_pembeli' => 'reseller',
                'metode_bayar' => 'transfer',
                'total'        => $subtotalBeras,
                'created_at'   => now()->subMinutes(45),
                'updated_at'   => now()->subMinutes(45),
            ]);

            DetailTransaksi::create([
                'transaksi_id' => $trx2->id,
                'produk_id'    => $beras->id,
                'jumlah'       => 1,
                'harga'        => $beras->harga_jual,
                'subtotal'     => $subtotalBeras,
                'created_at'   => now()->subMinutes(45),
                'updated_at'   => now()->subMinutes(45),
            ]);
        }
    }
}
