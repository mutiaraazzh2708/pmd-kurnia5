<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Satuan extends Model
{
    protected $table = 'satuan';
    protected $fillable = ['nama'];

    public function produk()
    {
        return $this->hasMany(Produk::class);
    }
}
