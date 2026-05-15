<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tamu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class TamuController extends Controller
{
    /**
     * List data tamu untuk petugas.
     * GET /api/tamu
     */
    public function index()
    {
        $tamu = Tamu::with('user:id,nama,foto_profil')
            ->latest('waktu_masuk')
            ->get()
            ->map(fn (Tamu $item) => $this->formatTamu($item));

        return response()->json([
            'success' => true,
            'data' => $tamu,
        ]);
    }

    /**
     * Simpan data tamu baru.
     * POST /api/tamu
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama' => 'required|string|max:255',
            'alamat' => 'required|string|max:1000',
            'keperluan' => 'required|string|max:255',
            'foto_tamu' => 'required|image|max:5120',
            'status' => 'nullable|in:masuk,keluar',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $path = $request->file('foto_tamu')->store('tamu', 'public');

        $tamu = Tamu::create([
            'id_user' => $request->user()->id,
            'nama' => $request->nama,
            'alamat' => $request->alamat,
            'keperluan' => $request->keperluan,
            'foto_tamu' => asset(Storage::url($path)),
            'waktu_masuk' => now(),
            'status' => $request->input('status', 'masuk'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data tamu berhasil disimpan.',
            'data' => $this->formatTamu($tamu->load('user:id,nama,foto_profil')),
        ], 201);
    }

    /**
     * Update status tamu, terutama saat tamu keluar.
     * PATCH /api/tamu/{id}
     */
    public function update(Request $request, $id)
    {
        $tamu = Tamu::find($id);

        if (! $tamu) {
            return response()->json([
                'success' => false,
                'message' => 'Data tamu tidak ditemukan.',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:masuk,keluar',
            'waktu_keluar' => 'nullable|date',
            'jam_keluar' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $updateData = [
            'status' => $request->status,
        ];

        if ($request->status === 'keluar') {
            $updateData['waktu_keluar'] = $request->filled('waktu_keluar')
                ? $request->date('waktu_keluar')
                : now();
        }

        $tamu->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Data tamu berhasil diperbarui.',
            'data' => $this->formatTamu($tamu->fresh()->load('user:id,nama,foto_profil')),
        ]);
    }

    private function formatTamu(Tamu $tamu): array
    {
        return [
            'id' => $tamu->id,
            'id_user' => $tamu->id_user,
            'nama' => $tamu->nama,
            'alamat' => $tamu->alamat,
            'keperluan' => $tamu->keperluan,
            'foto_tamu' => $tamu->foto_tamu,
            'waktu_masuk' => $tamu->waktu_masuk?->toIso8601String(),
            'waktu_keluar' => $tamu->waktu_keluar?->toIso8601String(),
            'status' => $tamu->status,
            'user' => $tamu->relationLoaded('user') && $tamu->user ? [
                'id' => $tamu->user->id,
                'nama' => $tamu->user->nama,
                'foto_profil' => $tamu->user->foto_profil,
            ] : null,
        ];
    }
}
