<?php

namespace Database\Seeders;

use App\Models\Supplier;
use Illuminate\Database\Seeder;

class SupplierSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            ['nama' => 'UD Maju Jaya',      'telepon' => '081234567890', 'alamat' => 'Padang'],
            ['nama' => 'CV Sumber Rezeki', 'telepon' => '081298765432', 'alamat' => 'Bukittinggi'],
        ];

        foreach ($data as $s) {
            Supplier::create($s);
        }
    }
}