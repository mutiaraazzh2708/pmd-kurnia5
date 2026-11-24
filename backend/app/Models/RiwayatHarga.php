<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RiwayatHarga extends Model
{
    protected $table = 'riwayat_harga';
    protected $fillable = ['produk_id', 'jenis', 'tipe_pembeli', 'harga_lama', 'harga_baru', 'user_id'];

    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}