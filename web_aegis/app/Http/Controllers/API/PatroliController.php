<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\JadwalAbsensi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PatroliController extends Controller
{
    /**
     * GET /api/petugas/patroli/{idJadwalAbsensi}
     */
    public function getSesi(Request $request, int $idJadwalAbsensi)
    {
        $user = Auth::user();

        $jadwal = JadwalAbsensi::with([
            // rute → rute_checkpoint (urutan) → checkpoint (lat/lng/nama)
            'rute.ruteCheckpoints.checkpoint',
            // laporan yang sudah dibuat petugas ini
            'laporanCheckpoint',
            // shift via jadwal → jadwal.shift
            'jadwal.shift',
        ])
            ->where('id', $idJadwalAbsensi)
            ->where('id_user', $user->id)
            ->first();

        if (!$jadwal) {
            return response()->json([
                'status'  => false,
                'message' => 'Data jadwal tidak ditemukan.',
            ], 404);
        }

        if (!$jadwal->rute) {
            return response()->json([
                'status'  => false,
                'message' => 'Tidak ada rute patroli untuk sesi ini.',
            ], 404);
        }

        $rute  = $jadwal->rute;
        $shift = $jadwal->jadwal?->shift;   // JadwalAbsensi → Jadwal → Shift

        // Buat string jam shift, e.g. "08.00 - 16.00"
        $jamShift = '';
        if ($shift) {
            // jam_mulai & jam_selesai di-cast ke Carbon oleh Laravel,
            // gunakan ->format() bukan substr() agar tidak dapat representasi tahun
            $jamMasuk  = $shift->jam_mulai  ? $shift->jam_mulai->format('H.i')  : '';
            $jamPulang = $shift->jam_selesai ? $shift->jam_selesai->format('H.i') : '';
            $jamShift  = "{$jamMasuk} - {$jamPulang}";
        }

        $checkpoints = $rute->ruteCheckpoints
            ->sortBy('urutan')
            ->map(function ($rc) use ($jadwal) {
                $cp = $rc->checkpoint;

                $laporan = $jadwal->laporanCheckpoint
                    ->firstWhere('id_rute_checkpoint', $rc->id);

                return [
                    'id'              => $rc->id,
                    'id_checkpoint'   => $rc->id_checkpoint,
                    'urutan'          => $rc->urutan,
                    'nama_checkpoint' => $cp->nama      ?? '-',
                    'latitude'        => $cp->latitude  ?? null,
                    'longitude'       => $cp->longitude ?? null,
                    'deskripsi'       => $cp->deskripsi ?? null,
                    'laporan'         => $laporan ? [
                        'id'      => $laporan->id,
                        'kondisi' => $laporan->kondisi,
                        'status'  => $laporan->status,
                    ] : null,
                ];
            })
            ->values();

        $polyline = $checkpoints
            ->map(fn($cp) => [
                'latitude'  => $cp['latitude'],
                'longitude' => $cp['longitude'],
            ])
            ->filter(fn($p) => $p['latitude'] && $p['longitude'])
            ->values();

        return response()->json([
            'status' => true,
            'data'   => [
                'id_jadwal_absensi' => $jadwal->id,
                'nama_rute'         => $rute->nama_rute,
                'deskripsi_rute'    => $rute->deskripsi ?? '',
                // ── Shift ──────────────────────────────────────
                'nama_shift'        => $shift?->nama_shift ?? '',
                'jam_shift'         => $jamShift,
                // ───────────────────────────────────────────────
                'checkpoints'       => $checkpoints,
                'polyline'          => $polyline,
            ],
        ]);
    }

    /**
     * POST /api/petugas/patroli/{idJadwalAbsensi}/lokasi
     */
    public function updateLokasi(Request $request, int $idJadwalAbsensi)
    {
        $request->validate([
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user   = Auth::user();
        $jadwal = JadwalAbsensi::where('id', $idJadwalAbsensi)
            ->where('id_user', $user->id)
            ->first();

        if (!$jadwal) {
            return response()->json([
                'status'  => false,
                'message' => 'Data jadwal tidak ditemukan.',
            ], 404);
        }

        $jadwal->update([
            'latitude'  => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        return response()->json([
            'status'  => true,
            'message' => 'Lokasi diperbarui.',
        ]);
    }
}