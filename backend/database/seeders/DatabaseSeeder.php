<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Default Admin account
        User::updateOrCreate(
            ['email' => 'admin@fitform.com'],
            [
                'name' => 'FitForm Admin',
                'password' => Hash::make('password123'),
                'role' => 'admin',
            ]
        );

        // Default Demo User account
        User::updateOrCreate(
            ['email' => 'user@fitform.com'],
            [
                'name' => 'John Doe',
                'password' => Hash::make('user123'),
                'role' => 'user',
                'gender' => 'male',
                'height_cm' => 175.00,
                'weight_kg' => 70.00,
            ]
        );

        // Budi Account
        User::updateOrCreate(
            ['email' => 'budi@example.com'],
            [
                'name' => 'Budi Santoso',
                'password' => Hash::make('password123'),
                'role' => 'user',
                'gender' => 'male',
                'height_cm' => 170.00,
                'weight_kg' => 68.00,
            ]
        );

        // Seed default categories & exercises
        $this->call([
            CategorySeeder::class,
            ExerciseSeeder::class,
        ]);
    }
}
