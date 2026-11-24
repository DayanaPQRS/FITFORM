<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('workout_repetitions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained('workout_sessions')->cascadeOnDelete();
            $table->unsignedInteger('rep_number');
            $table->boolean('is_valid')->default(true);
            $table->string('anomaly_reason', 150)->nullable();
            $table->decimal('imu_confidence_score', 4, 3)->nullable();
            $table->decimal('pose_confidence_score', 4, 3)->nullable();
            $table->decimal('duration_seconds', 4, 2)->nullable();
            $table->decimal('peak_joint_angle', 5, 2)->nullable();
            $table->decimal('body_sway_angle', 5, 2)->nullable();
            $table->decimal('peak_acceleration', 6, 2)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('workout_repetitions');
    }
};
