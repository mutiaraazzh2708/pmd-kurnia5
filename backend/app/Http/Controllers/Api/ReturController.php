<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DetailTransaksi;
use App\Models\Produk;
use App\Models\Retur;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ReturController extends Controller
{
    public function index(Request $request)
    {
        $query = Retur::with(['transaksi', 'produk'])->latest();
        return response()->json($query->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'transaksi_id' => 'required|integer|exists:transaksi,id',
            'produk_id'    => 'required|integer|exists:produk,id',
            'jumlah'       => 'required|integer|min:1',
            'alasan'       => 'required|string|max:500',
        ], [
            'transaksi_id.required' => 'Transaksi wajib dipilih',
            'transaksi_id.exists'   => 'Transaksi tidak ditemukan',
            'produk_id.required'    => 'Produk wajib dipilih',
            'produk_id.exists'      => 'Produk tidak ditemukan',
            'jumlah.required'       => 'Jumlah retur wajib diisi',
            'jumlah.min'            => 'Jumlah retur minimal 1',
            'alasan.required'       => 'Alasan retur wajib diisi',
        ]);

        $retur = DB::transaction(function () use ($data) {
            // Validasi apakah produk benar dibeli pada transaksi ini
            $detail = DetailTransaksi::where('transaksi_id', $data['transaksi_id'])
                ->where('produk_id', $data['produk_id'])
                ->first();

            if (!$detail) {
                throw ValidationException::withMessages([
                    'produk_id' => 'Produk ini tidak ada dalam transaksi yang dipilih',
                ]);
            }

            // Hitung total yang sudah diretur sebelumnya untuk item ini
            $totalReturSebelumnya = Retur::where('transaksi_id', $data['transaksi_id'])
                ->where('produk_id', $data['produk_id'])
                ->sum('jumlah');

            if (($totalReturSebelumnya + $data['jumlah']) > $detail->jumlah) {
                $sisaBisaRetur = max(0, $detail->jumlah - $totalReturSebelumnya);
                throw ValidationException::withMessages([
                    'jumlah' => "Jumlah retur melebihi sisa pembelian yang bisa diretur (maksimal: {$sisaBisaRetur})",
                ]);
            }

            // Simpan data retur
            $baru = Retur::create($data);

            // Tambahkan kembali stok produk
            Produk::where('id', $data['produk_id'])->increment('stok', $data['jumlah']);

            return $baru;
        });

        return response()->json([
            'message' => 'Retur berhasil disimpan',
            'retur'   => $retur->load(['transaksi', 'produk']),
        ], 201);
    }
}
