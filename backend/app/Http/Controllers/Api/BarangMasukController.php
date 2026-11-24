<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BarangMasuk;
use App\Models\DetailBarangMasuk;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BarangMasukController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'supplier_id'        => 'nullable|exists:supplier,id',
            'tanggal'            => 'required|date',
            'catatan'            => 'nullable|string|max:255',
            'items'              => 'required|array|min:1',
            'items.*.produk_id'  => 'required|exists:produk,id',
            'items.*.jumlah'     => 'required|integer|min:1',
            'items.*.harga_beli' => 'required|numeric|min:0',
        ]);

        $masuk = DB::transaction(function () use ($data, $request) {
            $bm = BarangMasuk::create([
                'supplier_id' => $data['supplier_id'] ?? null,
                'user_id'     => $request->user()->id,
                'tanggal'     => $data['tanggal'],
                'catatan'     => $data['catatan'] ?? null,
            ]);

            foreach ($data['items'] as $item) {
                DetailBarangMasuk::create([
                    'barang_masuk_id' => $bm->id,
                    'produk_id'       => $item['produk_id'],
                    'jumlah'          => $item['jumlah'],
                    'harga_beli'      => $item['harga_beli'],
                ]);

                Produk::where('id', $item['produk_id'])
                    ->increment('stok_gudang', $item['jumlah']);
            }

            return $bm;
        });

        return response()->json($masuk, 201);
    }
}
