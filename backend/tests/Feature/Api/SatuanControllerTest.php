<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SatuanControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_pemilik_can_create_satuan(): void
    {
        $pemilik = User::factory()->create([
            'username' => 'pemilik-test',
            'role' => 'pemilik',
        ]);

        $response = $this->actingAs($pemilik)
            ->postJson('/api/satuan', ['nama' => 'pcs']);

        $response->assertCreated()
            ->assertJsonPath('nama', 'pcs');

        $this->assertDatabaseHas('satuan', ['nama' => 'pcs']);
    }

    public function test_non_pemilik_cannot_create_satuan(): void
    {
        $kasir = User::factory()->create([
            'username' => 'kasir-test',
            'role' => 'kasir',
        ]);

        $response = $this->actingAs($kasir)
            ->postJson('/api/satuan', ['nama' => 'pcs']);

        $response->assertForbidden();
        $this->assertDatabaseMissing('satuan', ['nama' => 'pcs']);
    }

    public function test_satuan_creation_requires_a_name(): void
    {
        $pemilik = User::factory()->create([
            'username' => 'pemilik-test',
            'role' => 'pemilik',
        ]);

        $response = $this->actingAs($pemilik)
            ->postJson('/api/satuan', []);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors('nama');

        $this->assertDatabaseCount('satuan', 0);
    }
}
