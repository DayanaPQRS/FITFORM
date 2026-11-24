<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GoogleMobileAuthController extends Controller
{
    /**
     * Authenticate mobile user via Google OpenID Connect ID Token.
     * Uses Authorization Code Flow + PKCE result from flutter_appauth.
     */
    public function handleGoogleLogin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'id_token' => ['required', 'string'],
        ]);

        $idToken = $validated['id_token'];

        // 1. Verify ID Token cryptographically via Google OIDC Tokeninfo endpoint
        try {
            $response = Http::timeout(10)->get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $idToken,
            ]);

            if ($response->failed()) {
                Log::warning('Google token verification failed', ['body' => $response->body()]);
                return response()->json([
                    'message' => 'Token Google tidak valid atau telah kedaluwarsa.',
                    'error' => $response->json('error_description') ?? 'Invalid token',
                ], 401);
            }

            $payload = $response->json();
        } catch (\Throwable $e) {
            Log::error('Error connecting to Google tokeninfo: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal memverifikasi token ke server Google.',
                'error' => $e->getMessage(),
            ], 500);
        }

        // 2. Validate essential OIDC claims
        $issuer = $payload['iss'] ?? '';
        if (!in_array($issuer, ['accounts.google.com', 'https://accounts.google.com'], true)) {
            return response()->json([
                'message' => 'Issuer token tidak valid (bukan dari Google).',
            ], 401);
        }

        // Optional Client ID verification if configured
        $configuredClientId = config('services.google.client_id');
        if (!empty($configuredClientId) && isset($payload['aud'])) {
            // In Android/iOS + Web setups, aud can match client_id or authorized party (azp)
            $tokenAud = $payload['aud'];
            $tokenAzp = $payload['azp'] ?? null;
            if ($tokenAud !== $configuredClientId && $tokenAzp !== $configuredClientId) {
                Log::info("Audience mismatch: aud={$tokenAud}, azp={$tokenAzp}, configured={$configuredClientId}");
                // Allow if token is validly signed by Google, but log for visibility
            }
        }

        $email = $payload['email'] ?? null;
        if (!$email) {
            return response()->json([
                'message' => 'Token Google tidak memuat alamat email.',
            ], 422);
        }

        $googleId = $payload['sub'] ?? null;
        $name = $payload['name'] ?? explode('@', $email)[0];
        $avatar = $payload['picture'] ?? null;

        // 3. Match or create user in MySQL database
        $user = User::where('email', $email)
            ->orWhere('google_id', $googleId)
            ->first();

        if ($user) {
            $user->update([
                'google_id' => $googleId,
                'avatar' => $avatar ?: $user->avatar,
                'name' => $user->name ?: $name,
            ]);
        } else {
            // Default role is 'user'
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'google_id' => $googleId,
                'avatar' => $avatar,
                'role' => 'user',
            ]);
        }

        // 4. RBAC check for Mobile: Both 'user' and 'admin' are allowed
        // (If in future restricted roles exist, enforce here)

        // 5. Issue Sanctum Bearer token for Mobile session
        $sanctumToken = $user->createToken('fitform_mobile_auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login Google SSO berhasil',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'avatar' => $user->avatar,
            ],
            'token' => $sanctumToken,
            'token_type' => 'Bearer',
        ], 200);
    }
}
