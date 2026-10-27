<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaksi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

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

    public function store(Request $request)
    {
        $data = $request->validate([
            'tipe_pembeli' => 'required|in:umum,reseller',
            'metode_bayar' => 'required|in:tunai,transfer,qris',
            'items' => 'required|array|min:1',
            'items.*.produk_id' => 'required|integer|distinct|exists:produk,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ], [
            'tipe_pembeli.required' => 'Tipe pembeli wajib dipilih',
            'metode_bayar.required' => 'Metode bayar wajib dipilih',
            'items.required' => 'Keranjang tidak boleh kosong',
            'items.min' => 'Keranjang tidak boleh kosong',
            'items.*.jumlah.min' => 'Jumlah harus lebih dari 0',
            'items.*.produk_id.distinct' => 'Produk tidak boleh dobel di keranjang',
        ]);

        $id = DB::transaction(function () use ($data, $request) {
            $total = 0;
            $baris = [];

            foreach ($data['items'] as $i => $item) {
                $produk = DB::table('produk')
                    ->where('id', $item['produk_id'])
                    ->whereNull('deleted_at')
                    ->lockForUpdate()
                    ->first();

                if (!$produk) {
                    throw ValidationException::withMessages(["items.$i.produk_id" => 'Produk tidak tersedia']);
                }
                if ($produk->stok < $item['jumlah']) {
                    throw ValidationException::withMessages(["items.$i.jumlah" => 'Stok tidak cukup (tersisa ' . $produk->stok . ')']);
                }

                DB::table('produk')->where('id', $produk->id)->decrement('stok', $item['jumlah']);

                $subtotal = $produk->harga_jual * $item['jumlah'];
                $total += $subtotal;
                $baris[] = [
                    'produk_id' => $produk->id,
                    'jumlah' => $item['jumlah'],
                    'harga' => $produk->harga_jual,
                    'subtotal' => $subtotal,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            $transaksiId = DB::table('transaksi')->insertGetId([
                'user_id' => $request->user()->id,
                'tipe_pembeli' => $data['tipe_pembeli'],
                'metode_bayar' => $data['metode_bayar'],
                'total' => $total,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            foreach ($baris as $b) {
                DB::table('detail_transaksi')->insert($b + ['transaksi_id' => $transaksiId]);
            }

            return $transaksiId;
        });

        return response()->json([
            'message' => 'Transaksi berhasil disimpan',
            'transaksi' => DB::table('transaksi')->find($id),
            'detail' => DB::table('detail_transaksi')->where('transaksi_id', $id)->get(),
        ], 201);
    }
}
