<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mutasi;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MutasiController extends Controller
{
    // gudang = kolom stok_gudang, toko = kolom stok (stok lama)
    private const KOLOM = ['gudang' => 'stok_gudang', 'toko' => 'stok'];

    public function index()
    {
        $hasil = Mutasi::with('produk:id,nama')->latest()->get()->map(fn ($m) => [
            'id'         => $m->id,
            'produk_id'  => $m->produk_id,
            'produk'     => ['nama' => $m->produk?->nama],
            'jumlah'     => $m->jumlah,
            'asal'       => $m->dari,
            'tujuan'     => $m->ke,
            'tanggal'    => $m->created_at?->toDateString(),
            'keterangan' => '',
        ]);

        return response()->json($hasil);
    }

    public function store(Request $request)
    {
        // terima nama dari mobile (asal/tujuan) maupun nama tabel (dari/ke)
        $request->merge([
            'dari' => strtolower((string) $request->input('dari', $request->input('asal'))),
            'ke'   => strtolower((string) $request->input('ke', $request->input('tujuan'))),
        ]);

        $data = $request->validate([
            'produk_id' => 'required|exists:produk,id',
            'jumlah'    => 'required|integer|min:1',
            'dari'      => 'required|in:gudang,toko',
            'ke'        => 'required|in:gudang,toko|different:dari',
        ]);

        $hasil = DB::transaction(function () use ($data, $request) {
            $produk = Produk::lockForUpdate()->findOrFail($data['produk_id']);
            $asal   = self::KOLOM[$data['dari']];
            $tujuan = self::KOLOM[$data['ke']];

            if ($produk->$asal < $data['jumlah']) {
                return null;
            }

            $produk->decrement($asal, $data['jumlah']);
            $produk->increment($tujuan, $data['jumlah']);

            return Mutasi::create([
                'produk_id' => $produk->id,
                'user_id'   => $request->user()->id,
                'jumlah'    => $data['jumlah'],
                'dari'      => $data['dari'],
                'ke'        => $data['ke'],
            ]);
        });

        if ($hasil === null) {
            return response()->json(['message' => 'Jumlah melebihi stok asal'], 422);
        }

        return response()->json($hasil, 201);
    }
}
