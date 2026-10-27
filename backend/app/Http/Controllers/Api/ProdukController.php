<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProdukController extends Controller
{
    public function index(Request $request)
    {
        $query = Produk::orderBy('nama');

        if ($request->filled('cari')) {
            $query->where('nama', 'like', '%' . $request->cari . '%');
        }

        return response()->json($query->get());
    }
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'       => 'required|string|max:255',
            'satuan_id'  => 'required|integer|exists:satuan,id',
            'harga_beli' => 'required|numeric|min:0',
            'harga_jual' => 'required|numeric|min:0',
            'stok'       => 'required|integer|min:0',
        ]);

        $produk = Produk::create($data);

        return response()->json($produk->load('satuan'), 201);
    }

    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'nama'       => 'required|string|max:255',
            'satuan_id'  => 'required|integer|exists:satuan,id',
            'harga_beli' => 'required|numeric|min:0',
            'harga_jual' => 'required|numeric|min:0',
            'stok'       => 'sometimes|integer|min:0',
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
        ->join('satuan', 'satuan.id', '=', 'produk.satuan_id')
        ->whereNull('produk.deleted_at')
        ->where('produk.nama', 'like', '%' . $data['q'] . '%')
        ->select('produk.id', 'produk.nama', 'satuan.nama as satuan', 'produk.harga_jual', 'produk.stok')
        ->orderBy('produk.nama')
        ->limit(10)
        ->get();

    return response()->json($hasil);
}
}
