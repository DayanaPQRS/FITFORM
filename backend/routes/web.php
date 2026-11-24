<?php

use App\Http\Controllers\Auth\AdminAuthController;
use App\Http\Controllers\Auth\GoogleWebController;
use App\Http\Controllers\Auth\UserWebAuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes - FitForm Ecosystem
| 1. FitForm Admin (Web Admin: Email & Password only, no Google SSO, no register)
| 2. FitForm Web (Web User: Email & Password + Google SSO)
|--------------------------------------------------------------------------
*/

// Redirect root to FitForm Web login
Route::get('/', function () {
    return redirect()->route('user.login');
});

// ==========================================
// 1. FITFORM ADMIN (Web Admin)
// ==========================================
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');

    // Protected Admin Dashboard (RBAC: must be authenticated and role == admin)
    Route::middleware(['auth', 'admin'])->group(function () {
        Route::get('/dashboard', [AdminAuthController::class, 'dashboard'])->name('dashboard');
    });
});

// ==========================================
// 2. FITFORM WEB (Web User)
// ==========================================
Route::name('user.')->group(function () {
    Route::get('/login', [UserWebAuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [UserWebAuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [UserWebAuthController::class, 'logout'])->name('logout');

    // Protected User Dashboard
    Route::middleware(['auth'])->group(function () {
        Route::get('/dashboard', [UserWebAuthController::class, 'dashboard'])->name('dashboard');
    });
});

// ==========================================
// GOOGLE SSO (OpenID Connect / OAuth 2.0)
// For FitForm Web & FitForm Mobile
// ==========================================
Route::get('/auth/google', [GoogleWebController::class, 'redirectToGoogle'])->name('auth.google');
Route::get('/auth/google/callback', [GoogleWebController::class, 'handleGoogleCallback'])->name('auth.google.callback');
