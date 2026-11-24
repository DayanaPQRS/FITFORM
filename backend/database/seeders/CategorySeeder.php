<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Upper Body',
                'slug' => 'upper-body',
                'description' => 'Latihan fokus pada otot tubuh bagian atas seperti lengan, dada, dan trisep.',
                'icon' => 'fitness_center',
                'is_active' => true,
            ],
            [
                'name' => 'Shoulders',
                'slug' => 'shoulders',
                'description' => 'Latihan penguatan dan pembentukan otot bahu serta deltoid.',
                'icon' => 'accessibility_new',
                'is_active' => true,
            ],
            [
                'name' => 'Lower Body',
                'slug' => 'lower-body',
                'description' => 'Latihan fokus pada otot paha, hamstring, betis, dan gluteal tubuh bagian bawah.',
                'icon' => 'directions_run',
                'is_active' => true,
            ],
            [
                'name' => 'Core & Abs',
                'slug' => 'core-abs',
                'description' => 'Latihan penguatan otot inti, perut, dan stabilitas postur tubuh.',
                'icon' => 'sports_gymnastics',
                'is_active' => true,
            ],
        ];

        foreach ($categories as $cat) {
            Category::updateOrCreate(
                ['slug' => $cat['slug']],
                $cat
            );
        }
    }
}
