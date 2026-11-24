<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DetailBarangMasuk extends Model
{
    protected $table = 'detail_barang_masuk';
    protected $fillable = ['barang_masuk_id', 'produk_id', 'jumlah', 'harga_beli'];

    public function barangMasuk()
    {
        return $this->belongsTo(BarangMasuk::class);
    }

    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }
}