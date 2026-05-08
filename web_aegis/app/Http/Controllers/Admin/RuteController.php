<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Rute;
use App\Models\Checkpoint;
use Illuminate\Http\Request;
use Inertia\Inertia;

class RuteController extends Controller
{
    // ── INDEX ────────────────────────────────────────────
    public function index(Request $request)
    {
        $query = Rute::with([
            'checkpoint' => fn($q) => $q
                ->select('checkpoint.id', 'nama', 'latitude', 'longitude')
                ->orderBy('rute_checkpoint.urutan'),
        ]);

        if ($request->filled('search')) {
            $query->where('nama_rute', 'like', '%' . $request->search . '%');
        }

        // Ambil semua (tanpa paginasi) agar polyline di peta tetap lengkap.
        // Jika data sangat banyak, ganti paginate(15) dan sesuaikan frontend.
        $rutes = $query->orderBy('nama_rute')->get();

        // Semua checkpoint (untuk dropdown pilih di modal tambah/edit)
        $allCheckpoints = Checkpoint::select('id', 'nama', 'latitude', 'longitude')
            ->orderBy('nama')
            ->get();

        return Inertia::render('Admin/Rute', [
            'rutes'          => $rutes,
            'allCheckpoints' => $allCheckpoints,
            'filters'        => $request->only(['search']),
        ]);
    }

    // ── STORE ────────────────────────────────────────────
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_rute'      => 'required|string|max:255|unique:rute,nama_rute',
            'checkpoints'    => 'required|array|min:1',
            'checkpoints.*'  => 'exists:checkpoint,id',
        ], [
            'nama_rute.required'   => 'Nama rute wajib diisi.',
            'nama_rute.unique'     => 'Nama rute sudah digunakan.',
            'checkpoints.required' => 'Pilih minimal satu checkpoint.',
            'checkpoints.min'      => 'Pilih minimal satu checkpoint.',
            'checkpoints.*.exists' => 'Checkpoint tidak valid.',
        ]);

        $rute = Rute::create(['nama_rute' => $validated['nama_rute']]);

        // Sync pivot rute_checkpoint dengan urutan sesuai posisi array
        $pivot = [];
        foreach ($validated['checkpoints'] as $urutan => $cpId) {
            $pivot[$cpId] = ['urutan' => $urutan + 1];
        }
        $rute->checkpoint()->sync($pivot);

        return redirect()
            ->route('admin.rute.index', $request->only('search'))
            ->with('success', 'Rute berhasil ditambahkan.');
    }

    // ── UPDATE ───────────────────────────────────────────
    public function update(Request $request, Rute $rute)
    {
        $validated = $request->validate([
            'nama_rute'     => [
                'required', 'string', 'max:255',
                \Illuminate\Validation\Rule::unique('rute', 'nama_rute')->ignore($rute->id),
            ],
            'checkpoints'   => 'required|array|min:1',
            'checkpoints.*' => 'exists:checkpoint,id',
        ], [
            'nama_rute.required'   => 'Nama rute wajib diisi.',
            'nama_rute.unique'     => 'Nama rute sudah digunakan.',
            'checkpoints.required' => 'Pilih minimal satu checkpoint.',
            'checkpoints.min'      => 'Pilih minimal satu checkpoint.',
            'checkpoints.*.exists' => 'Checkpoint tidak valid.',
        ]);

        $rute->update(['nama_rute' => $validated['nama_rute']]);

        // Sync ulang dengan urutan baru
        $pivot = [];
        foreach ($validated['checkpoints'] as $urutan => $cpId) {
            $pivot[$cpId] = ['urutan' => $urutan + 1];
        }
        $rute->checkpoint()->sync($pivot);

        return redirect()
            ->route('admin.rute.index', $request->only('search'))
            ->with('success', 'Rute berhasil diperbarui.');
    }

    // ── DESTROY ──────────────────────────────────────────
    public function destroy(Request $request, Rute $rute)
    {
        // Hapus pivot terlebih dahulu, lalu hapus rute
        $rute->checkpoint()->detach();
        $rute->delete();

        return redirect()
            ->route('admin.rute.index', $request->only('search'))
            ->with('success', 'Rute berhasil dihapus.');
    }
}