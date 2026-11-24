<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Laravel\Socialite\Facades\Socialite;
use Throwable;

class GoogleWebController extends Controller
{
    /**
     * Redirect to Google OpenID Connect / OAuth 2.0 authorization endpoint.
     * Used by FitForm Web and FitForm Mobile (Web mode).
     */
    public function redirectToGoogle(Request $request): RedirectResponse
    {
        if ($request->has('from')) {
            session([
                'oauth_from' => $request->query('from'),
                'oauth_return_to' => $request->query('return_to', 'http://localhost:5000'),
            ]);
        } else {
            session()->forget(['oauth_from', 'oauth_return_to']);
        }

        return Socialite::driver('google')
            ->scopes(['openid', 'profile', 'email'])
            ->with(['prompt' => 'select_account'])
            ->redirect();
    }

    /**
     * Handle the Google OAuth callback.
     */
    public function handleGoogleCallback(Request $request): RedirectResponse
    {
        try {
            $googleUser = Socialite::driver('google')->user();
        } catch (Throwable $e) {
            Log::error('Google OAuth callback failed: ' . $e->getMessage());
            return redirect()->route('user.login')->with('error', 'Gagal melakukan autentikasi dengan Google: ' . $e->getMessage());
        }

        $email = $googleUser->getEmail();
        $googleId = $googleUser->getId();
        $name = $googleUser->getName() ?? 'FitForm User';
        $avatar = $googleUser->getAvatar();

        // Match existing user by email or google_id
        $user = User::where('email', $email)
            ->orWhere('google_id', $googleId)
            ->first();

        if ($user) {
            $user->update([
                'google_id' => $googleId,
                'avatar' => $avatar,
                'name' => $user->name ?: $name,
            ]);
        } else {
            // New accounts created via Google default to 'user' role
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'google_id' => $googleId,
                'avatar' => $avatar,
                'role' => 'user',
            ]);
        }

        // Check if authentication originated from FitForm Mobile (Flutter Web mode)
        if (session('oauth_from') === 'mobile') {
            $returnTo = session('oauth_return_to', 'http://localhost:5000');
            session()->forget(['oauth_from', 'oauth_return_to']);

            $sanctumToken = $user->createToken('fitform_mobile_auth_token')->plainTextToken;

            $query = http_build_query([
                'token' => $sanctumToken,
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'avatar' => $user->avatar ?? '',
            ]);

            return redirect("{$returnTo}/?{$query}");
        }

        // Standard FitForm Web SSO Login
        Auth::login($user, remember: true);

        return redirect()->route('user.dashboard');
    }
}
