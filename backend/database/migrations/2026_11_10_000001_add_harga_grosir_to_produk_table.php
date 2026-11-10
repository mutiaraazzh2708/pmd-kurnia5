<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->decimal('harga_grosir', 12, 2)->nullable()->after('harga_jual');
        });

        // Set nilai awal harga_grosir = 90% harga_jual (diskon grosir)
        DB::table('produk')->update([
            'harga_grosir' => DB::raw('ROUND(harga_jual * 0.9, 0)')
        ]);
    }

    public function down(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->dropColumn('harga_grosir');
        });
    }
};
