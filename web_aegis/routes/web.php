<?php

use App\Http\Controllers\Admin\CheckpointController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\JadwalController;
use App\Http\Controllers\Admin\PosJagaController;
use App\Http\Controllers\Admin\RuteController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Auth\WebAuthController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;

Route::get('/', function () {
    return Auth::check()
        ? redirect()->route('admin.dashboard')
        : redirect()->route('login');
});

// ── Auth Web ────────────────────────────────────────────
Route::middleware('guest')->group(function () {
    Route::get('/login', [WebAuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [WebAuthController::class, 'login'])->name('login.post');
});

Route::post('/logout', [WebAuthController::class, 'logout'])
    ->middleware('auth')
    ->name('logout');

// ── Admin Area ──────────────────────────────────────────
Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::post('/informasi', [DashboardController::class, 'kirimPesan'])
        ->name('informasi.kirim');

    // ── Manajemen User ──────────────────────────────────
    Route::get('/users', [UserController::class, 'index'])->name('users.index');
    Route::post('/users', [UserController::class, 'store'])->name('users.store');
    Route::put('/users/{user}', [UserController::class, 'update'])->name('users.update');
    Route::delete('/users/{user}', [UserController::class, 'destroy'])->name('users.destroy');


    // ── Manajemen Checkpoint ──────────────────────────────────

    Route::get('/checkpoint',              [CheckpointController::class, 'index'])  ->name('checkpoint.index');
    Route::post('/checkpoint',             [CheckpointController::class, 'store'])  ->name('checkpoint.store');
    Route::put('/checkpoint/{checkpoint}', [CheckpointController::class, 'update']) ->name('checkpoint.update');
    Route::delete('/checkpoint/{checkpoint}', [CheckpointController::class, 'destroy'])->name('checkpoint.destroy');

      // ── Rute Patroli ────────────────────────────────────
    Route::get('/rute',          [RuteController::class, 'index'])  ->name('rute.index');
    Route::post('/rute',         [RuteController::class, 'store'])  ->name('rute.store');
    Route::put('/rute/{rute}',   [RuteController::class, 'update']) ->name('rute.update');
    Route::delete('/rute/{rute}',[RuteController::class, 'destroy'])->name('rute.destroy');


      // ── Pos Jaga ────────────────────────────────────
    Route::get('/pos-jaga',              [PosJagaController::class, 'index'])  ->name('pos-jaga.index');
    Route::post('/pos-jaga',             [PosJagaController::class, 'store'])  ->name('pos-jaga.store');
    Route::put('/pos-jaga/{posJaga}',    [PosJagaController::class, 'update']) ->name('pos-jaga.update');
    Route::delete('/pos-jaga/{posJaga}', [PosJagaController::class, 'destroy'])->name('pos-jaga.destroy');

     // ── Jadwal Absensi ──────────────────────────────────
    Route::get('/jadwal',                        [JadwalController::class, 'index'])          ->name('jadwal.index');
    Route::post('/jadwal',                       [JadwalController::class, 'store'])          ->name('jadwal.store');
    Route::post('/jadwal/auto-generate',         [JadwalController::class, 'autoGenerate'])   ->name('jadwal.auto-generate'); // ← pindah ke atas
    Route::put('/jadwal/absensi/{absensi}',      [JadwalController::class, 'update'])         ->name('jadwal.absensi.update');
    Route::delete('/jadwal/absensi/{absensi}',   [JadwalController::class, 'destroyAbsensi']) ->name('jadwal.absensi.destroy');
    Route::delete('/jadwal/template',            [JadwalController::class, 'destroyTemplate'])->name('jadwal.template.destroy');
});