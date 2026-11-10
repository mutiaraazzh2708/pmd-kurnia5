<?php

namespace Tests\Feature\Api;

use App\Models\DetailTransaksi;
use App\Models\Produk;
use App\Models\Retur;
use App\Models\Satuan;
use App\Models\Transaksi;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class Sprint2FungsiTest extends TestCase
{
    use RefreshDatabase;

    private User $kasir;
    private Satuan $satuan;
    private Produk $produkMinyak;
    private Produk $produkGula;

    protected function setUp(): void
    {
        parent::setUp();

        $this->kasir = User::factory()->create([
            'username' => 'kasir-sprint2',
            'role' => 'kasir',
        ]);

        $this->satuan = Satuan::create(['nama' => 'Pcs']);

        $this->produkMinyak = Produk::create([
            'nama' => 'Minyak Goreng Sania 1L',
            'satuan_id' => $this->satuan->id,
            'harga_beli' => 15000,
            'harga_jual' => 18000,
            'stok' => 20,
        ]);

        $this->produkGula = Produk::create([
            'nama' => 'Gula Pasir Gulaku 1kg',
            'satuan_id' => $this->satuan->id,
            'harga_beli' => 13000,
            'harga_jual' => 16000,
            'stok' => 15,
        ]);
    }

    /** 1. Autocomplete Produk */
    public function test_autocomplete_produk_returns_matching_results(): void
    {
        $response = $this->actingAs($this->kasir)
            ->getJson('/api/produk/autocomplete?q=minyak');

        $response->assertOk()
            ->assertJsonStructure([
                '*' => ['id', 'nama', 'harga_jual', 'stok', 'satuan']
            ]);

        $this->assertEquals('Minyak Goreng Sania 1L', $response->json('0.nama'));
    }

    /** 2. Simpan Transaksi Berhasil & Pengurangan Stok */
    public function test_kasir_can_store_transaction_and_stock_is_reduced(): void
    {
        $payload = [
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'items' => [
                [
                    'produk_id' => $this->produkMinyak->id,
                    'jumlah' => 2,
                ],
                [
                    'produk_id' => $this->produkGula->id,
                    'jumlah' => 1,
                ]
            ],
        ];

        $response = $this->actingAs($this->kasir)
            ->postJson('/api/transaksi', $payload);

        $response->assertCreated()
            ->assertJsonPath('message', 'Transaksi berhasil disimpan');

        // Total: (2 * 18000) + (1 * 16000) = 36000 + 16000 = 52000
        $this->assertDatabaseHas('transaksi', [
            'user_id' => $this->kasir->id,
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'total' => 52000,
        ]);

        // Detail transaksi tersimpan
        $this->assertDatabaseHas('detail_transaksi', [
            'produk_id' => $this->produkMinyak->id,
            'jumlah' => 2,
            'subtotal' => 36000,
        ]);

        // Cek stok berkurang
        $this->assertEquals(18, $this->produkMinyak->fresh()->stok);
        $this->assertEquals(14, $this->produkGula->fresh()->stok);
    }

    /** 3. Validasi Transaksi: Stok Kurang atau Keranjang Kosong */
    public function test_transaksi_validation_fails_on_empty_items_or_insufficient_stock(): void
    {
        // Keranjang kosong
        $respEmpty = $this->actingAs($this->kasir)->postJson('/api/transaksi', [
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'items' => [],
        ]);
        $respEmpty->assertUnprocessable()->assertJsonValidationErrors('items');

        // Stok tidak cukup (minta 999 padahal stok 20)
        $respOver = $this->actingAs($this->kasir)->postJson('/api/transaksi', [
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'items' => [
                ['produk_id' => $this->produkMinyak->id, 'jumlah' => 999]
            ],
        ]);
        $respOver->assertUnprocessable();
    }

    /** 4. Riwayat Transaksi & Detail Transaksi */
    public function test_can_view_transaction_history_and_detail(): void
    {
        $trx = Transaksi::create([
            'user_id' => $this->kasir->id,
            'tipe_pembeli' => 'reseller',
            'metode_bayar' => 'transfer',
            'total' => 36000,
        ]);
        DetailTransaksi::create([
            'transaksi_id' => $trx->id,
            'produk_id' => $this->produkMinyak->id,
            'jumlah' => 2,
            'harga' => 18000,
            'subtotal' => 36000,
        ]);

        // Index riwayat
        $resIndex = $this->actingAs($this->kasir)->getJson('/api/transaksi');
        $resIndex->assertOk()->assertJsonCount(1);

        // Detail transaksi
        $resShow = $this->actingAs($this->kasir)->getJson("/api/transaksi/{$trx->id}");
        $resShow->assertOk()
            ->assertJsonPath('total', 36000)
            ->assertJsonPath('detail.0.produk_id', $this->produkMinyak->id);
    }

    /** 5. Retur Transaksi Berhasil & Stok Kembali */
    public function test_can_store_retur_and_product_stock_is_incremented(): void
    {
        $trx = Transaksi::create([
            'user_id' => $this->kasir->id,
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'total' => 36000,
        ]);
        DetailTransaksi::create([
            'transaksi_id' => $trx->id,
            'produk_id' => $this->produkMinyak->id,
            'jumlah' => 2,
            'harga' => 18000,
            'subtotal' => 36000,
        ]);

        $stokAwal = $this->produkMinyak->fresh()->stok; // 20

        $resRetur = $this->actingAs($this->kasir)->postJson('/api/retur', [
            'transaksi_id' => $trx->id,
            'produk_id'    => $this->produkMinyak->id,
            'jumlah'       => 1,
            'alasan'       => 'Kemasan bocor / rusak',
        ]);

        $resRetur->assertCreated()
            ->assertJsonPath('message', 'Retur berhasil disimpan');

        $this->assertDatabaseHas('retur', [
            'transaksi_id' => $trx->id,
            'produk_id'    => $this->produkMinyak->id,
            'jumlah'       => 1,
        ]);

        // Stok bertambah kembali 1
        $this->assertEquals($stokAwal + 1, $this->produkMinyak->fresh()->stok);
    }

    /** 6. Validasi Retur: Melebihi Jumlah Pembelian atau Produk Salah */
    public function test_retur_fails_if_quantity_exceeds_purchase_or_product_not_in_transaction(): void
    {
        $trx = Transaksi::create([
            'user_id' => $this->kasir->id,
            'tipe_pembeli' => 'umum',
            'metode_bayar' => 'tunai',
            'total' => 18000,
        ]);
        DetailTransaksi::create([
            'transaksi_id' => $trx->id,
            'produk_id' => $this->produkMinyak->id,
            'jumlah' => 1,
            'harga' => 18000,
            'subtotal' => 18000,
        ]);

        // Retur produk yang tidak ada di transaksi tersebut (Gula)
        $resWrongProd = $this->actingAs($this->kasir)->postJson('/api/retur', [
            'transaksi_id' => $trx->id,
            'produk_id'    => $this->produkGula->id,
            'jumlah'       => 1,
            'alasan'       => 'Salah beli',
        ]);
        $resWrongProd->assertUnprocessable()
            ->assertJsonValidationErrors('produk_id');

        // Retur melebihi yang dibeli (dibeli 1, retur 2)
        $resExceed = $this->actingAs($this->kasir)->postJson('/api/retur', [
            'transaksi_id' => $trx->id,
            'produk_id'    => $this->produkMinyak->id,
            'jumlah'       => 2,
            'alasan'       => 'Rusak',
        ]);
        $resExceed->assertUnprocessable()
            ->assertJsonValidationErrors('jumlah');
    }
}
