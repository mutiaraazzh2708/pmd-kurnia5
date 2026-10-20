<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Produk extends Model
{
    use SoftDeletes;

    protected $table = 'produk';
    protected $fillable = ['nama', 'satuan_id', 'harga_beli', 'harga_jual', 'stok'];

    public function satuan()
    {
        return $this->belongsTo(Satuan::class);
    }
}