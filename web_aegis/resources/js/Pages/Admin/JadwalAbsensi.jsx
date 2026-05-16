import { useState, useMemo } from 'react';
import { router, useForm, usePage } from '@inertiajs/react';
import { Head } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { FormInput, inputStyle } from '@/Components/Admin/FormInput';
import { StatCard } from '@/Components/Admin/StatCard';

// ─── Konstanta ────────────────────────────────────────────────────────────────

const DAYS   = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];


// ─── Utilitas ─────────────────────────────────────────────────────────────────

function getWeekDates(startOfWeek) {
    return Array.from({ length: 7 }, (_, i) => {
        const d = new Date(startOfWeek);
        d.setDate(d.getDate() + i);
        return d;
    });
}

function toDateStr(d) { return d.toISOString().split('T')[0]; }

function isToday(dateStr) {
    const t = new Date(), d = new Date(dateStr);
    return d.getDate()     === t.getDate()
        && d.getMonth()    === t.getMonth()
        && d.getFullYear() === t.getFullYear();
}

function formatWeekRange(startOfWeek, endOfWeek) {
    const s = new Date(startOfWeek), e = new Date(endOfWeek);
    return `${s.getDate()} ${MONTHS[s.getMonth()]} – ${e.getDate()} ${MONTHS[e.getMonth()]} ${e.getFullYear()}`;
}

function shiftKey(nama) {
    const n = (nama || '').toLowerCase();
    if (n.includes('pagi'))  return 'pagi';
    if (n.includes('siang')) return 'siang';
    return 'malam';
}

// ─── Warna shift ──────────────────────────────────────────────────────────────

const SHIFT_COLOR = {
    pagi:  { bg: '#f0fdf4', border: '#86efac', text: '#166534', sub: '#16a34a' },
    siang: { bg: '#fffbeb', border: '#fcd34d', text: '#92400e', sub: '#d97706' },
    malam: { bg: '#eef2ff', border: '#a5b4fc', text: '#3730a3', sub: '#4f46e5' },
};

// ─── Status Badge ─────────────────────────────────────────────────────────────

const STATUS_STYLE = {
    hadir:     { bg: '#f0fdf4', border: '#86efac', text: '#166534' },
    terlambat: { bg: '#fffbeb', border: '#fcd34d', text: '#92400e' },
    alpha:     { bg: '#fef2f2', border: '#fca5a5', text: '#991b1b' },
    menunggu:  { bg: '#f8fafc', border: '#cbd5e1', text: '#64748b' }, // ← ganti belum_absen
};

// StatusBadge — ganti fallback
function StatusBadge({ status }) {
    const s = STATUS_STYLE[status] ?? STATUS_STYLE.menunggu; // ← ganti belum_absen
    return (
        <span className="inline-block text-[10px] font-medium px-2 py-0.5 rounded-full border"
            style={{ background: s.bg, borderColor: s.border, color: s.text }}>
            {(status ?? 'menunggu').replace('_', ' ')} {/* ← ganti belum_absen */}
        </span>
    );
}

// ─── Flash ────────────────────────────────────────────────────────────────────

function Flash() {
    const { flash } = usePage().props;
    if (!flash?.success && !flash?.error) return null;
    return (
        <div className="mb-4 px-4 py-3 rounded-xl text-sm border"
            style={flash.success
                ? { background: '#f0fdf4', borderColor: '#86efac', color: '#166534' }
                : { background: '#fef2f2', borderColor: '#fca5a5', color: '#991b1b' }}>
            {flash.success ?? flash.error}
        </div>
    );
}

// ─── Jadwal Card ──────────────────────────────────────────────────────────────

function JadwalCard({ absensi, shiftNama, onClick }) {
    const c = SHIFT_COLOR[shiftKey(shiftNama)];
    return (
        <div onClick={onClick}
            className="rounded-lg border px-2 py-1.5 mb-1 cursor-pointer transition-all hover:shadow-sm hover:scale-[1.01]"
            style={{ background: c.bg, borderColor: c.border }}>
            <p className="text-[11px] font-semibold truncate" style={{ color: c.text }}>
                {absensi.user?.nama ?? '—'}
            </p>
            <p className="text-[10px] truncate" style={{ color: c.sub }}>
                {absensi.rute?.nama ?? '—'}
            </p>
        </div>
    );
}

