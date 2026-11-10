<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProdukController;
use App\Http\Controllers\Api\ReturController;
use App\Http\Controllers\Api\SatuanController;
use App\Http\Controllers\Api\TransaksiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', fn (Request $r) => $r->user());

    // Produk — semua role yang login
    Route::get('/produk', [ProdukController::class, 'index']);

    // Transaksi — semua role yang login
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::get('/transaksi/{id}', [TransaksiController::class, 'show']);

    // Retur baca — semua role yang login
    Route::get('/retur', [ReturController::class, 'index']);

    // Khusus pemilik
    Route::middleware('role:pemilik')->group(function () {
        Route::post('/satuan', [SatuanController::class, 'store']);
        Route::post('/produk', [ProdukController::class, 'store']);
        Route::put('/produk/{id}', [ProdukController::class, 'update']);
        Route::delete('/produk/{id}', [ProdukController::class, 'destroy']);
    });

    // Khusus kasir & pemilik (baca autocomplete)
    Route::middleware('role:kasir,pemilik')->group(function () {
        Route::get('/produk/autocomplete', [ProdukController::class, 'autocomplete']);
    });

    // Khusus kasir saja (transaksi & retur)
    Route::middleware('role:kasir')->group(function () {
        Route::post('/transaksi', [TransaksiController::class, 'store']);
        Route::post('/retur', [ReturController::class, 'store']);
    });
});
