<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SosController;
use Illuminate\Support\Facades\Route;

// ── Auth API (Flutter) ──────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
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