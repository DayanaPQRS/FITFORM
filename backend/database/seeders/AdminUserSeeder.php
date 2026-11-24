<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Sets predefined Admin and demo User credentials.
     */
    public function run(): void
    {
        // 1. Predefined Administrator Account (FitForm Admin)
        $adminEmail = env('ADMIN_EMAIL', 'admin@fitform.com');
        User::updateOrCreate(
            ['email' => $adminEmail],
            [
                'name' => 'Administrator FitForm',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'google_id' => null,
            ]
        );

        // 2. Predefined Regular User Account (FitForm Web & Mobile)
        User::updateOrCreate(
            ['email' => 'user@fitform.com'],
            [
                'name' => 'User FitForm Demo',
                'password' => Hash::make('user123'),
                'role' => 'user',
            ]
        );

        // 3. User Budi (Default Testing)
        User::updateOrCreate(
            ['email' => 'budi@example.com'],
            [
                'name' => 'Budi Santoso',
                'password' => Hash::make('password123'),
                'role' => 'user',
                'gender' => 'male',
                'height_cm' => 170.0,
                'weight_kg' => 68.0,
            ]
        );

        $this->command->info("Predefined accounts seeded successfully:");
        $this->command->info("Admin: {$adminEmail} / admin123 (FitForm Admin only)");
        $this->command->info("User:  user@fitform.com / user123 (FitForm Web & Mobile)");
    }
}
