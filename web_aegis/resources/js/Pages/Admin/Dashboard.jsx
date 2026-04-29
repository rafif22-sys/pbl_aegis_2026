import { Head, router, useForm } from "@inertiajs/react";
import { useState, useRef, useEffect } from "react";

// ── Icons ───────────────────────────────────────────────
const Icon = {
    Dashboard: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill={c}>
            <rect x="3" y="3" width="8" height="8" rx="1.5" />
            <rect x="13" y="3" width="8" height="8" rx="1.5" />
            <rect x="3" y="13" width="8" height="8" rx="1.5" />
            <rect x="13" y="13" width="8" height="8" rx="1.5" />
        </svg>
    ),
    User: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2">
            <circle cx="12" cy="8" r="4" />
            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" />
        </svg>
    ),
    Jadwal: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2">
            <rect x="3" y="4" width="18" height="18" rx="2" />
            <path d="M16 2v4M8 2v4M3 10h18" />
        </svg>
    ),
    Checkpoint: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2">
            <path d="M12 2C8.1 2 5 5.1 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.9-3.1-7-7-7z" />
            <circle cx="12" cy="9" r="2.5" />
        </svg>
    ),
    PosJaga: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2">
            <circle cx="12" cy="8" r="3" />
            <path d="M6 21v-1a6 6 0 0 1 12 0v1" />
            <path d="M3 11l9-9 9 9" />
        </svg>
    ),
    Rute: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2">
            <circle cx="5" cy="6" r="2" />
            <circle cx="19" cy="6" r="2" />
            <circle cx="12" cy="18" r="2" />
            <path d="M7 6h10M19 8l-7 8M5 8l7 8" />
        </svg>
    ),
    BukuTamu: (c) => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2">
            <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
            <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
        </svg>
    ),
    Logout: () => (
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#c0392b" strokeWidth="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
        </svg>
    ),
    Send: () => (
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
            <line x1="22" y1="2" x2="11" y2="13" />
            <polygon points="22 2 15 22 11 13 2 9 22 2" />
        </svg>
    ),
};

// ── Logo AEGIS ──────────────────────────────────────────
function AegisLogo({ size = 38 }) {
    return (
        <svg width={size} height={size} viewBox="0 0 40 46" fill="none">
            <defs>
                <linearGradient id="shGrad" x1="20" y1="3" x2="20" y2="44" gradientUnits="userSpaceOnUse">
                    <stop offset="0%" stopColor="#1e80d8" />
                    <stop offset="100%" stopColor="#003d7a" />
                </linearGradient>
            </defs>
            <path d="M20 3L5 9v13c0 9.8 7 19 15 21.5C28 40 35 30.8 35 22V9L20 3z" fill="url(#shGrad)" />
            <path
                d="M20 8L9 13v10c0 6.5 4.8 12.8 11 14.8C27.2 35.8 31 29.5 31 23V13L20 8z"
                fill="none" stroke="white" strokeOpacity="0.25" strokeWidth="1"
            />
            <text x="20" y="30" textAnchor="middle" fill="white"
                fontSize="17" fontWeight="bold" fontFamily="Georgia, serif">A</text>
        </svg>
    );
}

const menuItems = [
    { label: "Dashboard",        icon: Icon.Dashboard },
    { label: "Manajemen User",   icon: Icon.User },
    { label: "Manajemen Jadwal", icon: Icon.Jadwal },
    { label: "Checkpoint",       icon: Icon.Checkpoint },
    { label: "Pos Jaga",         icon: Icon.PosJaga },
    { label: "Rute Jaga",        icon: Icon.Rute },
    { label: "Buku Tamu",        icon: Icon.BukuTamu },
];

function formatWaktu(waktu) {
    if (!waktu) return "-";
    const d = new Date(waktu);
    return d.toLocaleString("id-ID", {
        day: "2-digit", month: "short", year: "numeric",
        hour: "2-digit", minute: "2-digit",
    });
}

