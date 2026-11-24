<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;

class StokController extends Controller
{
    public function index(Request $request)
    {
        $request->validate(['lokasi' => 'nullable|in:gudang,toko']);

        $query = Produk::with('satuan:id,nama')->orderBy('nama');

        if ($request->filled('cari')) {
            $query->where('nama', 'like', '%' . $request->cari . '%');
        }

        $hasil = $query->get()->map(fn ($p) => [
            'produk_id'   => $p->id,
            'nama'        => $p->nama,
            'satuan'      => $p->satuan?->nama,
            'stok_toko'   => $p->stok,
            'stok_gudang' => $p->stok_gudang,
        ]);

        if ($request->lokasi === 'gudang') {
            $hasil = $hasil->map(fn ($r) => collect($r)->except('stok_toko')->all());
        } elseif ($request->lokasi === 'toko') {
            $hasil = $hasil->map(fn ($r) => collect($r)->except('stok_gudang')->all());
        }

        return response()->json($hasil->values());
    }
}
