<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RiwayatHarga;
use Illuminate\Http\Request;

class RiwayatHargaController extends Controller
{
    public function index(Request $request)
    {
        $query = RiwayatHarga::with(['produk:id,nama', 'user:id,name'])->latest();

        if ($request->filled('produk_id')) {
            $query->where('produk_id', $request->produk_id);
        }

        return response()->json($query->get());
    }
}