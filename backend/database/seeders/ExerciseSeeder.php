<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Exercise;
use Illuminate\Database\Seeder;

class ExerciseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $upperBody = Category::where('slug', 'upper-body')->first();
        $shoulders = Category::where('slug', 'shoulders')->first();

        $exercises = [
            [
                'category_id' => $upperBody?->id,
                'name' => 'Bicep Curl',
                'description' => 'Gerakan fleksi siku untuk melatih otot bisep dengan menjaga postur tubuh dan siku tetap stabil.',
                'target_muscle' => 'Biceps Brachii',
                'min_elbow_angle' => 40.00,
                'max_elbow_angle' => 160.00,
                'max_torso_sway_angle' => 15.00,
                'is_active' => true,
            ],
            [
                'category_id' => $shoulders?->id,
                'name' => 'Lateral Raise',
                'description' => 'Gerakan mengangkat beban ke samping hingga setinggi bahu untuk mengisolasi otot deltoid lateral.',
                'target_muscle' => 'Lateral Deltoid',
                'min_elbow_angle' => 15.00,
                'max_elbow_angle' => 90.00,
                'max_torso_sway_angle' => 10.00,
                'is_active' => true,
            ],
            [
                'category_id' => $shoulders?->id,
                'name' => 'Shoulder Press',
                'description' => 'Gerakan mendorong beban ke atas kepala untuk melatih otot bahu dan trisep.',
                'target_muscle' => 'Anterior Deltoid & Triceps',
                'min_elbow_angle' => 70.00,
                'max_elbow_angle' => 175.00,
                'max_torso_sway_angle' => 12.00,
                'is_active' => true,
            ],
        ];

        foreach ($exercises as $exercise) {
            Exercise::updateOrCreate(
                ['name' => $exercise['name']],
                $exercise
            );
        }
    }
}
