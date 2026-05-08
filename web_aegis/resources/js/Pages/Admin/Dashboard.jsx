// resources/js/Pages/Admin/Dashboard.jsx
import { Head, useForm } from "@inertiajs/react";
import { useEffect, useRef } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPersonMilitaryPointing, faPeopleRoof, faUserTie } from "@fortawesome/free-solid-svg-icons";

import AdminLayout   from "@/Layouts/AdminLayout";
import { StatCard }  from "@/Components/Admin/StatCard";
import { LogBubble } from "@/Components/Admin/LogBubble";
import { Icon }      from "@/Components/Admin/Icons";
import { formatWaktu } from "@/utils/dateHelpers";

export default function Dashboard({ stats, buku_tamu, rute_patroli, informasi, auth, unread_count }) {
    const logEndRef    = useRef(null);
    const currentUserId = auth?.user?.id;
    const { data, setData, post, processing, reset, errors } = useForm({ pesan: "" });

    useEffect(() => {
        logEndRef.current?.scrollIntoView({ behavior: "smooth" });
    }, [informasi]);

    const handleKirim = (e) => {
        e.preventDefault();
        if (!data.pesan.trim() || processing) return;
        post(route("admin.informasi.kirim"), {
            preserveScroll:  true,
            preserveState:   false,
            onSuccess:       () => reset("pesan"),
        });
    };

    const statCards = [
        {
            label: "Petugas",   value: stats.petugas,
            blue: true,
            icon:   <FontAwesomeIcon icon={faPersonMilitaryPointing} style={{ fontSize: 28, color: "white" }} />,
            accent: "#fbbf24",
        },
        {
            label: "Warga",     value: stats.warga,
            blue: false,
            icon:   <FontAwesomeIcon icon={faPeopleRoof} style={{ fontSize: 28, color: "#005EA4" }} />,
            accent: "#005EA4",
        },
        {
            label: "Supervisor", value: stats.supervisor,
            blue: true,
            icon:   <FontAwesomeIcon icon={faUserTie} style={{ fontSize: 28, color: "white" }} />,
            accent: "#34d399",
        },
    ];

    return (
        <>
            <Head title="Dashboard" />
            <AdminLayout
                auth={auth}
                activeMenu="Dashboard"
                title={`Halo, ${auth.user?.nama ?? "Admin"}`}
            >
                <div className="grid grid-cols-3 gap-4 items-stretch flex-1 min-h-0">

                    {/* ── LEFT COLUMN ── */}
                    <div className="col-span-2 flex flex-col gap-4 min-h-0">

                        {/* Stat Cards */}
                        <div className="grid grid-cols-3 gap-4 shrink-0">
                            {statCards.map((c) => <StatCard key={c.label} {...c} />)}
                        </div>

                        {/* Buku Tamu */}
                        <div
                            className="rounded-2xl overflow-hidden shadow-sm"
                            style={{ background: "white", border: "1.5px solid #c7e8f8" }}
                        >
                            <div
                                className="px-4 py-3 border-b flex items-center gap-2"
                                style={{ borderColor: "#e0f2fe" }}
                            >
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="2">
                                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
                                </svg>
                                <h2 className="font-semibold text-sm" style={{ color: "#0F2A44" }}>Buku Tamu</h2>
                            </div>
                            <table className="w-full text-sm" style={{ tableLayout: "fixed" }}>
                                <thead>
                                    <tr style={{ background: "#005EA4", color: "white" }}>
                                        {["Nama", "Alamat", "Keperluan", "Waktu Masuk"].map((h) => (
                                            <th key={h} className="px-3 py-2.5 text-center font-semibold">{h}</th>
                                        ))}
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

                    {/* ── RIGHT COLUMN ── */}
                    <div className="col-span-1 flex flex-col gap-3 min-h-0">

                        {/* Rute Patroli */}
                        <div
                            className="rounded-2xl p-4 shadow-sm shrink-0"
                            style={{ background: "#005EA4", color: "white" }}
                        >
                            <h2 className="font-semibold text-sm mb-3">Rute Patroli</h2>
                            <div
                                className="flex flex-col gap-2 overflow-y-auto pr-1"
                                style={{ maxHeight: "110px", scrollbarWidth: "thin", scrollbarColor: "rgba(255,255,255,0.3) transparent" }}
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

                        {/* Checkpoint + Pos Jaga */}
                        <div
                            className="rounded-2xl px-4 py-3 shadow-sm shrink-0 flex items-center"
                            style={{ background: "white", border: "1.5px solid #c7e8f8" }}
                        >
                            {[
                                {
                                    label: "Checkpoint", value: stats.checkpoint,
                                    svgPath: <>
                                        <path d="M12 2C8.1 2 5 5.1 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.9-3.1-7-7-7z" />
                                        <circle cx="12" cy="9" r="2.5" />
                                    </>,
                                },
                                {
                                    label: "Pos Jaga", value: stats.pos_jaga,
                                    svgPath: <>
                                        <circle cx="12" cy="8" r="3" />
                                        <path d="M6 21v-1a6 6 0 0 1 12 0v1" />
                                        <path d="M3 11l9-9 9 9" />
                                    </>,
                                },
                            ].map(({ label, value, svgPath }, idx) => (
                                <>
                                    {idx > 0 && <div key="sep" className="w-px self-stretch mx-2" style={{ background: "#e0f2fe" }} />}
                                    <div key={label} className="flex items-center gap-3 flex-1">
                                        <div className="w-9 h-9 rounded-xl flex items-center justify-center shrink-0"
                                            style={{ background: "#e0f2fe" }}>
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#005EA4" strokeWidth="2">
                                                {svgPath}
                                            </svg>
                                        </div>
                                        <div>
                                            <p className="text-xs text-gray-400">{label}</p>
                                            <p className="text-xl font-bold" style={{ color: "#0F2A44" }}>{value}</p>
                                        </div>
                                    </div>
                                </>
                            ))}
                        </div>

                        {/* Log Informasi */}
                        <div
                            className="rounded-2xl overflow-hidden shadow-sm flex flex-col flex-1 min-h-0"
                            style={{ background: "white", border: "1.5px solid #c7e8f8" }}
                        >
                            {/* Log header */}
                            <div
                                className="px-3 py-2.5 shrink-0 flex items-center gap-2"
                                style={{ background: "#0F2A44" }}
                            >
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#90c4e8" strokeWidth="2">
                                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                                </svg>
                                <h2 className="font-semibold text-xs text-white tracking-wide">LOG INFORMASI</h2>
                                {unread_count > 0 && (
                                    <span
                                        className="ml-auto text-xs px-2 py-0.5 rounded-full font-semibold animate-pulse"
                                        style={{ background: "#ef4444", color: "white" }}
                                    >
                                        {unread_count} belum terbaca
                                    </span>
                                )}
                            </div>

                            {/* Messages */}
                            <div
                                className="flex-1 overflow-y-auto p-3 flex flex-col gap-2 min-h-0"
                                style={{ scrollbarWidth: "thin", scrollbarColor: "#b8dff0 transparent" }}
                            >
                                {informasi.length === 0 ? (
                                    <p className="text-xs text-center text-gray-400 mt-4">Belum ada informasi.</p>
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

                            {/* Input */}
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
                                        onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); handleKirim(e); } }}
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
                                        className="rounded-lg p-2 shrink-0 hover:opacity-80 disabled:opacity-40 disabled:cursor-not-allowed"
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
            </AdminLayout>
        </>
    );
}