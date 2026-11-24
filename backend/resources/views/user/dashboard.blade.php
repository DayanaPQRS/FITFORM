<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitForm Web - Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen flex items-center justify-center p-4">

    <!-- Card Wrapper (Kotak, Bersih, Serasi dengan Login) -->
    <div class="w-full max-w-md bg-slate-900 border border-slate-800 rounded-lg shadow-xl p-8">
        
        <!-- Brand Logo Header -->
        <div class="mb-6 pb-5 border-b border-slate-800 flex items-center justify-between">
            <span class="text-xl font-black tracking-[0.2em] text-white uppercase select-none">
                FIT<span class="text-blue-500">FORM</span>
            </span>
        </div>

        <!-- User Profile & Welcome Greeting -->
        <div class="text-center my-4">
            <!-- User Avatar (Bersih tanpa efek neon / shape berlebih) -->
            <div class="mb-4 inline-block">
                @if ($user->avatar)
                    <img src="{{ $user->avatar }}" alt="{{ $user->name }}" class="w-20 h-20 rounded-full border border-slate-700 mx-auto object-cover">
                @else
                    <div class="w-20 h-20 rounded-full bg-slate-800 border border-slate-700 flex items-center justify-center text-2xl font-bold text-slate-300 mx-auto">
                        {{ strtoupper(substr($user->name, 0, 1)) }}
                    </div>
                @endif
            </div>

            <!-- Welcome Title -->
            <h1 class="text-xl font-bold text-white tracking-tight">Selamat Datang di FitForm</h1>
            <p class="text-sm text-slate-400 mt-1">{{ $user->name }}</p>
        </div>

        <!-- User Information (Kotak Sederhana) -->
        <div class="bg-slate-800/60 rounded border border-slate-700/80 p-4 my-6 space-y-2.5 text-sm">
            <div class="flex items-center justify-between">
                <span class="text-slate-400 text-xs">Nama</span>
                <span class="font-medium text-white">{{ $user->name }}</span>
            </div>
            <div class="flex items-center justify-between pt-2 border-t border-slate-700/60">
                <span class="text-slate-400 text-xs">Email</span>
                <span class="font-medium text-white">{{ $user->email }}</span>
            </div>
        </div>

        <!-- Logout Action (Tombol Kotak Standar) -->
        <form action="{{ route('user.logout') }}" method="POST">
            @csrf
            <button type="submit" 
                    class="w-full py-2.5 px-4 bg-red-600 hover:bg-red-500 text-white font-bold text-xs uppercase tracking-wider rounded transition">
                Keluar (Logout)
            </button>
        </form>

    </div>

</body>
</html>
