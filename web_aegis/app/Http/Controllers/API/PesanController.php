<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Informasi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;

class PesanController extends Controller
{
    /**
     * List pesan untuk aplikasi mobile.
     * GET /api/pesan?filter=semua|belum_dibaca|favorit
     */
    public function index(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'filter' => 'nullable|in:semua,belum_dibaca,favorit',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()->id;
        $filter = $request->query('filter', 'semua');
        $lastRead = Cache::get($this->lastReadKey($userId));
        $favoriteIds = $this->favoriteIds($userId);

        $pesan = Informasi::with('user:id,nama,role')
            ->latest('waktu_kirim')
            ->get()
            ->map(fn (Informasi $item) => $this->formatPesan($item, $userId, $lastRead, $favoriteIds));

        if ($filter === 'belum_dibaca') {
            $pesan = $pesan->where('isUnread', true)->values();
        }

        if ($filter === 'favorit') {
            $pesan = $pesan->where('isStarred', true)->values();
        }

        return response()->json([
            'success' => true,
            'data' => $pesan->values(),
        ]);
    }

    private function formatPesan(Informasi $informasi, int $userId, $lastRead, array $favoriteIds): array
    {
        $role = strtolower((string) ($informasi->user->role ?? ''));
        $waktuKirim = $informasi->waktu_kirim;

        return [
            'id' => $informasi->id,
            'sender' => $this->namaPengirim($informasi),
            'time' => $waktuKirim?->locale('id')->translatedFormat('d F Y | H.i'),
            'content' => $informasi->pesan,
            'isStarred' => in_array((int) $informasi->id, $favoriteIds, true),
            'isUnread' => $this->isUnread($informasi, $userId, $lastRead),
            'hasLeftIndicator' => $role === 'supervisor',
        ];
    }

    private function namaPengirim(Informasi $informasi): string
    {
        $role = strtolower((string) ($informasi->user->role ?? ''));

        return match ($role) {
            'admin' => 'Admin',
            'supervisor' => 'Supervisor',
            'aegis', 'system' => 'AEGIS',
            default => $informasi->user->nama ?? 'Unknown',
        };
    }

    private function isUnread(Informasi $informasi, int $userId, $lastRead): bool
    {
        if ($informasi->id_user === $userId) {
            return false;
        }

        if (! $lastRead) {
            return true;
        }

        return $informasi->waktu_kirim?->greaterThan($lastRead) ?? false;
    }

    private function favoriteIds(int $userId): array
    {
        return array_map('intval', Cache::get($this->favoriteKey($userId), []));
    }

    private function lastReadKey(int $userId): string
    {
        return "pesan_last_read_{$userId}";
    }

    private function favoriteKey(int $userId): string
    {
        return "pesan_favorites_{$userId}";
    }
}
