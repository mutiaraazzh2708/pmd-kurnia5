<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use App\Models\Satuan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProdukController extends Controller
{
    public function index(Request $request)
    {
        $query = Produk::with('satuan')->orderBy('nama');

        if ($request->filled('cari')) {
            $query->where('nama', 'like', '%' . $request->cari . '%');
        }

        return response()->json($query->get());
    }

    public function store(Request $request)
    {
        // Support baik format satuan_dasar (teks dari mobile) maupun satuan_id
        if ($request->filled('satuan_dasar') && !$request->filled('satuan_id')) {
            $satuan = \App\Models\Satuan::firstOrCreate(['nama' => $request->satuan_dasar]);
            $request->merge(['satuan_id' => $satuan->id]);
        }
        if ($request->filled('stok_awal') && !$request->filled('stok')) {
            $request->merge(['stok' => $request->stok_awal]);
        }

        $data = $request->validate([
            'nama'         => 'required|string|max:255',
            'satuan_id'    => 'required|integer|exists:satuan,id',
            'harga_beli'   => 'required|numeric|min:0',
            'harga_jual'   => 'required|numeric|min:0',
            'harga_grosir' => 'nullable|numeric|min:0',
            'stok'         => 'required|integer|min:0',
        ]);

        $produk = Produk::create($data);

        return response()->json($produk->load('satuan'), 201);
    }

    public function update(Request $request, $id)
    {
        // Support baik format satuan_dasar maupun satuan_id
        if ($request->filled('satuan_dasar') && !$request->filled('satuan_id')) {
            $satuan = \App\Models\Satuan::firstOrCreate(['nama' => $request->satuan_dasar]);
            $request->merge(['satuan_id' => $satuan->id]);
        }
        if ($request->filled('stok_awal') && !$request->filled('stok')) {
            $request->merge(['stok' => $request->stok_awal]);
        }

        $data = $request->validate([
            'nama'         => 'required|string|max:255',
            'satuan_id'    => 'required|integer|exists:satuan,id',
            'harga_beli'   => 'required|numeric|min:0',
            'harga_jual'   => 'required|numeric|min:0',
            'harga_grosir' => 'nullable|numeric|min:0',
            'stok'         => 'sometimes|integer|min:0',
        ]);

        $produk = Produk::findOrFail($id);
        $produk->update($data);

        return response()->json($produk->load('satuan'));
    }

    public function destroy($id)
    {
        $produk = Produk::findOrFail($id);
        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }

    public function autocomplete(Request $request)
    {
        $data = $request->validate([
            'q' => 'required|string|min:2',
        ], [
            'q.required' => 'Kata kunci wajib diisi',
            'q.min' => 'Ketik minimal 2 huruf',
        ]);

        $hasil = DB::table('produk')
            ->leftJoin('satuan', 'satuan.id', '=', 'produk.satuan_id')
            ->whereNull('produk.deleted_at')
            ->where('produk.nama', 'like', '%' . $data['q'] . '%')
            ->select(
                'produk.id',
                'produk.nama',
                DB::raw("COALESCE(satuan.nama, 'pcs') as satuan"),
                'produk.harga_jual',
                DB::raw('COALESCE(produk.harga_grosir, produk.harga_jual) as harga_grosir'),
                'produk.stok'
            )
            ->orderBy('produk.nama')
            ->limit(10)
            ->get();

        return response()->json($hasil);
    }
}
