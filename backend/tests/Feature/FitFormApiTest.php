<?php

namespace Tests\Feature;

use App\Models\Device;
use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FitFormApiTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private User $admin;
    private Exercise $exercise;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::create([
            'name' => 'Athlete User',
            'email' => 'athlete@fitform.com',
            'password' => bcrypt('password123'),
            'role' => 'user',
            'weight_kg' => 70.0,
            'height_cm' => 175.0,
        ]);

        $this->admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@fitform.com',
            'password' => bcrypt('password123'),
            'role' => 'admin',
        ]);

        $this->exercise = Exercise::create([
            'name' => 'Bicep Curl',
            'description' => 'Standard dumbbell curl',
            'target_muscle' => 'Biceps Brachii',
            'min_elbow_angle' => 40.0,
            'max_elbow_angle' => 160.0,
            'max_torso_sway_angle' => 15.0,
            'is_active' => true,
        ]);
    }

    public function test_can_retrieve_active_exercises(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/exercises');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'data' => [
                    '*' => ['id', 'name', 'target_muscle', 'min_elbow_angle', 'max_elbow_angle'],
                ],
            ]);
    }

    public function test_admin_can_create_exercise_and_non_admin_is_forbidden(): void
    {
        // Non-admin forbidden
        $response = $this->actingAs($this->user)
            ->postJson('/api/exercises', [
                'name' => 'Hammer Curl',
                'target_muscle' => 'Brachialis',
            ]);
        $response->assertStatus(403);

        // Admin can create
        $responseAdmin = $this->actingAs($this->admin)
            ->postJson('/api/exercises', [
                'name' => 'Hammer Curl',
                'target_muscle' => 'Brachialis',
                'min_elbow_angle' => 45.0,
                'max_elbow_angle' => 150.0,
                'max_torso_sway_angle' => 10.0,
            ]);
        $responseAdmin->assertStatus(201)
            ->assertJsonPath('data.name', 'Hammer Curl');
    }

    public function test_can_update_user_physical_profile(): void
    {
        $response = $this->actingAs($this->user)
            ->putJson('/api/user/profile', [
                'height_cm' => 180.5,
                'weight_kg' => 75.2,
                'gender' => 'male',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('user.height_cm', 180.5)
            ->assertJsonPath('user.weight_kg', 75.2)
            ->assertJsonPath('user.gender', 'male');

        $this->assertDatabaseHas('users', [
            'id' => $this->user->id,
            'weight_kg' => 75.2,
        ]);
    }

    public function test_can_pair_and_unpair_device(): void
    {
        // Pair device
        $response = $this->actingAs($this->user)
            ->postJson('/api/devices', [
                'mac_address' => 'AA:BB:CC:DD:EE:01',
                'device_code' => 'DUMBBELL-TEST-01',
                'firmware_version' => '1.0.0',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.mac_address', 'AA:BB:CC:DD:EE:01')
            ->assertJsonPath('data.status', 'active');

        $deviceId = $response->json('data.id');

        // Unpair device
        $deleteResponse = $this->actingAs($this->user)
            ->deleteJson("/api/devices/{$deviceId}");

        $deleteResponse->assertStatus(200);

        $this->assertDatabaseHas('devices', [
            'id' => $deviceId,
            'user_id' => null,
            'status' => 'inactive',
        ]);
    }

    public function test_can_submit_workout_session_with_data_processing(): void
    {
        $payload = [
            'exercise_id' => $this->exercise->id,
            'started_at' => now()->subMinutes(10)->toIso8601String(),
            'ended_at' => now()->toIso8601String(),
            'duration_seconds' => 600, // 10 minutes
            'notes' => 'Evening dumbbell set',
            'repetitions' => [
                [
                    'rep_number' => 1,
                    'is_valid' => true,
                    'imu_confidence_score' => 0.95,
                    'pose_confidence_score' => 0.92,
                    'duration_seconds' => 2.4,
                    'peak_joint_angle' => 145.0,
                    'body_sway_angle' => 4.2,
                ],
                [
                    'rep_number' => 2,
                    'is_valid' => true,
                    'imu_confidence_score' => 0.93,
                    'pose_confidence_score' => 0.91,
                    'duration_seconds' => 2.3,
                    'peak_joint_angle' => 143.5,
                    'body_sway_angle' => 5.1,
                ],
                [
                    'rep_number' => 3,
                    'is_valid' => false,
                    'anomaly_reason' => 'Torso swinging detected',
                    'imu_confidence_score' => 0.88,
                    'pose_confidence_score' => 0.85,
                    'duration_seconds' => 2.0,
                    'peak_joint_angle' => 130.0,
                    'body_sway_angle' => 18.5,
                ],
                [
                    'rep_number' => 4,
                    'is_valid' => true,
                    'imu_confidence_score' => 0.94,
                    'pose_confidence_score' => 0.93,
                    'duration_seconds' => 2.5,
                    'peak_joint_angle' => 146.0,
                    'body_sway_angle' => 4.8,
                ],
            ],
        ];

        $response = $this->actingAs($this->user)
            ->postJson('/api/workout-sessions', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('data.total_reps_valid', 3)
            ->assertJsonPath('data.total_reps_anomaly', 1)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'calories_burned',
                    'repetitions' => [
                        '*' => ['id', 'rep_number', 'is_valid', 'peak_joint_angle'],
                    ],
                ],
            ]);

        $this->assertEquals(75.0, (float) $response->json('data.form_accuracy_percentage'));

        // Verify calculations: Calories burned should be > 0
        $this->assertGreaterThan(0, $response->json('data.calories_burned'));
    }

    public function test_can_calculate_aggregate_workout_statistics(): void
    {
        // Create 2 workout sessions directly
        WorkoutSession::create([
            'user_id' => $this->user->id,
            'exercise_id' => $this->exercise->id,
            'started_at' => now()->subDay(),
            'ended_at' => now()->subDay()->addMinutes(15),
            'duration_seconds' => 900,
            'total_reps_valid' => 18,
            'total_reps_anomaly' => 2,
            'form_accuracy_percentage' => 90.0,
            'calories_burned' => 55.5,
        ]);

        WorkoutSession::create([
            'user_id' => $this->user->id,
            'exercise_id' => $this->exercise->id,
            'started_at' => now(),
            'ended_at' => now()->addMinutes(10),
            'duration_seconds' => 600,
            'total_reps_valid' => 10,
            'total_reps_anomaly' => 0,
            'form_accuracy_percentage' => 100.0,
            'calories_burned' => 37.0,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/workout-sessions/statistics');

        $response->assertStatus(200)
            ->assertJsonPath('data.total_sessions', 2)
            ->assertJsonPath('data.total_duration_seconds', 1500)
            ->assertJsonPath('data.total_reps_valid', 28)
            ->assertJsonPath('data.total_reps_anomaly', 2);

        $this->assertEquals(95.0, (float) $response->json('data.average_accuracy_percentage'));
        $this->assertEquals(92.5, (float) $response->json('data.total_calories_burned'));
    }
}
