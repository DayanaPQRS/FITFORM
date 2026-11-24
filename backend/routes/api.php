<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DeviceController;
use App\Http\Controllers\Api\ExerciseController;
use App\Http\Controllers\Api\GoogleMobileAuthController;
use App\Http\Controllers\Api\WorkoutSessionController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - FitForm Mobile & Smart Dumbbell Ecosystem
|--------------------------------------------------------------------------
*/

// ==========================================
// 1. PUBLIC AUTHENTICATION ROUTES
// ==========================================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');
Route::post('/auth/google-sso', [GoogleMobileAuthController::class, 'handleGoogleLogin']);

// ==========================================
// 2. PROTECTED ROUTES (Laravel Sanctum Bearer Token)
// ==========================================
Route::middleware('auth:sanctum')->group(function () {

    // --- User Profile & Logout ---
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);
    Route::put('/user/change-password', [AuthController::class, 'changePassword']);
    Route::delete('/user/account', [AuthController::class, 'deleteAccount']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // --- Master Category Catalog (Read) ---
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/{id}', [CategoryController::class, 'show']);

    // --- Exercise Catalog (Read) ---
    Route::get('/exercises', [ExerciseController::class, 'index']);
    Route::get('/exercises/{id}', [ExerciseController::class, 'show']);

    // --- Smart Dumbbell Devices Management (CRUD) ---
    Route::get('/devices', [DeviceController::class, 'index']);
    Route::post('/devices', [DeviceController::class, 'store']);
    Route::get('/devices/{id}', [DeviceController::class, 'show']);
    Route::put('/devices/{id}', [DeviceController::class, 'update']);
    Route::delete('/devices/{id}', [DeviceController::class, 'destroy']);

    // --- Workout Sessions & Telemetry (CRUD + Data Processing) ---
    Route::get('/workout-sessions', [WorkoutSessionController::class, 'index']);
    Route::get('/workout-sessions/statistics', [WorkoutSessionController::class, 'statistics']);
    Route::get('/workout-sessions/{id}', [WorkoutSessionController::class, 'show']);
    Route::post('/workout-sessions', [WorkoutSessionController::class, 'store']);
    Route::delete('/workout-sessions/{id}', [WorkoutSessionController::class, 'destroy']);

    // ==========================================
    // 3. ADMIN-ONLY MANAGEMENT ROUTES
    // ==========================================
    Route::middleware('admin.api')->group(function () {
        // --- Master Category Management (Admin CRUD) ---
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{id}', [CategoryController::class, 'update']);
        Route::delete('/categories/{id}', [CategoryController::class, 'destroy']);

        // --- Exercise Management (Admin CRUD) ---
        Route::post('/exercises', [ExerciseController::class, 'store']);
        Route::put('/exercises/{id}', [ExerciseController::class, 'update']);
        Route::delete('/exercises/{id}', [ExerciseController::class, 'destroy']);
    });
});
