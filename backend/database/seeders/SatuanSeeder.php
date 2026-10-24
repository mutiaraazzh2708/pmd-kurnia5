<?php

namespace Database\Seeders;

use App\Models\Satuan;
use Illuminate\Database\Seeder;

class SatuanSeeder extends Seeder
{
    public function run(): void
    {
        $satuanList = [
            ['nama' => 'Pcs'],
            ['nama' => 'Dus'],
            ['nama' => 'Renceng'],
            ['nama' => 'Kg'],
            ['nama' => 'Pack'],
        ];

        foreach ($satuanList as $satuan) {
            Satuan::firstOrCreate($satuan);
        }
    }
}
