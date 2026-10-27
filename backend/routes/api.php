<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProdukController;
use App\Http\Controllers\Api\SatuanController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TransaksiController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', fn (Request $r) => $r->user());
    Route::get('/produk', [ProdukController::class, 'index']);
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::get('/transaksi/{id}', [TransaksiController::class, 'show']);

    Route::middleware('role:pemilik')->group(function () {
        Route::post('/satuan', [SatuanController::class, 'store']);
        Route::post('/produk', [ProdukController::class, 'store']);
        Route::put('/produk/{id}', [ProdukController::class, 'update']);
        Route::delete('/produk/{id}', [ProdukController::class, 'destroy']);
    });

    Route::middleware('role:kasir,pemilik')->group(function () {
        Route::get('/produk/autocomplete', [ProdukController::class, 'autocomplete']);
        Route::post('/transaksi', [TransaksiController::class, 'store']);
    });
});