// Format waktu pesan: "hari ini 14:30" / "kemarin 09:15" / "12 Jan 14:30"
function formatWaktuPesan(waktu) {
    if (!waktu) return "-";
    // waktu dari controller sudah diformat, tapi kita butuh object Date
    // Controller sekarang mengirim ISO string di field waktu_kirim_iso
    // Jika tidak ada, fallback ke string waktu apa adanya
    if (typeof waktu === "string" && waktu.includes("T")) {
        const d = new Date(waktu);
        const now = new Date();
        const isHariIni =
            d.getDate() === now.getDate() &&
            d.getMonth() === now.getMonth() &&
            d.getFullYear() === now.getFullYear();
        const kemarin = new Date(now);
        kemarin.setDate(now.getDate() - 1);
        const isKemarin =
            d.getDate() === kemarin.getDate() &&
            d.getMonth() === kemarin.getMonth() &&
            d.getFullYear() === kemarin.getFullYear();

        const jam = d.toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" });
        if (isHariIni)   return `Hari ini, ${jam}`;
        if (isKemarin)   return `Kemarin, ${jam}`;
        return d.toLocaleString("id-ID", {
            day: "2-digit", month: "short", year: "numeric",
            hour: "2-digit", minute: "2-digit",
        });
    }
    // Fallback: tampilkan apa adanya (sudah diformat H:i oleh controller lama)
    return waktu;
}

// ── Badge role berwarna ──────────────────────────────────
function RoleBadge({ role }) {
    const map = {
        admin:      { bg: "#dbeafe", color: "#1d4ed8" },
        petugas:    { bg: "#dcfce7", color: "#15803d" },
        supervisor: { bg: "#fef9c3", color: "#a16207" },
        warga:      { bg: "#e0f2fe", color: "#0369a1" },
    };
    const s = map[role] ?? { bg: "#f1f5f9", color: "#475569" };
    return (
        <span
            className="text-[9px] font-semibold px-1.5 py-0.5 rounded-full"
            style={{ background: s.bg, color: s.color }}
        >
            {role}
        </span>
    );
}

// ── Gelembung pesan ──────────────────────────────────────
function LogBubble({ log, isMe }) {
    // Gunakan waktu_iso (ISO string) jika ada, fallback ke waktu (string H:i)
    const waktuTampil = formatWaktuPesan(log.waktu_iso ?? log.waktu);

    return (
        <div className={`flex flex-col ${isMe ? "items-end" : "items-start"}`}>
            {!isMe && (
                <div className="flex items-center gap-1 mb-0.5">
                    <span className="text-xs font-semibold" style={{ color: "#005EA4" }}>
                        {log.pengirim}
                    </span>
                    {log.role && <RoleBadge role={log.role} />}
                </div>
            )}
            <div
                className="px-3 py-1.5 text-xs max-w-[90%] leading-relaxed"
                style={{
                    background: isMe ? "#0F2A44" : "#f1f5f9",
                    color: isMe ? "white" : "#0F2A44",
                    borderRadius: isMe ? "12px 12px 2px 12px" : "12px 12px 12px 2px",
                }}
            >
                {log.pesan}
            </div>
            {/* Waktu lengkap: tanggal + jam */}
            <span className="text-[10px] mt-0.5" style={{ color: "#94a3b8" }}>
                {waktuTampil}
            </span>
        </div>
    );
}

