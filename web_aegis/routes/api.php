<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ForgotPasswordController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\SosController;
use App\Http\Controllers\Api\TamuController;
use Illuminate\Support\Facades\Route;

// ── Auth API (Flutter) ──────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendOtp']);
    Route::post('/verify-otp',      [ForgotPasswordController::class, 'verifyOtp']);
    Route::post('/reset-password',  [ForgotPasswordController::class, 'resetPassword']);
});

// ── Protected API Routes ────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::prefix('auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/logout-all', [AuthController::class, 'logoutAll']);
    });

    // ── Petugas Routes ──────────────────────────────────
    Route::middleware('role:petugas')->prefix('petugas')->name('petugas.')->group(function () {
        Route::patch('/sos/{id}', [SosController::class, 'update'])->name('sos.update');
        Route::prefix('jadwal')->name('jadwal.')->group(function () {
        Route::get('/mingguan', [JadwalController::class, 'mingguan'])->name('mingguan');
        Route::get('/absensi', [JadwalController::class, 'riwayatAbsensi'])->name('absensi.index');
        Route::get('/absensi/{id}', [JadwalController::class, 'showAbsensi'])->name('absensi.show');
    });
    });

    // ── Buku Tamu Routes ────────────────────────────────
    // GET — semua role bisa lihat
    Route::middleware('role:petugas,supervisor,warga')->group(function () {
        Route::get('/tamu', [TamuController::class, 'index'])->name('tamu.index');
    });
    // POST/PATCH/PUT — hanya petugas yang bisa tambah/edit
    Route::middleware('role:petugas')->group(function () {
        Route::post('/tamu', [TamuController::class, 'store'])->name('tamu.store');
        Route::patch('/tamu/{id}', [TamuController::class, 'update'])->name('tamu.update');
        Route::put('/tamu/{id}', [TamuController::class, 'update'])->name('tamu.put');
    });

    // ── Supervisor Routes ───────────────────────────────
    Route::middleware('role:supervisor')->prefix('supervisor')->name('supervisor.')->group(function () {
        Route::patch('/sos/{id}', [SosController::class, 'update'])->name('sos.update');
    });

    // ── Warga Routes ────────────────────────────────────
    Route::middleware('role:warga')->prefix('warga')->name('warga.')->group(function () {
        // Route::post('/laporan', [WargaLaporanController::class, 'store']);
    });

    // ── Shared (semua role mobile bisa akses) ───────────
    Route::middleware('role:petugas,supervisor,warga')->group(function () {
        Route::post('/sos', [SosController::class, 'store'])->name('sos.store');
        Route::get('/sos/{id}', [SosController::class, 'show'])->name('sos.show');
         Route::get('/sos', [SosController::class, 'index'])->name('sos.index');
    });
});
