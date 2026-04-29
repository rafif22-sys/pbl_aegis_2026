<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // =========================
        // ADMIN (2)
        // =========================
        $admin1 = User::create([
            'nama' => 'Admin Utama',
            'email' => 'admin1@mail.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'tanggal_lahir' => '1990-01-01',
            'alamat' => 'Jakarta',
            'no_hp' => '081111111111',
            'foto_profil' => '/foto_profil/admin/1_admin_utama.jpg',
        ]);

        $admin2 = User::create([
            'nama' => 'Admin Kedua',
            'email' => 'admin2@mail.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'tanggal_lahir' => '1991-02-02',
            'alamat' => 'Bandung',
            'no_hp' => '081111111112',
            'foto_profil' => '/foto_profil/admin/2_admin_kedua.jpg',
        ]);

        // =========================
        // SUPERVISOR (2)
        // =========================
        $supervisor1 = User::create([
            'nama' => 'Supervisor Satu',
            'email' => 'spv1@mail.com',
            'password' => Hash::make('password'),
            'role' => 'supervisor',
            'tanggal_lahir' => '1985-03-10',
            'alamat' => 'Semarang',
            'no_hp' => '081111111113',
            'tanggal_bergabung' => now()->subYears(2),
            'wilayah_pengawasan' => 'Wilayah A',
            'foto_profil' => '/foto_profil/supervisor/1_supervisor_satu.jpg',
        ]);

        $supervisor2 = User::create([
            'nama' => 'Supervisor Dua',
            'email' => 'spv2@mail.com',
            'password' => Hash::make('password'),
            'role' => 'supervisor',
            'tanggal_lahir' => '1986-04-12',
            'alamat' => 'Solo',
            'no_hp' => '081111111114',
            'tanggal_bergabung' => now()->subYears(3),
            'wilayah_pengawasan' => 'Wilayah B',
            'foto_profil' => '/foto_profil/supervisor/2_supervisor_dua.jpg',
        ]);

        // =========================
        // PETUGAS (6)
        // =========================
        $petugas = [
            ['nama' => 'Petugas A1', 'email' => 'petugas1@mail.com', 'spv' => $supervisor1->id],
            ['nama' => 'Petugas A2', 'email' => 'petugas2@mail.com', 'spv' => $supervisor1->id],
            ['nama' => 'Petugas A3', 'email' => 'petugas3@mail.com', 'spv' => $supervisor1->id],
            ['nama' => 'Petugas B1', 'email' => 'petugas4@mail.com', 'spv' => $supervisor2->id],
            ['nama' => 'Petugas B2', 'email' => 'petugas5@mail.com', 'spv' => $supervisor2->id],
            ['nama' => 'Petugas B3', 'email' => 'petugas6@mail.com', 'spv' => $supervisor2->id],
        ];

        foreach ($petugas as $i => $p) {
            $id = $i + 1;

            $slug = strtolower(str_replace(' ', '_', $p['nama']));

            User::create([
                'nama' => $p['nama'],
                'email' => $p['email'],
                'password' => Hash::make('password'),
                'role' => 'petugas',
                'id_supervisor' => $p['spv'],
                'tanggal_lahir' => '1995-01-01',
                'alamat' => 'Area Petugas',
                'no_hp' => '08122222000' . $id,
                'tanggal_bergabung' => now()->subYear(),
                'wilayah_pengawasan' => null,
                'foto_profil' => "/foto_profil/petugas/{$id}_{$slug}.jpg",
            ]);
        }

        // =========================
        // WARGA (3)
        // =========================
        for ($i = 1; $i <= 3; $i++) {

            $nama = "Warga {$i}";
            $slug = strtolower(str_replace(' ', '_', $nama));

            User::create([
                'nama' => $nama,
                'email' => 'warga' . $i . '@mail.com',
                'password' => Hash::make('password'),
                'role' => 'warga',
                'tanggal_lahir' => '2000-01-0' . $i,
                'alamat' => 'Alamat Warga',
                'no_hp' => '08133333000' . $i,
                'foto_profil' => "/foto_profil/warga/{$i}_{$slug}.jpg",
            ]);
        }
    }
}