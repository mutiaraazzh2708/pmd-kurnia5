<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $akun = [
            ['name' => 'Pemilik',  'username' => 'pemilik1',  'role' => 'pemilik'],
            ['name' => 'Kasir',    'username' => 'kasir1',    'role' => 'kasir'],
            ['name' => 'Karyawan', 'username' => 'karyawan1', 'role' => 'karyawan_toko'],
        ];

        foreach ($akun as $a) {
            User::create($a + ['password' => Hash::make('password123')]);
        }
    }
}