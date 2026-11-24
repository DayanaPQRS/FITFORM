<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Exercise extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'name',
        'description',
        'target_muscle',
        'min_elbow_angle',
        'max_elbow_angle',
        'max_torso_sway_angle',
        'thumbnail_url',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'category_id' => 'integer',
            'min_elbow_angle' => 'float',
            'max_elbow_angle' => 'float',
            'max_torso_sway_angle' => 'float',
            'is_active' => 'boolean',
        ];
    }

    /**
     * Get the category that this exercise belongs to.
     */
    public function category(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Get the workout sessions for this exercise.
     */
    public function workoutSessions(): HasMany
    {
        return $this->hasMany(WorkoutSession::class);
    }
}
