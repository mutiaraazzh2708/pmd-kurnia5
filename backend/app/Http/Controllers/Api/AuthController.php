<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function login(Request $request) { return response()->json(['message' => 'belum diisi'], 501); }
    public function logout(Request $request) { return response()->json(['message' => 'belum diisi'], 501); }
}
