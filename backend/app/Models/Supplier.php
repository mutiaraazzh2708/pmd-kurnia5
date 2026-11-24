<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Supplier extends Model
{
    protected $table = 'supplier';
    protected $fillable = ['nama', 'telepon', 'alamat'];

    public function barangMasuk()
    {
        return $this->hasMany(BarangMasuk::class);
    }
}