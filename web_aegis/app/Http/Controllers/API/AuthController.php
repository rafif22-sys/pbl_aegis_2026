<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Models\User;

class AuthController extends Controller
{
    // ── Login API (Flutter) ─────────────────────────────
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'       => ['required', 'email'],
            'password'    => ['required'],
            // 'device_name' => ['required', 'string'], 
        ]);

        $user = User::where('email', $request->email)->first();

        // Validasi kredensial
        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah.',
            ], 401);
        }

        // Hanya role non-admin yang boleh akses API
        $allowedRoles = ['petugas', 'warga', 'supervisor'];
        if (! in_array($user->role, $allowedRoles)) {
            return response()->json([
                'message' => 'Akun ini tidak memiliki akses ke aplikasi mobile.',
            ], 403);
        }

        // Hapus token lama device yang sama (opsional, hindari duplikasi)
        $user->tokens()->where('name', $request->device_name)->delete();

        // Buat token baru dengan ability sesuai role
        $token = $user->createToken('mobile-app', [$user->role]);

        return response()->json([
            'message' => 'Login berhasil.',
            'token'   => $token->plainTextToken,
            'user'    => $this->formatUser($user),
        ], 200);
    }

    // ── Get profil user yang sedang login ───────────────
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $this->formatUser($request->user()),
        ]);
    }

    // ── Logout API ──────────────────────────────────────
    public function logout(Request $request): JsonResponse
    {
        // Hapus hanya token yang dipakai sekarang
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil.',
        ]);
    }

    // ── Logout semua device ─────────────────────────────
    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'message' => 'Semua sesi berhasil dihapus.',
        ]);
    }

    // ── Format response user ────────────────────────────
    private function formatUser(User $user): array
    {
        $data = [
            'id'               => $user->id,
            'nama'             => $user->nama,
            'email'            => $user->email,
            'role'             => $user->role,
            'tanggal_lahir'    => $user->tanggal_lahir?->format('Y-m-d'),
            'alamat'           => $user->alamat,
            'no_hp'            => $user->no_hp,
            'foto_profil'      => $user->foto_profil
                ? asset($user->foto_profil)
                : null,
            'tanggal_bergabung'  => $user->tanggal_bergabung?->format('Y-m-d'),
            'wilayah_pengawasan' => $user->wilayah_pengawasan,
        ];

        // Tambahkan data supervisor jika role petugas
        if ($user->role === 'petugas' && $user->id_supervisor) {
            $data['supervisor'] = [
                'id'   => $user->supervisor->id,
                'nama' => $user->supervisor->nama,
            ];
        }

        return $data;
    }
}