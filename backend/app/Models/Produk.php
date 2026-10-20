<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $table = 'produk';
    protected $fillable = ['nama', 'satuan_dasar', 'stok_minimum', 'aktif'];

    public function satuan()
    {
        return $this->hasMany(ProdukSatuan::class, 'produk_id');
    }

    public function stok()
    {
        return $this->hasMany(Stok::class, 'produk_id');
    }
}
