<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaksi;
use Illuminate\Http\Request;

class TransaksiController extends Controller
{
    public function index(Request $request)
    {
        $query = Transaksi::with('kasir:id,name,username')->latest();

        if ($request->filled('metode_bayar')) {
            $query->where('metode_bayar', $request->metode_bayar);
        }

        if ($request->filled('tanggal')) {
            $query->whereDate('created_at', $request->tanggal);
        }

        return response()->json($query->get());
    }

    public function show($id)
    {
        $transaksi = Transaksi::with(['kasir:id,name,username', 'detail.produk:id,nama'])
            ->findOrFail($id);

        return response()->json($transaksi);
    }
}