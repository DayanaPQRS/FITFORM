<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkoutRepetition extends Model
{
    use HasFactory;

    protected $fillable = [
        'session_id',
        'rep_number',
        'is_valid',
        'anomaly_reason',
        'imu_confidence_score',
        'pose_confidence_score',
        'duration_seconds',
        'peak_joint_angle',
        'body_sway_angle',
        'peak_acceleration',
    ];

    protected function casts(): array
    {
        return [
            'rep_number' => 'integer',
            'is_valid' => 'boolean',
            'imu_confidence_score' => 'float',
            'pose_confidence_score' => 'float',
            'duration_seconds' => 'float',
            'peak_joint_angle' => 'float',
            'body_sway_angle' => 'float',
            'peak_acceleration' => 'float',
        ];
    }

    /**
     * Get the session that this repetition belongs to.
     */
    public function session(): BelongsTo
    {
        return $this->belongsTo(WorkoutSession::class, 'session_id');
    }
}
