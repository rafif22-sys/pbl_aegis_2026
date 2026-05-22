import { Head, useForm } from "@inertiajs/react";

export default function Login() {
    const { data, setData, post, processing, errors } = useForm({
        email: "",
        password: "",
        remember: false,
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        post("/login"); // lebih aman daripada route()
    };

    return (
        <>
            <Head title="Login" />

            <div className="min-h-screen flex">

                {/* LEFT SIDE */}
                <div className="w-[50%] bg-[#0F2A44] text-white flex flex-col justify-center items-center px-10">
                    
                    <img
                        src="https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/logo_aegis_full.png"
                        alt="Aegis Logo"
                        className="w-64 h-auto object-contain mb-4"
                    />

                    <button
                        className="px-6 py-3 rounded text-sm leading-snug text-center"
                        style={{
                            background: "#00152A",
                            color: "rgba(245, 250, 255, 0.7)",
                        }}
                    >
                        <div>" Sistem Pelaporan Patroli Keamanan</div>
                        <div>yang Terpadu dan Responsif "</div>
                    </button>
                </div>

                {/* RIGHT SIDE */}
                <div className="w-[50%] bg-[#E7F8FF] flex items-center justify-center">
                    <div className="w-[360px]">

                        <h2 className="text-2xl font-bold mb-2 text-[#0F2A44]">
                            Selamat Datang
                        </h2>

                        <p className="text-sm text-gray-600 mb-6">
                            Silahkan Masuk Ke Pusat Komando
                        </p>

                        {errors.email && (
                            <div className="bg-red-100 text-red-600 text-sm p-2 rounded mb-3">
                                {errors.email}
                            </div>
                        )}

                        <form onSubmit={handleSubmit} className="space-y-4">

                            {/* EMAIL */}
                            <div className="space-y-1">
                                <label className="text-xs text-[#0F2A44] flex items-center gap-1">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0F2A44" strokeWidth="2">
                                        <path d="M4 4h16v16H4z" />
                                        <path d="m22 6-10 7L2 6" />
                                    </svg>
                                    EMAIL
                                </label>

                                <input
                                    type="email"
                                    placeholder="Masukkan email Anda"
                                    className="w-full p-2 rounded bg-white border border-gray-300 focus:outline-none focus:ring-2 focus:ring-[#005EA4]"
                                    value={data.email}
                                    onChange={(e) => setData("email", e.target.value)}
                                />
                            </div>

                            {/* PASSWORD */}
                            <div className="space-y-1">
                                <label className="text-xs text-[#0F2A44] flex items-center gap-1">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0F2A44" strokeWidth="2">
                                        <rect x="3" y="11" width="18" height="11" rx="2" />
                                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                    </svg>
                                    PASSWORD
                                </label>

                                <input
                                    type="password"
                                    placeholder="Masukkan password Anda"
                                    className="w-full p-2 rounded bg-white border border-gray-300 focus:outline-none focus:ring-2 focus:ring-[#005EA4]"
                                    value={data.password}
                                    onChange={(e) => setData("password", e.target.value)}
                                />
                            </div>

                            {/* REMEMBER */}
                            <div className="flex items-center text-xs text-[#0F2A44]">
                                <input
                                    type="checkbox"
                                    checked={data.remember}
                                    onChange={(e) => setData("remember", e.target.checked)}
                                    className="mr-2"
                                />
                                Ingatkan Saya
                            </div>

                            {/* BUTTON */}
                            <button
                                type="submit"
                                disabled={processing}
                                className="w-full bg-[#0F2A44] text-white py-2 rounded"
                            >
                                {processing ? "Loading..." : "Masuk →"}
                            </button>

                        </form>
                    </div>
                </div>
            </div>
        </>
    );
}