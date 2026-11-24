<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Supplier;
use Illuminate\Http\Request;

class SupplierController extends Controller
{
    public function index(Request $request)
    {
        $query = Supplier::orderBy('nama');

        if ($request->filled('cari')) {
            $query->where('nama', 'like', '%' . $request->cari . '%');
        }

        return response()->json($query->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'    => 'required|string|max:100',
            'telepon' => 'nullable|string|max:20',
            'alamat'  => 'nullable|string|max:255',
        ]);

        return response()->json(Supplier::create($data), 201);
    }

    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'nama'    => 'required|string|max:100',
            'telepon' => 'nullable|string|max:20',
            'alamat'  => 'nullable|string|max:255',
        ]);

        $supplier = Supplier::findOrFail($id);
        $supplier->update($data);

        return response()->json($supplier);
    }
}