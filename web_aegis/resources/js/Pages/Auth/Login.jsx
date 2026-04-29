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
                <div className="w-[50%] bg-[#0F2A44] text-white flex flex-col justify-start items-center px-10 pt-20">

                    <img
                        src="https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/aegis-nobg.png"
                        alt="Aegis Logo"
                        className="w-96 h-auto object-contain mb-2"
                    />

                    <p className="text-sm text-center opacity-80 mb-6 -mt-24">
                        Advanced Emergency <br />
                        & Guard Information System
                    </p>

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
                            <div>
                                <label className="text-xs text-[#0F2A44]">EMAIL</label>
                                <input
                                    type="email"
                                    className="w-full p-2 rounded bg-white border border-gray-300"
                                    value={data.email}
                                    onChange={(e) => setData("email", e.target.value)}
                                />
                            </div>

                            {/* PASSWORD */}
                            <div>
                                <label className="text-xs text-[#0F2A44]">PASSWORD</label>
                                <input
                                    type="password"
                                    className="w-full p-2 rounded bg-white border border-gray-300"
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