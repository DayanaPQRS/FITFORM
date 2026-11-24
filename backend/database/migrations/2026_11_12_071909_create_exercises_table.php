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
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->string('target_muscle', 100)->nullable();
            $table->decimal('min_elbow_angle', 5, 2)->nullable();
            $table->decimal('max_elbow_angle', 5, 2)->nullable();
            $table->decimal('max_torso_sway_angle', 5, 2)->nullable();
            $table->string('thumbnail_url', 255)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
