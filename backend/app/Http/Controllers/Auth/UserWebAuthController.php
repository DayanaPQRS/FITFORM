<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class UserWebAuthController extends Controller
{
    /**
     * Show the FitForm Web login page.
     * Supports Email/Password login and Google SSO.
     */
    public function showLoginForm(): View|RedirectResponse
    {
        if (Auth::check()) {
            return redirect()->route('user.dashboard');
        }

        return view('user.login');
    }

    /**
     * Process User Web login submission via Email & Password.
     */
    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ], [
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Format email tidak valid.',
            'password.required' => 'Password wajib diisi.',
        ]);

        if (!Auth::attempt($credentials, $request->boolean('remember'))) {
            return back()->withInput($request->only('email'))
                ->with('error', 'Email atau password salah.');
        }

        $request->session()->regenerate();

        return redirect()->intended(route('user.dashboard'));
    }

    /**
     * Show the FitForm Web user dashboard.
     */
    public function dashboard(): View
    {
        return view('user.dashboard', [
            'user' => Auth::user(),
        ]);
    }

    /**
     * Log out from FitForm Web.
     */
    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('user.login')->with('success', 'Anda telah berhasil logout dari FitForm Web.');
    }
}
