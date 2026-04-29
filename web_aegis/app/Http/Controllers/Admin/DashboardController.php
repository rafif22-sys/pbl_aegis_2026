<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Checkpoint;
use App\Models\Informasi;
use App\Models\PosJaga;
use App\Models\Rute;
use App\Models\Tamu;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Dashboard', [
            'stats' => [
                'petugas'    => User::where('role', 'petugas')->count(),
                'warga'      => User::where('role', 'warga')->count(),
                'supervisor' => User::where('role', 'supervisor')->count(),
                'rute'       => Rute::count(),
                'checkpoint' => Checkpoint::count(),
                'pos_jaga'   => PosJaga::count(),
            ],

            'buku_tamu' => Tamu::latest('waktu_masuk')
                ->limit(10)
                ->get(['id', 'nama', 'alamat', 'keperluan', 'waktu_masuk']),

            'rute_patroli' => Rute::with([
                'checkpoint' => fn ($q) => $q->orderBy('rute_checkpoint.urutan'),
            ])
            ->latest()
            ->get()
            ->map(fn ($rute) => [
                'id'        => $rute->id,
                'nama'      => $rute->nama_rute,
                'deskripsi' => $rute->checkpoint->pluck('nama')->join(' > '),
            ]),

            // Ambil 50 pesan terbaru beserta nama pengirim
            'informasi' => Informasi::with('user')
                ->latest('waktu_kirim')
                ->limit(50)
                ->get()
                ->reverse()
                ->values()
                ->map(fn ($info) => [
                    'id'        => $info->id,
                    'id_pengirim' => $info->id_user,
                    'pengirim'  => $info->user->nama ?? 'Unknown',
                    'role'      => $info->user->role ?? '',
                    'pesan'     => $info->pesan,
                    'waktu' => $info->waktu_kirim->translatedFormat('d F Y | H:i'),
                ]),
        ]);
    }

    public function kirimPesan(Request $request)
    {
        $request->validate([
            'pesan' => ['required', 'string', 'max:1000'],
        ]);

        Informasi::create([
            'id_user'    => auth()->id(),
            'pesan'      => $request->pesan,
            'waktu_kirim' => now(),
        ]);

        return back();
    }
}