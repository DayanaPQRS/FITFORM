<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WorkoutSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'exercise_id',
        'device_id',
        'started_at',
        'ended_at',
        'duration_seconds',
        'total_reps_valid',
        'total_reps_anomaly',
        'form_accuracy_percentage',
        'calories_burned',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
            'duration_seconds' => 'integer',
            'total_reps_valid' => 'integer',
            'total_reps_anomaly' => 'integer',
            'form_accuracy_percentage' => 'float',
            'calories_burned' => 'float',
        ];
    }

    /**
     * Get the user who performed this workout session.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the exercise performed in this session.
     */
    public function exercise(): BelongsTo
    {
        return $this->belongsTo(Exercise::class);
    }

    /**
     * Get the smart device used in this session.
     */
    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }

    /**
     * Get the repetitions recorded in this session.
     */
    public function repetitions(): HasMany
    {
        return $this->hasMany(WorkoutRepetition::class, 'session_id');
    }
}
