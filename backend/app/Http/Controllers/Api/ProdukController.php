<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\HargaSatuan;
use App\Models\Produk;
use App\Models\ProdukSatuan;
use App\Models\Stok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProdukController extends Controller
{
    // ===== Bagian Rafa (#10): jangan diubah =====
    public function index()
    {
        $produk = Produk::where('aktif', true)->get();

        return response()->json($produk);
    }

    // ===== Bagian Mutiara (#6 dan #20): tambah produk + validasi =====
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'         => 'required|string|max:100',
            'satuan_dasar' => 'required|string|max:100',
            'harga_beli'   => 'required|numeric|min:0',
            'harga_jual'   => 'required|numeric|min:0',
            'stok_awal'    => 'required|integer|min:0',
        ]);

        $produk = DB::transaction(function () use ($data) {
            $p = Produk::create([
                'nama'         => $data['nama'],
                'satuan_dasar' => $data['satuan_dasar'],
                'aktif'        => true,
            ]);

            $ps = ProdukSatuan::create([
                'produk_id'   => $p->id,
                'nama_satuan' => 'eceran',
                'isi'         => 1,
                'harga_beli'  => $data['harga_beli'],
            ]);

            HargaSatuan::create([
                'produk_satuan_id' => $ps->id,
                'tipe_pembeli'     => 'umum',
                'harga_jual'       => $data['harga_jual'],
            ]);

            Stok::create([
                'produk_id' => $p->id,
                'lokasi'    => 'gudang',
                'jumlah'    => $data['stok_awal'],
            ]);

            return $p;
        });

        return response()->json($produk, 201);
    }

    // ===== Bagian Mutiara (#12 dan #20): edit produk + validasi =====
    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'nama'         => 'required|string|max:100',
            'satuan_dasar' => 'required|string|max:100',
            'harga_beli'   => 'required|numeric|min:0',
            'harga_jual'   => 'required|numeric|min:0',
        ]);

        $produk = Produk::where('aktif', true)->findOrFail($id);

        DB::transaction(function () use ($produk, $data) {
            $produk->update([
                'nama'         => $data['nama'],
                'satuan_dasar' => $data['satuan_dasar'],
            ]);

            $ps = ProdukSatuan::where('produk_id', $produk->id)
                ->where('nama_satuan', 'eceran')
                ->firstOrFail();

            $ps->update(['harga_beli' => $data['harga_beli']]);

            HargaSatuan::where('produk_satuan_id', $ps->id)
                ->where('tipe_pembeli', 'umum')
                ->update(['harga_jual' => $data['harga_jual']]);
        });

        return response()->json($produk->fresh());
    }

    // ===== Bagian Rafa (#14): jangan diubah =====
    public function destroy($id)
    {
        $produk = Produk::findOrFail($id);
        $produk->update(['aktif' => false]);

        return response()->json(['message' => 'Produk dihapus']);
    }
}
