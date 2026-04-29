<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sos extends Model
{
    use HasFactory;

    protected $table = 'sos';

    protected $fillable = [
        'id_user',
        'latitude',
        'longitude',
        'jenis_keadaan',
        'deskripsi',
        'waktu_kirim',
        'status',
        'bantuan_warga',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'waktu_kirim' => 'datetime',
        'bantuan_warga' => 'boolean',
    ];

    
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}