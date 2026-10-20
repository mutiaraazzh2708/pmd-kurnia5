<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiAuthenticationTest extends TestCase
{
    public function test_unauthenticated_api_request_returns_json_401_without_json_accept_header(): void
    {
        $response = $this->withHeaders(['Accept' => '*/*'])
            ->post('/api/produk', [
                'nama' => 'Gula Pasir',
                'satuan_id' => 2,
                'harga_beli' => 12000,
                'harga_jual' => 15000,
                'stok' => 50,
            ]);

        $response->assertUnauthorized()
            ->assertJson(['message' => 'Unauthenticated.']);
    }
}
