<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitForm Web - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/lottie-web/5.12.2/lottie.min.js"></script>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen flex items-center justify-center p-4">

    <!-- Card Wrapper (Sesuai Referensi Gambar: Kotak, Bersih, Tanpa Shape) -->
    <div class="w-full max-w-4xl bg-slate-900 border border-slate-800 rounded-lg shadow-2xl overflow-hidden grid grid-cols-1 md:grid-cols-2">
        
        <!-- ============================================== -->
        <!-- KOLOM KIRI: FORM LOGIN (Identik Gambar)        -->
        <!-- ============================================== -->
        <div class="p-8 sm:p-10 flex flex-col justify-between bg-slate-900">
            
            <!-- Top: Brand Logo Identity -->
            <div class="mb-6">
                <span class="text-2xl font-black tracking-[0.2em] text-white uppercase select-none">
                    FIT<span class="text-blue-500">FORM</span>
                </span>
            </div>

            <!-- Flash Error Messages jika ada -->
            @if (session('error'))
                <div class="mb-4 p-3 rounded bg-red-500/10 border border-red-500/30 text-red-400 text-xs">
                    {{ session('error') }}
                </div>
            @endif

            @if (session('success'))
                <div class="mb-4 p-3 rounded bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs">
                    {{ session('success') }}
                </div>
            @endif

            <!-- Form -->
            <form action="{{ route('user.login.submit') }}" method="POST" class="space-y-4 my-auto">
                @csrf

                <!-- Input 1: Username or email -->
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                        </svg>
                    </div>
                    <input type="email" id="email" name="email" value="{{ old('email', 'user@fitform.com') }}" required autofocus
                           placeholder="Username or email"
                           class="w-full pl-10 pr-4 py-2.5 bg-slate-800 border border-slate-700 rounded text-white placeholder-slate-400 text-sm focus:outline-none focus:border-blue-500 transition">
                </div>

                <!-- Input 2: Password with Eye Toggle -->
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
                        </svg>
                    </div>
                    <input type="password" id="password" name="password" required
                           placeholder="Password"
                           class="w-full pl-10 pr-10 py-2.5 bg-slate-800 border border-slate-700 rounded text-white placeholder-slate-400 text-sm focus:outline-none focus:border-blue-500 transition">
                    <button type="button" onclick="togglePasswordVisibility()" class="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-200">
                        <svg id="eyeIcon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                        </svg>
                    </button>
                </div>

                <!-- Row: Remember Me & LOGIN Button (Sejajar Sesuai Gambar) -->
                <div class="flex items-center justify-between pt-1">
                    <label class="flex items-center space-x-2 cursor-pointer select-none">
                        <input type="checkbox" name="remember" class="w-4 h-4 rounded bg-slate-800 border-slate-700 text-blue-600 focus:ring-0">
                        <span class="text-xs text-slate-300">Remember me</span>
                    </label>

                    <button type="submit" 
                            class="px-6 py-2 bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs uppercase tracking-wider rounded transition">
                        LOGIN
                    </button>
                </div>

                <!-- Row: Register now & Forgot password? -->
                <div class="flex items-center justify-between text-xs pt-1 pb-1">
                    <span class="text-blue-400 hover:underline cursor-pointer" onclick="alert('Silakan login langsung menggunakan tombol Login with Google di bawah!')">
                        Register now
                    </span>
                    <span class="text-slate-400 hover:text-slate-300 cursor-pointer" onclick="alert('Akun demo: user@fitform.com / user123')">
                        Forgot password?
                    </span>
                </div>

                <!-- Divider "or" -->
                <div class="relative my-4 text-center">
                    <div class="absolute inset-0 flex items-center">
                        <div class="w-full border-t border-slate-800"></div>
                    </div>
                    <span class="relative px-3 bg-slate-900 text-xs text-slate-400 lowercase">
                        or
                    </span>
                </div>

                <!-- LOGIN WITH GOOGLE (Khusus Google Saja) -->
                <div>
                    <a href="{{ route('auth.google') }}" 
                       class="w-full flex items-center justify-center space-x-3 px-4 py-3 bg-[#EA4335] hover:bg-[#d93025] text-white font-bold text-xs uppercase tracking-wider rounded transition shadow-sm">
                        <!-- Google "G" Badge Icon -->
                        <div class="w-5 h-5 rounded-full bg-white flex items-center justify-center flex-shrink-0">
                            <svg class="w-3.5 h-3.5" viewBox="0 0 24 24">
                                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                            </svg>
                        </div>
                        <span>LOGIN WITH GOOGLE</span>
                    </a>
                </div>

            </form>

            <!-- Bottom minimal note -->
            <div class="mt-4 pt-3 border-t border-slate-800 text-center">
                <span class="text-[11px] text-slate-500">
                    Akun Demo: user@fitform.com / user123
                </span>
            </div>

        </div>

        <!-- ============================================== -->
        <!-- KOLOM KANAN: ANIMASI LOTTIE (Bersih, Tanpa Teks)-->
        <!-- ============================================== -->
        <div class="hidden md:flex items-center justify-center bg-slate-950/60 border-l border-slate-800 p-6">
            <div id="lottie-dumbbell" class="w-full max-w-[380px] h-[380px]"></div>
        </div>

    </div>

    <!-- Script Password Toggle & Lottie Player -->
    <script>
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.getElementById('eyeIcon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.innerHTML = `
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                `;
            } else {
                passwordInput.type = 'password';
                eyeIcon.innerHTML = `
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.6" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                `;
            }
        }

        // Render Lottie Animation
        document.addEventListener('DOMContentLoaded', function () {
            lottie.loadAnimation({
                container: document.getElementById('lottie-dumbbell'),
                renderer: 'svg',
                loop: true,
                autoplay: true,
                path: '/js/dumbbell.json'
            });
        });
    </script>
</body>
</html>