// ─── Select ───────────────────────────────────────────────────────────────────

function Select({ value, onChange, children, error }) {
    return (
        <select value={value} onChange={onChange}
            className="w-full text-sm rounded-xl px-3 py-2.5 focus:outline-none transition-all"
            style={inputStyle(error)}>
            {children}
        </select>
    );
}

// ─── InfoRow ──────────────────────────────────────────────────────────────────

function InfoRow({ label, value }) {
    return (
        <div className="flex items-center justify-between gap-4">
            <span className="text-xs shrink-0" style={{ color: '#94a3b8' }}>{label}</span>
            <span className="text-xs font-semibold text-right" style={{ color: '#0F2A44' }}>{value}</span>
        </div>
    );
}

// ─── Modal Tambah ─────────────────────────────────────────────────────────────

function ModalTambah({ open, onClose, posJagas, shifts, petugas, rutes, defaultTanggal, defaultShiftId }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        id_pos_jaga : posJagas[0]?.id ?? '',
        id_shift    : shifts[0]?.id   ?? '',  // selalu number/string konsisten
        id_user     : petugas[0]?.id  ?? '',
        id_rute     : rutes[0]?.id    ?? '',
        tanggal     : defaultTanggal  ?? '',
        scope       : 'week',
    });

    useMemo(() => {
        if (!open) return;
        setData(prev => ({
            ...prev,
            // Gunakan Number() agar tipe konsisten dengan shifts[].id
            id_shift : defaultShiftId ? Number(defaultShiftId) : (shifts[0]?.id ?? ''),
            tanggal  : defaultTanggal ?? prev.tanggal,
        }));
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [open, defaultShiftId, defaultTanggal]);

    const submit = (e) => {
        e.preventDefault();
        post(route('admin.jadwal.store'), {
            onSuccess: () => { reset(); onClose(); },
        });
    };

    if (!open) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md max-h-[90vh] overflow-y-auto">

                {/* Header — sama dengan ManajemenUser */}
                <div className="flex items-center justify-between px-6 py-4 border-b sticky top-0 bg-white z-10"
                    style={{ borderColor: '#e0f2fe' }}>
                    <div>
                        <h2 className="text-base font-bold" style={{ color: '#0F2A44' }}>Tambah Jadwal</h2>
                        <p className="text-[11px] mt-0.5" style={{ color: '#94a3b8' }}>
                            Isi form untuk menambah jadwal patroli
                        </p>
                    </div>
                    <button onClick={onClose}
                        className="w-8 h-8 rounded-lg flex items-center justify-center transition-colors hover:bg-gray-100"
                        style={{ color: '#94a3b8' }}>✕</button>
                </div>

                <form onSubmit={submit} className="px-6 py-5 space-y-4">
                    <FormInput label="Pos Jaga" required error={errors.id_pos_jaga}>
                        <Select value={data.id_pos_jaga}
                            onChange={e => setData('id_pos_jaga', e.target.value)}
                            error={errors.id_pos_jaga}>
                            {posJagas.map(p => <option key={p.id} value={p.id}>{p.nama}</option>)}
                        </Select>
                    </FormInput>

                    <FormInput label="Shift" required error={errors.id_shift}>
                        <Select
                            value={data.id_shift}
                            onChange={e => setData('id_shift', Number(e.target.value))} 
                            error={errors.id_shift}>
                            {shifts.map(s => (
                                <option key={s.id} value={s.id}>
                                    {s.nama} ({s.jam_masuk} – {s.jam_pulang})
                                </option>
                            ))}
                        </Select>
                    </FormInput>

                    <FormInput label="Petugas" required error={errors.id_user}>
                        <Select value={data.id_user}
                            onChange={e => setData('id_user', e.target.value)}
                            error={errors.id_user}>
                            {petugas.map(u => <option key={u.id} value={u.id}>{u.nama}</option>)}
                        </Select>
                    </FormInput>

                    <FormInput label="Rute Patroli" required error={errors.id_rute}>
                        <Select value={data.id_rute}
                            onChange={e => setData('id_rute', e.target.value)}
                            error={errors.id_rute}>
                            {rutes.map(r => <option key={r.id} value={r.id}>{r.nama}</option>)}
                        </Select>
                    </FormInput>

                    <FormInput label="Tanggal" required error={errors.tanggal}>
                        <input type="date" value={data.tanggal}
                            onChange={e => setData('tanggal', e.target.value)}
                            className="w-full text-sm rounded-xl px-3 py-2.5 focus:outline-none transition-all"
                            style={inputStyle(errors.tanggal)} />
                    </FormInput>

                    <FormInput label="Terapkan ke">
                        <Select value={data.scope} onChange={e => setData('scope', e.target.value)}>
                            <option value="week">Minggu ini saja</option>
                            <option value="template">Template berulang (12 minggu ke depan)</option>
                        </Select>
                    </FormInput>

                    {data.scope === 'template' && (
                        <div className="rounded-xl px-4 py-3 text-xs border"
                            style={{ background: '#fffbeb', borderColor: '#fcd34d', color: '#92400e' }}>
                            ⚠️ Jadwal akan dibuat otomatis untuk 12 minggu ke depan pada hari yang sama setiap minggunya.
                        </div>
                    )}

                    <div className="flex justify-end gap-2 pt-2">
                        <button type="button" onClick={onClose}
                            className="px-4 py-2 text-sm rounded-xl border transition-colors hover:bg-gray-50"
                            style={{ borderColor: '#c7e8f8', color: '#64748b' }}>
                            Batal
                        </button>
                        <button type="submit" disabled={processing}
                            className="px-5 py-2 text-sm rounded-xl font-semibold transition-colors hover:opacity-90 disabled:opacity-60"
                            style={{ background: '#005EA4', color: 'white' }}>
                            {processing ? 'Menyimpan...' : 'Simpan Jadwal'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// ─── Modal Detail ─────────────────────────────────────────────────────────────

function ModalDetail({ open, onClose, jadwal, absensi, petugas, rutes }) {
    const [editMode, setEditMode] = useState(false);
    const [editUser, setEditUser] = useState('');
    const [editRute, setEditRute] = useState('');

    useMemo(() => {
        if (absensi) {
            setEditUser(absensi.user?.id ?? '');
            setEditRute(absensi.rute?.id ?? '');
        }
        setEditMode(false);
    }, [absensi]);

    if (!open || !jadwal || !absensi) return null;

    const handleUpdate = () => {
        router.put(route('admin.jadwal.absensi.update', absensi.id), {
            id_user: editUser, id_rute: editRute,
        }, { onSuccess: () => { setEditMode(false); onClose(); } });
    };

    const handleHapusMingguIni = () => {
        if (!confirm(`Hapus jadwal ${absensi.user?.nama} pada ${jadwal.tanggal}?`)) return;
        router.delete(route('admin.jadwal.absensi.destroy', absensi.id), { onSuccess: onClose });
    };

    const handleHapusTemplate = () => {
        if (!confirm(`Hapus semua jadwal berulang ${absensi.user?.nama} dari minggu ini ke depan?`)) return;
        router.delete(route('admin.jadwal.template.destroy'), {
            data: {
                id_pos_jaga : jadwal.pos_jaga?.id,
                id_shift    : jadwal.shift?.id,
                id_user     : absensi.user?.id,
                from_date   : jadwal.tanggal,
            },
            onSuccess: onClose,
        });
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm">

                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b"
                    style={{ borderColor: '#e0f2fe' }}>
                    <div>
                        <h2 className="text-base font-bold" style={{ color: '#0F2A44' }}>Detail Jadwal</h2>
                        <p className="text-[11px] mt-0.5" style={{ color: '#94a3b8' }}>{jadwal.tanggal}</p>
                    </div>
                    <button onClick={onClose}
                        className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-gray-100"
                        style={{ color: '#94a3b8' }}>✕</button>
                </div>

                {/* Body */}
                <div className="px-6 py-5 space-y-3">
                    <div className="rounded-xl p-3 space-y-2"
                        style={{ background: '#f8fafc', border: '1.5px solid #c7e8f8' }}>
                        <InfoRow label="Pos Jaga" value={jadwal.pos_jaga?.nama} />
                        <InfoRow label="Shift"    value={jadwal.shift?.nama} />
                        <InfoRow label="Jam"      value={`${jadwal.shift?.jam_masuk} – ${jadwal.shift?.jam_pulang}`} />
                    </div>

                    <div className="h-px" style={{ background: '#e0f2fe' }} />

                    {editMode ? (
                        <div className="space-y-3">
                            <FormInput label="Petugas">
                                <Select value={editUser} onChange={e => setEditUser(e.target.value)}>
                                    {petugas.map(u => <option key={u.id} value={u.id}>{u.nama}</option>)}
                                </Select>
                            </FormInput>
                            <FormInput label="Rute">
                                <Select value={editRute} onChange={e => setEditRute(e.target.value)}>
                                    {rutes.map(r => <option key={r.id} value={r.id}>{r.nama}</option>)}
                                </Select>
                            </FormInput>
                        </div>
                    ) : (
                        <div className="space-y-2">
                            <InfoRow label="Petugas" value={absensi.user?.nama} />
                            <InfoRow label="Rute"    value={absensi.rute?.nama} />
                            <InfoRow label="Status"  value={<StatusBadge status={absensi.status} />} />
                        </div>
                    )}
                </div>

                {/* Footer */}
                <div className="px-6 py-4 border-t" style={{ borderColor: '#e0f2fe' }}>
                    {editMode ? (
                        <div className="flex gap-2 justify-end">
                            <button onClick={() => setEditMode(false)}
                                className="px-4 py-2 text-sm rounded-xl border hover:bg-gray-50"
                                style={{ borderColor: '#c7e8f8', color: '#64748b' }}>
                                Batal
                            </button>
                            <button onClick={handleUpdate}
                                className="px-4 py-2 text-sm rounded-xl font-semibold hover:opacity-90"
                                style={{ background: '#005EA4', color: 'white' }}>
                                Simpan Perubahan
                            </button>
                        </div>
                    ) : (
                        <div className="flex flex-wrap gap-2">
                            {/* Edit — sama dengan ManajemenUser */}
                            <button onClick={() => setEditMode(true)}
                                className="w-7 h-7 rounded-lg flex items-center justify-center hover:scale-105 transition-transform"
                                style={{ background: '#e0f2fe' }} title="Edit">
                                ✏️
                            </button>
                            <button onClick={handleHapusMingguIni}
                                className="w-7 h-7 rounded-lg flex items-center justify-center hover:scale-105 transition-transform"
                                style={{ background: '#fde8e8' }} title="Hapus Minggu Ini">
                                🗑
                            </button>
                            <button onClick={handleHapusTemplate}
                                className="px-3 py-1.5 text-xs rounded-xl font-semibold hover:opacity-90"
                                style={{ background: '#fde8e8', color: '#c0392b' }}>
                                Hapus Template
                            </button>
                            <button onClick={onClose}
                                className="ml-auto px-4 py-2 text-sm rounded-xl border hover:bg-gray-50"
                                style={{ borderColor: '#c7e8f8', color: '#64748b' }}>
                                Tutup
                            </button>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}


function ModalAutoGenerate({ open, onClose, weekOffset, startOfWeek, endOfWeek }) {
    const [processing, setProcessing] = useState(false);

    if (!open) return null;

    const handleGenerate = () => {
        if (!confirm(`Generate jadwal otomatis untuk minggu\n${formatWeekRange(startOfWeek, endOfWeek)}?\n\nJadwal yang sudah ada tidak akan ditimpa.`)) return;

        setProcessing(true);
        router.post(route('admin.jadwal.auto-generate'),
            { week_offset: weekOffset },
            {
                onSuccess: () => { setProcessing(false); onClose(); },
                onError:   () => { setProcessing(false); },
            }
        );
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm">

                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b"
                    style={{ borderColor: '#e0f2fe' }}>
                    <div>
                        <h2 className="text-base font-bold" style={{ color: '#0F2A44' }}>
                            Generate Jadwal Otomatis
                        </h2>
                        <p className="text-[11px] mt-0.5" style={{ color: '#94a3b8' }}>
                            Buat jadwal minggu ini secara otomatis
                        </p>
                    </div>
                    <button onClick={onClose}
                        className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-gray-100"
                        style={{ color: '#94a3b8' }}>✕</button>
                </div>

                {/* Body */}
                <div className="px-6 py-5 space-y-4">

                    {/* Info periode */}
                    <div className="rounded-xl px-4 py-3 border"
                        style={{ background: '#f0f9ff', borderColor: '#c7e8f8' }}>
                        <p className="text-xs font-semibold mb-1" style={{ color: '#0F2A44' }}>
                            Periode Minggu Ini
                        </p>
                        <p className="text-sm font-bold" style={{ color: '#005EA4' }}>
                            {formatWeekRange(startOfWeek, endOfWeek)}
                        </p>
                    </div>

                    {/* Aturan */}
                    <div className="space-y-2">
                        <p className="text-xs font-semibold" style={{ color: '#0F2A44' }}>
                            Aturan penjadwalan:
                        </p>
                        {[
                            '🔄 Rotasi libur otomatis — 1 petugas libur per hari per pos',
                            '👥 Setiap shift diisi minimal 2 petugas',
                            '📍 Petugas dibagi merata ke masing-masing pos jaga',
                            '✅ Jadwal yang sudah ada tidak akan ditimpa',
                        ].map(item => (
                            <div key={item} className="flex items-start gap-2 text-xs"
                                style={{ color: '#64748b' }}>
                                <span>{item}</span>
                            </div>
                        ))}
                    </div>

                    {/* Warning */}
                    <div className="rounded-xl px-4 py-3 border text-xs"
                        style={{ background: '#fffbeb', borderColor: '#fcd34d', color: '#92400e' }}>
                        ⚠️ Pastikan data petugas, shift, rute, dan pos jaga sudah lengkap sebelum generate.
                    </div>
                </div>

                {/* Footer */}
                <div className="px-6 py-4 border-t flex justify-end gap-2"
                    style={{ borderColor: '#e0f2fe' }}>
                    <button onClick={onClose}
                        className="px-4 py-2 text-sm rounded-xl border hover:bg-gray-50"
                        style={{ borderColor: '#c7e8f8', color: '#64748b' }}>
                        Batal
                    </button>
                    <button onClick={handleGenerate} disabled={processing}
                        className="px-5 py-2 text-sm rounded-xl font-semibold hover:opacity-90 disabled:opacity-60 flex items-center gap-2"
                        style={{ background: '#005EA4', color: 'white' }}>
                        {processing ? (
                            <>
                                <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none"
                                    stroke="currentColor" strokeWidth="2">
                                    <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
                                </svg>
                                Generating...
                            </>
                        ) : (
                            '🗓️ Generate Sekarang'
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
}

// ─── Halaman Utama ────────────────────────────────────────────────────────────

export default function JadwalAbsensi({
    jadwals, posJagas, shifts, petugas, rutes, stats,
    weekOffset, startOfWeek, endOfWeek, filters,
}) {
    const [localOffset,    setLocalOffset]    = useState(weekOffset);
    const [filterPos,      setFilterPos]      = useState(filters.pos_jaga_id ?? '');
    const [filterShift,    setFilterShift]    = useState(filters.shift_id    ?? '');
    const [showTambah,     setShowTambah]     = useState(false);
    const [defaultTanggal, setDefaultTanggal] = useState('');
    const [defaultShiftId, setDefaultShiftId] = useState('');
    const [showDetail,     setShowDetail]     = useState(false);
    const [detailJadwal,   setDetailJadwal]   = useState(null);
    const [detailAbsensi,  setDetailAbsensi]  = useState(null);
    const [showAutoGenerate, setShowAutoGenerate] = useState(false);

    const weekDates = useMemo(() => getWeekDates(startOfWeek), [startOfWeek]);

    const changeWeek = (dir) => {
        const next = localOffset + dir;
        setLocalOffset(next);
        router.get(route('admin.jadwal.index'),
            { week_offset: next, pos_jaga_id: filterPos || undefined, shift_id: filterShift || undefined },
            { preserveState: true, replace: true });
    };

    const applyFilter = (pos, shift) => {
        router.get(route('admin.jadwal.index'),
            { week_offset: localOffset, pos_jaga_id: pos || undefined, shift_id: shift || undefined },
            { preserveState: true, replace: true });
    };

    const onFilterPos   = (val) => { setFilterPos(val);   applyFilter(val, filterShift); };
    const onFilterShift = (val) => { setFilterShift(val); applyFilter(filterPos, val);   };

    const openAddFromCell = (tanggal, shiftId) => {
        setDefaultTanggal(tanggal);
        setDefaultShiftId(shiftId); // langsung pakai number
        setShowTambah(true);
    };

    const openDetail = (jadwal, ab) => {
        setDetailJadwal(jadwal);
        setDetailAbsensi(ab);
        setShowDetail(true);
    };

    // StatCard data — sama pola dengan ManajemenUser
    const statCards = [
        {
            label: 'Total Jadwal',
            value: stats.total_jadwal,
            sub: 'minggu ini',
            blue: true,
            icon: (
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.8">
                    <rect x="3" y="4" width="18" height="18" rx="3"/>
                    <path d="M16 2v4M8 2v4M3 10h18"/>
                </svg>
            ),
            accent: '#fbbf24',
        },
        {
            label: 'Petugas Aktif',
            value: stats.total_petugas,
            sub: 'terjadwal minggu ini',
            blue: false,
            icon: (
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="1.8">
                    <circle cx="12" cy="8" r="4"/>
                    <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                </svg>
            ),
            accent: '#005EA4',
        },
        {
            label: 'Rute Dipakai',
            value: stats.total_rute,
            sub: 'jalur berbeda',
            blue: true,
            icon: (
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.8">
                    <path d="M3 12h18M3 6l9-3 9 3M3 18l9 3 9-3"/>
                </svg>
            ),
            accent: '#34d399',
        },
        {
            label: 'Shift Terisi',
            value: stats.shift_terisi,
            sub: 'dari semua shift',
            blue: false,
            icon: (
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="1.8">
                    <circle cx="12" cy="12" r="9"/>
                    <path d="M12 7v5l3 3"/>
                </svg>
            ),
            accent: '#7c3aed',
        },
    ];

    return (
        <>
            <Head title="Jadwal Absensi" />
            <AdminLayout activeMenu="Jadwal Absensi" title="Jadwal Absensi">
                <div className="flex flex-col gap-3 flex-1 min-h-0">
                    <Flash />

                    {/* ── Stat Cards — sama persis dengan ManajemenUser ── */}
                    <div className="grid grid-cols-4 gap-4 shrink-0">
                        {statCards.map(c => <StatCard key={c.label} {...c} />)}
                    </div>

                    {/* ── Table Card — sama struktur dengan ManajemenUser ── */}
                    <div className="flex-1 rounded-2xl overflow-hidden flex flex-col min-h-0 shadow-sm"
                        style={{ background: 'white', border: '1.5px solid #c7e8f8' }}>

                        {/* Toolbar */}
                        <div className="px-5 py-3 shrink-0 flex items-center gap-3 flex-wrap"
                            style={{ borderBottom: '1.5px solid #e0f2fe' }}>

                            {/* Judul */}
                            <div className="flex items-center gap-2">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="2">
                                    <rect x="3" y="4" width="18" height="18" rx="3"/>
                                    <path d="M16 2v4M8 2v4M3 10h18"/>
                                </svg>
                                <h2 className="font-semibold text-sm" style={{ color: '#0F2A44' }}>
                                    Jadwal Mingguan Patroli
                                </h2>
                            </div>

                            {/* Filter Pos Jaga */}
                            <select value={filterPos} onChange={e => onFilterPos(e.target.value)}
                                className="text-xs rounded-xl px-3 py-2 outline-none transition-all"
                                style={{ background: '#f8fafc', border: '1.5px solid #c7e8f8', color: '#0F2A44' }}
                                onFocus={e => e.target.style.borderColor = '#005EA4'}
                                onBlur={e  => e.target.style.borderColor = '#c7e8f8'}>
                                <option value="">Semua Pos Jaga</option>
                                {posJagas.map(p => <option key={p.id} value={p.id}>{p.nama}</option>)}
                            </select>

                            {/* Filter Shift */}
                            <select value={filterShift} onChange={e => onFilterShift(e.target.value)}
                                className="text-xs rounded-xl px-3 py-2 outline-none transition-all"
                                style={{ background: '#f8fafc', border: '1.5px solid #c7e8f8', color: '#0F2A44' }}
                                onFocus={e => e.target.style.borderColor = '#005EA4'}
                                onBlur={e  => e.target.style.borderColor = '#c7e8f8'}>
                                <option value="">Semua Shift</option>
                                {shifts.map(s => <option key={s.id} value={s.id}>{s.nama}</option>)}
                            </select>

                            {/* Navigasi minggu */}
                            <div className="flex items-center gap-2">
                                <button onClick={() => changeWeek(-1)}
                                    className="w-7 h-7 rounded-lg flex items-center justify-center hover:scale-105 transition-transform"
                                    style={{ background: '#e0f2fe', color: '#005EA4' }}>
                                    ←
                                </button>
                                <span className="text-xs font-semibold min-w-[180px] text-center"
                                    style={{ color: '#0F2A44' }}>
                                    {formatWeekRange(startOfWeek, endOfWeek)}
                                </span>
                                <button onClick={() => changeWeek(1)}
                                    className="w-7 h-7 rounded-lg flex items-center justify-center hover:scale-105 transition-transform"
                                    style={{ background: '#e0f2fe', color: '#005EA4' }}>
                                    →
                                </button>
                            </div>

                            {/* Tombol Generate Otomatis — taruh sebelum tombol Tambah Jadwal */}
                            <button onClick={() => setShowAutoGenerate(true)}
                                className="ml-auto flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold hover:opacity-90 shrink-0"
                                style={{ background: '#059669', color: 'white' }}>
                                🗓️ Generate Otomatis
                            </button>

                            {/* Tombol tambah — sama dengan ManajemenUser */}
                            <button onClick={() => { setDefaultTanggal(''); setDefaultShiftId(''); setShowTambah(true); }}
                                className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold text-white hover:opacity-90 shrink-0"
                                style={{ background: '#005EA4' }}>
                                + Tambah Jadwal
                            </button>
                        </div>

                        {/* Legend */}
                        <div className="px-5 py-2 flex items-center gap-4 shrink-0"
                            style={{ borderBottom: '1px solid #f0f9ff' }}>
                            {[
                                [SHIFT_COLOR.pagi,  'Shift Pagi'],
                                [SHIFT_COLOR.siang, 'Shift Siang'],
                                [SHIFT_COLOR.malam, 'Shift Malam'],
                            ].map(([c, label]) => (
                                <div key={label} className="flex items-center gap-1.5 text-[10px]"
                                    style={{ color: '#64748b' }}>
                                    <span className="w-2.5 h-2.5 rounded border"
                                        style={{ background: c.bg, borderColor: c.border }} />
                                    {label}
                                </div>
                            ))}

                            {/* Info banner kecil */}
                            <div className="ml-auto flex items-center gap-1.5 text-[10px]"
                                style={{ color: '#1d4ed8' }}>
                                ℹ️ Klik sel untuk tambah jadwal · Klik kartu untuk detail
                            </div>
                        </div>

                        {/* Grid Jadwal */}
                        <div className="flex-1 overflow-auto"
                            style={{ scrollbarWidth: 'thin', scrollbarColor: '#b8dff0 transparent' }}>
                            <div style={{ minWidth: 700 }}>

                                {/* Header hari */}
                                <div className="grid sticky top-0 z-10"
                                    style={{
                                        gridTemplateColumns : '110px repeat(7, 1fr)',
                                        background          : '#005EA4',
                                    }}>
                                    <div className="px-3 py-3 text-xs font-semibold text-white">Shift</div>
                                    {weekDates.map((d, i) => {
                                        const ds    = toDateStr(d);
                                        const today = isToday(ds);
                                        return (
                                            <div key={i}
                                                className="px-2 py-3 text-center text-xs font-medium border-l"
                                                style={{
                                                    borderColor : 'rgba(255,255,255,0.15)',
                                                    background  : today ? 'rgba(255,255,255,0.15)' : 'transparent',
                                                    color       : 'white',
                                                }}>
                                                <span className="block text-lg font-bold mb-0.5 leading-none">
                                                    {d.getDate()}
                                                </span>
                                                {DAYS[i]}
                                                {today && (
                                                    <span className="block text-[9px] mt-0.5 font-semibold"
                                                        style={{ color: '#fbbf24' }}>
                                                        HARI INI
                                                    </span>
                                                )}
                                            </div>
                                        );
                                    })}
                                </div>

                                {/* Baris shift */}
                                {shifts.map((shift, si) => (
                                    <div key={shift.id}
                                        className="grid"
                                        style={{
                                            gridTemplateColumns : '110px repeat(7, 1fr)',
                                            borderBottom        : si < shifts.length - 1
                                                ? '1px solid #e0f2fe' : 'none',
                                        }}>

                                        {/* Label shift */}
                                        <div className="px-3 py-3 flex flex-col gap-0.5 border-r"
                                            style={{ background: '#f8fafc', borderColor: '#c7e8f8' }}>
                                            <span className="text-xs font-bold" style={{ color: '#0F2A44' }}>
                                                {shift.nama}
                                            </span>
                                            <span className="text-[10px]" style={{ color: '#94a3b8' }}>
                                                {shift.jam_masuk} – {shift.jam_pulang}
                                            </span>
                                        </div>

                                        {/* Sel hari */}
                                        {weekDates.map((d, di) => {
                                            const dateStr      = toDateStr(d);
                                            const today        = isToday(dateStr);
                                            const matchJadwals = jadwals.filter(j =>
                                                j.tanggal === dateStr && j.shift?.id === shift.id
                                            );

                                            return (
                                                <div key={di}
                                                    onClick={() => openAddFromCell(dateStr, shift.id)}
                                                    className="border-l min-h-[90px] p-2 cursor-pointer transition-colors"
                                                    style={{ borderColor: '#e0f2fe', background: today ? '#f0f9ff' : 'white' }}
                                                    onMouseEnter={e => e.currentTarget.style.background = today ? '#dbeeff' : '#f8fafc'}
                                                    onMouseLeave={e => e.currentTarget.style.background = today ? '#f0f9ff' : 'white'}>

                                                    {matchJadwals.flatMap(j =>
                                                        j.absensi
                                                            .filter(ab => ab.status !== 'libur')  // ← tambah ini
                                                            .map(ab => (
                                                                <JadwalCard key={ab.id}
                                                                    absensi={ab}
                                                                    shiftNama={shift.nama}
                                                                    onClick={(e) => {
                                                                        e.stopPropagation();
                                                                        openDetail(j, ab);
                                                                    }}
                                                                />
                                                            ))
                                                    )}

                                                    {/* Tombol tambah dashed */}
                                                    <div className="flex items-center justify-center h-6 mt-1 rounded-lg border border-dashed text-sm transition-colors"
                                                        style={{ borderColor: '#c7e8f8', color: '#c7e8f8' }}
                                                        onMouseEnter={e => {
                                                            e.currentTarget.style.borderColor = '#005EA4';
                                                            e.currentTarget.style.color = '#005EA4';
                                                        }}
                                                        onMouseLeave={e => {
                                                            e.currentTarget.style.borderColor = '#c7e8f8';
                                                            e.currentTarget.style.color = '#c7e8f8';
                                                        }}>
                                                        +
                                                    </div>
                                                </div>
                                            );
                                        })}
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                </div>

                {/* Modals */}
                <ModalTambah
                    open={showTambah}
                    onClose={() => setShowTambah(false)}
                    posJagas={posJagas} shifts={shifts}
                    petugas={petugas}   rutes={rutes}
                    defaultTanggal={defaultTanggal}
                    defaultShiftId={defaultShiftId}
                />
                <ModalDetail
                    open={showDetail}
                    onClose={() => setShowDetail(false)}
                    jadwal={detailJadwal}
                    absensi={detailAbsensi}
                    petugas={petugas}
                    rutes={rutes}
                />

                <ModalAutoGenerate
                    open={showAutoGenerate}
                    onClose={() => setShowAutoGenerate(false)}
                    weekOffset={localOffset}
                    startOfWeek={startOfWeek}
                    endOfWeek={endOfWeek}
                />
            </AdminLayout>
        </>
    );
}