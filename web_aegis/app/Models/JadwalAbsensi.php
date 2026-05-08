<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

// import relasi
use App\Models\User;
use App\Models\LaporanCheckpoint;

class JadwalAbsensi extends Model
{
    use HasFactory;

    protected $table = 'jadwal_absensi';

    protected $fillable = [
        'id_user',
        'id_jadwal',
        'id_rute',
        // 'tanggal',
        'jam_masuk',
        'jam_pulang',
        'status',
        'foto_masuk',
        'foto_pulang',
        'latitude',
        'longitude',
    ];

    protected $casts = [
        // 'tanggal' => 'date',
        'jam_masuk' => 'datetime:H:i:s',
        'jam_pulang' => 'datetime:H:i:s',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    
    public function rute()
    {
        return $this->belongsTo(Rute::class, 'id_rute');
    }
    
    public function jadwal()
    {
        return $this->belongsTo(Jadwal::class, 'id_jadwal');
    }

   
    public function laporanCheckpoint()
    {
        return $this->hasMany(LaporanCheckpoint::class, 'id_jadwal_absensi');
    }
}