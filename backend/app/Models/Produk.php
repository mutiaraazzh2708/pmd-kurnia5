<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Produk extends Model
{
    use SoftDeletes;

    protected $table = 'produk';

    protected $fillable = [
        'nama',
        'satuan_id',
        'harga_beli',
        'harga_jual',
        'harga_grosir',
        'stok',
    ];

    public function satuan()
    {
        return $this->belongsTo(Satuan::class, 'satuan_id');
    }

    protected static function booted()
    {
        static::updating(function ($produk) {
            $jenis = [
                'harga_beli'   => 'beli',
                'harga_jual'   => 'jual',
                'harga_grosir' => 'grosir',
            ];

            foreach ($jenis as $kolom => $nama) {
                if ($produk->isDirty($kolom)) {
                    \App\Models\RiwayatHarga::create([
                        'produk_id'  => $produk->id,
                        'jenis'      => $nama,
                        'harga_lama' => $produk->getOriginal($kolom) ?? 0,
                        'harga_baru' => $produk->$kolom ?? 0,
                        'user_id'    => \Illuminate\Support\Facades\Auth::id(),
                    ]);
                }
            }
        });
    }
}