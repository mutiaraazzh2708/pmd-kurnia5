<?php

namespace Database\Seeders;

use App\Models\Produk;
use App\Models\Satuan;
use Illuminate\Database\Seeder;

class ProdukSeeder extends Seeder
{
    public function run(): void
    {
        $kg = Satuan::where('nama', 'Kg')->first()?->id ?? 1;
        $pcs = Satuan::where('nama', 'Pcs')->first()?->id ?? 1;
        $dus = Satuan::where('nama', 'Dus')->first()?->id ?? 1;

        $daftar = [
            ['nama' => 'Gula Pasir 1 kg',          'satuan_id' => $kg,  'harga_beli' => 12500, 'harga_jual' => 15000, 'harga_grosir' => 13500, 'stok' => 50],
            ['nama' => 'Minyak Goreng 1L',          'satuan_id' => $pcs, 'harga_beli' => 15000, 'harga_jual' => 18000, 'harga_grosir' => 16500, 'stok' => 30],
            ['nama' => 'Beras 5 kg',                'satuan_id' => $kg,  'harga_beli' => 55000, 'harga_jual' => 65000, 'harga_grosir' => 59000, 'stok' => 100],
            ['nama' => 'Tepung Terigu 1 kg',        'satuan_id' => $kg,  'harga_beli' => 9500,  'harga_jual' => 12000, 'harga_grosir' => 10500, 'stok' => 45],
            ['nama' => 'Telur Ayam 1 kg',           'satuan_id' => $kg,  'harga_beli' => 24000, 'harga_jual' => 28000, 'harga_grosir' => 25500, 'stok' => 8],
            ['nama' => 'Kopi Bubuk 250g',           'satuan_id' => $pcs, 'harga_beli' => 10000, 'harga_jual' => 13500, 'harga_grosir' => 12000, 'stok' => 5],
            ['nama' => 'Teh Celup Kotak',           'satuan_id' => $pcs, 'harga_beli' => 6000,  'harga_jual' => 8500,  'harga_grosir' => 7500,  'stok' => 40],
            ['nama' => 'Mie Instan Goreng (Dus)',   'satuan_id' => $dus, 'harga_beli' => 105000,'harga_jual' => 120000,'harga_grosir' => 110000,'stok' => 15],
            ['nama' => 'Susu Kental Manis Kaleng',  'satuan_id' => $pcs, 'harga_beli' => 11000, 'harga_jual' => 14000, 'harga_grosir' => 12500, 'stok' => 7],
            ['nama' => 'Garam Dapur 250g',          'satuan_id' => $pcs, 'harga_beli' => 2000,  'harga_jual' => 3500,  'harga_grosir' => 3000,  'stok' => 60],
        ];

        foreach ($daftar as $p) {
            Produk::firstOrCreate(['nama' => $p['nama']], $p);
        }
    }
}
