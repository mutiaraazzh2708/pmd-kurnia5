<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProdukController extends Controller
{
    public function store(Request $request) { return response()->json([], 201); }
    public function update(Request $request, $id) { return response()->json([]); }
    public function index()
    {
        $produk = Produk::with('satuan')->orderBy('nama')->get();

        return response()->json($produk);
    }

    public function destroy($id)
    {
        $produk = Produk::findOrFail($id);
        $produk->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}
