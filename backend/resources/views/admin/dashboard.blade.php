<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitForm Admin - Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-slate-900 text-slate-100 min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-lg bg-slate-800/90 border border-slate-700/80 rounded-2xl p-8 shadow-2xl backdrop-blur-sm">
        
        <!-- Header Badge -->
        <div class="flex items-center justify-between mb-6 pb-6 border-b border-slate-700/60">
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-amber-500 to-rose-500 flex items-center justify-center text-white font-bold shadow-md shadow-amber-500/20">
                    AD
                </div>
                <div>
                    <h2 class="text-lg font-bold text-white">FitForm Admin</h2>
                    <p class="text-xs text-slate-400">Portal Pengelolaan Administrator</p>
                </div>
            </div>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
                Admin Session Active
            </span>
        </div>

        <!-- Main Welcome Message -->
        <div class="text-center my-6">
            <div class="relative inline-block mb-4">
                <div class="w-20 h-20 rounded-full bg-gradient-to-tr from-amber-500 to-rose-500 border-2 border-amber-400/50 flex items-center justify-center text-2xl font-bold text-white mx-auto shadow-lg shadow-amber-500/20">
                    {{ strtoupper(substr($user->name, 0, 1)) }}
                </div>
                <span class="absolute bottom-0 right-0 w-5 h-5 bg-emerald-500 border-2 border-slate-800 rounded-full"></span>
            </div>

            <h1 class="text-2xl font-extrabold text-white tracking-tight">Selamat Datang di FitForm Admin</h1>
            <p class="text-sm text-slate-400 mt-1">Anda login dengan kredensial administrator resmi</p>
        </div>

        <!-- Administrator Info Card -->
        <div class="bg-slate-900/60 rounded-xl p-5 border border-slate-700/50 mb-8 space-y-3">
            <div class="flex items-center justify-between py-1 border-b border-slate-800/80">
                <span class="text-xs text-slate-400 font-medium">Nama Administrator</span>
                <span class="text-sm font-semibold text-slate-200">{{ $user->name }}</span>
            </div>
            <div class="flex items-center justify-between py-1 border-b border-slate-800/80">
                <span class="text-xs text-slate-400 font-medium">Email Administrator</span>
                <span class="text-sm font-semibold text-slate-200">{{ $user->email }}</span>
            </div>
            <div class="flex items-center justify-between py-1 border-b border-slate-800/80">
                <span class="text-xs text-slate-400 font-medium">Hak Akses (Role)</span>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20 uppercase tracking-wide">
                    {{ $user->role }}
                </span>
            </div>
            <div class="flex items-center justify-between py-1">
                <span class="text-xs text-slate-400 font-medium">Metode Autentikasi</span>
                <span class="text-xs font-medium text-slate-300">Email &amp; Password Terverifikasi</span>
            </div>
        </div>

        <!-- Logout Action -->
        <form action="{{ route('admin.logout') }}" method="POST">
            @csrf
            <button type="submit" 
                    class="w-full flex items-center justify-center space-x-2 px-5 py-3 bg-red-600 hover:bg-red-500 text-white font-medium rounded-xl transition duration-200 shadow-lg shadow-red-600/20 text-sm">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                <span>Keluar (Logout)</span>
            </button>
        </form>

    </div>
</body>
</html>