// ── Main Dashboard ───────────────────────────────────────
export default function Dashboard({ stats, buku_tamu, rute_patroli, informasi, auth }) {
    const [activeMenu, setActiveMenu] = useState("Dashboard");
    const logEndRef = useRef(null);

    const currentUserId = auth?.user?.id;

    const { data, setData, post, processing, reset, errors } = useForm({ pesan: "" });

    useEffect(() => {
        logEndRef.current?.scrollIntoView({ behavior: "smooth" });
    }, [informasi]);

    const handleLogout = () => router.post(route("logout"));

    const handleKirim = (e) => {
        e.preventDefault();
        if (!data.pesan.trim() || processing) return;
        post(route("admin.informasi.kirim"), {
            preserveScroll: true,
            preserveState: false,
            onSuccess: () => reset("pesan"),
        });
    };

    const statCards = [
        {
            label: "Petugas", value: stats.petugas, blue: true,
            icon: <svg width="34" height="34" viewBox="0 0 24 24" fill="white"><circle cx="12" cy="7" r="4"/><path d="M4 20c0-3.8 3.6-7 8-7s8 3.2 8 7"/></svg>,
        },
        {
            label: "Warga", value: stats.warga, blue: false,
            icon: <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="1.8"><circle cx="9" cy="7" r="3.5"/><circle cx="16" cy="7" r="3.5"/><path d="M9 14c1.8-.8 4.2-.8 6 0 2.2.9 4 3.1 4 6H5c0-2.9 1.8-5.1 4-6z"/></svg>,
        },
        {
            label: "Supervisor", value: stats.supervisor, blue: true,
            icon: <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/><path d="M17 3.5C18.5 4.5 19 6 19 7" strokeDasharray="2 1.5"/></svg>,
        },
    ];

    return (
        <>
            <Head title="Dashboard" />

            <div className="flex h-screen overflow-hidden" style={{ background: "#E7F8FF" }}>

                {/* ── SIDEBAR ── */}
                <aside
                    className="w-56 flex flex-col justify-between py-5 px-3 shrink-0"
                    style={{ background: "#E7F8FF", borderRight: "1px solid #b8dff0" }}
                >
                    <div>
                        <div className="flex items-center gap-2.5 mb-7 px-2">
                            <AegisLogo size={38} />
                            <span className="text-xl font-bold tracking-[0.18em]" style={{ color: "#0F2A44" }}>
                                AEGIS
                            </span>
                        </div>
                        <nav className="flex flex-col gap-0.5">
                            {menuItems.map(({ label, icon }) => {
                                const isActive = activeMenu === label;
                                return (
                                    <button
                                        key={label}
                                        onClick={() => setActiveMenu(label)}
                                        className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-left transition-all w-full"
                                        style={{
                                            background: isActive ? "#0F2A44" : "transparent",
                                            color:      isActive ? "white" : "#334155",
                                            fontWeight: isActive ? 600 : 400,
                                        }}
                                    >
                                        {icon(isActive ? "white" : "#005EA4")}
                                        <span>{label}</span>
                                    </button>
                                );
                            })}
                        </nav>
                    </div>
                    <button
                        onClick={handleLogout}
                        className="flex items-center gap-2 mx-1 px-3 py-2.5 rounded-lg text-sm font-medium"
                        style={{ background: "#fde8e8", color: "#c0392b" }}
                    >
                        <Icon.Logout />
                        Keluar
                    </button>
                </aside>

                {/* ── MAIN ── */}
                <div className="flex-1 flex flex-col overflow-hidden">

                    {/* Topbar */}
                    <header className="px-6 py-3 flex justify-end items-center gap-3 shrink-0" style={{ background: "#0F2A44" }}>
                        <div className="text-right">
                            <p className="text-sm font-semibold text-white leading-tight">{auth.user?.nama ?? "Admin"}</p>
                            <p className="text-xs capitalize" style={{ color: "#90c4e8" }}>{auth.user?.role ?? "admin"}</p>
                        </div>
                        <div
                            className="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold text-white border-2"
                            style={{ background: "#005EA4", borderColor: "#3b9ede" }}
                        >
                            {auth.user?.nama?.[0] ?? "A"}
                        </div>
                    </header>

                    {/* Content */}
                    <main className="flex-1 overflow-hidden p-5 flex flex-col">
                        <h1 className="text-xl font-bold mb-4 shrink-0" style={{ color: "#0F2A44" }}>
                            Halo, {auth.user?.nama ?? "Admin"}!
                        </h1>

                        <div className="grid grid-cols-3 gap-4 items-stretch flex-1 min-h-0">

                            {/* ── KOLOM KIRI ── */}
                            <div className="col-span-2 flex flex-col gap-4 min-h-0">

                                {/* Stat Cards */}
                                <div className="grid grid-cols-3 gap-4 shrink-0">
                                    {statCards.map((card) => (
                                        <div
                                            key={card.label}
                                            className="rounded-xl px-4 py-3 flex items-center gap-3 shadow-sm hover:shadow-md transition-all"
                                            style={{
                                                background: card.blue ? "#005EA4" : "white",
                                                color:      card.blue ? "white" : "#0F2A44",
                                                border:     card.blue ? "none" : "1.5px solid #c7e8f8",
                                            }}
                                        >
                                            <div className="shrink-0">{card.icon}</div>
                                            <div>
                                                <p className="text-xs font-medium opacity-80">{card.label}</p>
                                                <p className="text-lg font-bold">{card.value}</p>
                                            </div>
                                        </div>
                                    ))}
                                </div>

                                {/* Buku Tamu */}
                                <div
                                    className="rounded-2xl overflow-hidden shadow-sm flex flex-col flex-1 min-h-0"
                                    style={{ background: "white", border: "1.5px solid #c7e8f8" }}
                                >
                                    <div className="px-4 py-3 border-b shrink-0" style={{ borderColor: "#e0f2fe" }}>
                                        <h2 className="font-semibold text-sm" style={{ color: "#0F2A44" }}>Buku Tamu</h2>
                                    </div>
                                    <div className="overflow-y-auto flex-1">
                                        <table className="w-full text-sm" style={{ tableLayout: "fixed" }}>
                                            <thead className="sticky top-0 z-10">
                                                <tr style={{ background: "#005EA4", color: "white" }}>
                                                    <th className="px-3 py-2.5 text-center font-semibold">Nama</th>
                                                    <th className="px-3 py-2.5 text-center font-semibold">Alamat</th>
                                                    <th className="px-3 py-2.5 text-center font-semibold">Keperluan</th>
                                                    <th className="px-3 py-2.5 text-center font-semibold">Waktu Masuk</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {buku_tamu.length === 0 ? (
                                                    <tr>
                                                        <td colSpan={4} className="px-4 py-6 text-center text-gray-400">
                                                            Tidak ada data
                                                        </td>
                                                    </tr>
                                                ) : (
                                                    buku_tamu.map((tamu, i) => (
                                                        <tr
                                                            key={tamu.id}
                                                            style={{
                                                                background: i % 2 === 1 ? "#dbeeff" : "white",
                                                                color: "#0F2A44",
                                                            }}
                                                        >
                                                            <td className="px-3 py-2.5 text-center font-medium">{tamu.nama}</td>
                                                            <td className="px-3 py-2.5 text-center">{tamu.alamat}</td>
                                                            <td className="px-3 py-2.5 text-center">{tamu.keperluan}</td>
                                                            <td className="px-3 py-2.5 text-center text-xs" style={{ color: "#475569" }}>
                                                                {formatWaktu(tamu.waktu_masuk)}
                                                            </td>
                                                        </tr>
                                                    ))
                                                )}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                            </div>

                            {/* ── KOLOM KANAN ── */}
                            <div className="col-span-1 flex flex-col gap-3 min-h-0">

                                {/* Rute Patroli */}
                                <div
                                    className="rounded-2xl p-4 shadow-sm shrink-0"
                                    style={{ background: "#005EA4", color: "white" }}
                                >
                                    <h2 className="font-semibold text-sm mb-3">Rute Patroli</h2>
                                    <div
                                        className="flex flex-col gap-2 overflow-y-auto pr-1"
                                        style={{
                                            maxHeight: "110px",
                                            scrollbarWidth: "thin",
                                            scrollbarColor: "rgba(255,255,255,0.3) transparent",
                                        }}
                                    >
                                        {rute_patroli.length === 0 ? (
                                            <p className="text-xs opacity-70 text-center py-2">Tidak ada rute</p>
                                        ) : (
                                            rute_patroli.map((rute) => (
                                                <div key={rute.id} className="rounded-xl p-2.5 shrink-0" style={{ background: "white" }}>
                                                    <p className="font-semibold text-xs" style={{ color: "#0F2A44" }}>{rute.nama}</p>
                                                    <p className="text-xs mt-0.5" style={{ color: "#64748b" }}>{rute.deskripsi}</p>
                                                </div>
                                            ))
                                        )}
                                    </div>
                                </div>

                                {/* ── Checkpoint + Pos Jaga dalam 1 card ── */}
                                <div
                                    className="rounded-2xl px-4 py-3 shadow-sm shrink-0 flex items-center gap-0"
                                    style={{ background: "white", border: "1.5px solid #c7e8f8" }}
                                >
                                    {/* Checkpoint */}
                                    <div className="flex items-center gap-3 flex-1">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="2">
                                            <path d="M12 2C8.1 2 5 5.1 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.9-3.1-7-7-7z" />
                                            <circle cx="12" cy="9" r="2.5" />
                                        </svg>
                                        <div>
                                            <p className="text-xs text-gray-400">Checkpoint</p>
                                            <p className="text-lg font-bold" style={{ color: "#0F2A44" }}>{stats.checkpoint}</p>
                                        </div>
                                    </div>

                                    {/* Divider vertikal */}
                                    <div className="w-px self-stretch mx-2" style={{ background: "#e0f2fe" }} />

                                    {/* Pos Jaga */}
                                    <div className="flex items-center gap-3 flex-1">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="2">
                                            <circle cx="12" cy="8" r="3" />
                                            <path d="M6 21v-1a6 6 0 0 1 12 0v1" />
                                            <path d="M3 11l9-9 9 9" />
                                        </svg>
                                        <div>
                                            <p className="text-xs text-gray-400">Pos Jaga</p>
                                            <p className="text-lg font-bold" style={{ color: "#0F2A44" }}>{stats.pos_jaga}</p>
                                        </div>
                                    </div>
                                </div>

                                {/* ── LOG INFORMASI — flex-1 agar mengisi sisa tinggi ── */}
                                <div
                                    className="rounded-2xl overflow-hidden shadow-sm flex flex-col flex-1 min-h-0"
                                    style={{ background: "white", border: "1.5px solid #c7e8f8" }}
                                >
                                    {/* Header */}
                                    <div
                                        className="px-3 py-2.5 shrink-0 flex items-center gap-2"
                                        style={{ background: "#0F2A44" }}
                                    >
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#90c4e8" strokeWidth="2">
                                            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                                        </svg>
                                        <h2 className="font-semibold text-xs text-white tracking-wide">LOG INFORMASI</h2>
                                        <span
                                            className="ml-auto text-xs px-1.5 py-0.5 rounded-full"
                                            style={{ background: "#005EA4", color: "white" }}
                                        >
                                            {informasi.length}
                                        </span>
                                    </div>

                                    {/* Daftar pesan */}
                                    <div
                                        className="flex-1 overflow-y-auto p-3 flex flex-col gap-2 min-h-0"
                                        style={{ scrollbarWidth: "thin", scrollbarColor: "#b8dff0 transparent" }}
                                    >
                                        {informasi.length === 0 ? (
                                            <p className="text-xs text-center text-gray-400 mt-4">
                                                Belum ada informasi.
                                            </p>
                                        ) : (
                                            informasi.map((log) => (
                                                <LogBubble
                                                    key={log.id}
                                                    log={log}
                                                    isMe={log.id_pengirim === currentUserId}
                                                />
                                            ))
                                        )}
                                        <div ref={logEndRef} />
                                    </div>

                                    {/* Form kirim */}
                                    <form
                                        onSubmit={handleKirim}
                                        className="flex flex-col gap-1 px-3 py-2 shrink-0"
                                        style={{ borderTop: "1px solid #e0f2fe" }}
                                    >
                                        <div className="flex items-center gap-2">
                                            <input
                                                type="text"
                                                value={data.pesan}
                                                onChange={(e) => setData("pesan", e.target.value)}
                                                onKeyDown={(e) => {
                                                    if (e.key === "Enter") {
                                                        e.preventDefault();
                                                        handleKirim(e);
                                                    }
                                                }}
                                                placeholder="Ketik pesan..."
                                                disabled={processing}
                                                className="flex-1 text-xs rounded-lg px-3 py-2 outline-none disabled:opacity-60"
                                                style={{
                                                    background: "#f1f5f9",
                                                    border: errors.pesan ? "1px solid #ef4444" : "1px solid #c7e8f8",
                                                    color: "#0F2A44",
                                                }}
                                            />
                                            <button
                                                type="submit"
                                                disabled={processing || !data.pesan.trim()}
                                                className="rounded-lg p-2 shrink-0 transition-opacity hover:opacity-80 disabled:opacity-40 disabled:cursor-not-allowed"
                                                style={{ background: "#005EA4" }}
                                            >
                                                {processing
                                                    ? <span className="block w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                                                    : <Icon.Send />
                                                }
                                            </button>
                                        </div>
                                        {errors.pesan && (
                                            <p className="text-[10px] text-red-500 px-1">{errors.pesan}</p>
                                        )}
                                    </form>
                                </div>

                            </div>
                        </div>
                    </main>
                </div>
            </div>
        </>
    );
}