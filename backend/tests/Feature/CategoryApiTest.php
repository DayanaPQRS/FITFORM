<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Exercise;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryApiTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private User $admin;
    private Category $category;

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

        $this->category = Category::create([
            'name' => 'Upper Body',
            'slug' => 'upper-body',
            'description' => 'Latihan bagian tubuh atas',
            'icon' => 'fitness_center',
            'is_active' => true,
        ]);

        Exercise::create([
            'category_id' => $this->category->id,
            'name' => 'Bicep Curl',
            'description' => 'Curl dumbbell latihan bisep',
            'target_muscle' => 'Biceps Brachii',
            'min_elbow_angle' => 40.0,
            'max_elbow_angle' => 160.0,
            'max_torso_sway_angle' => 15.0,
            'is_active' => true,
        ]);
    }

    public function test_unauthenticated_user_cannot_access_categories(): void
    {
        $response = $this->getJson('/api/categories');
        $response->assertStatus(401);
    }

    public function test_user_can_retrieve_active_categories(): void
    {
        // Add an inactive category
        Category::create([
            'name' => 'Draft Category',
            'slug' => 'draft-category',
            'is_active' => false,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/categories');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'data' => [
                    '*' => ['id', 'name', 'slug', 'description', 'icon', 'is_active', 'created_at'],
                ],
            ]);

        // Regular user should only see active category
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals('Upper Body', $data[0]['name']);
    }

    public function test_user_can_filter_categories_by_search(): void
    {
        Category::create([
            'name' => 'Lower Body',
            'slug' => 'lower-body',
            'description' => 'Latihan kaki dan paha',
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/categories?search=Lower');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals('Lower Body', $data[0]['name']);
    }

    public function test_user_can_retrieve_categories_with_exercises(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/categories?include_exercises=true');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'exercises' => [
                            '*' => ['id', 'name', 'target_muscle'],
                        ],
                    ],
                ],
            ]);

        $firstCat = $response->json('data.0');
        $this->assertNotEmpty($firstCat['exercises']);
        $this->assertEquals('Bicep Curl', $firstCat['exercises'][0]['name']);
    }

    public function test_user_can_retrieve_single_category_detail(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/categories/' . $this->category->id);

        $response->assertStatus(200)
            ->assertJsonPath('data.id', $this->category->id)
            ->assertJsonPath('data.name', 'Upper Body')
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'name',
                    'slug',
                    'exercises',
                ],
            ]);
    }

    public function test_returns_404_for_non_existent_category(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/categories/99999');

        $response->assertStatus(404);
    }

    public function test_non_admin_cannot_create_category(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/categories', [
                'name' => 'Core Strength',
            ]);

        $response->assertStatus(403);
    }

    public function test_admin_can_create_category_with_auto_generated_slug(): void
    {
        $response = $this->actingAs($this->admin)
            ->postJson('/api/categories', [
                'name' => 'Core & Stability',
                'description' => 'Latihan penguatan otot core',
                'icon' => 'sports_gymnastics',
                'is_active' => true,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.name', 'Core & Stability')
            ->assertJsonPath('data.slug', 'core-stability')
            ->assertJsonPath('data.is_active', true);

        $this->assertDatabaseHas('categories', [
            'name' => 'Core & Stability',
            'slug' => 'core-stability',
        ]);
    }

    public function test_create_category_validation_fails_on_duplicate_name(): void
    {
        $response = $this->actingAs($this->admin)
            ->postJson('/api/categories', [
                'name' => 'Upper Body', // Duplicate name
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name']);
    }

    public function test_non_admin_cannot_update_category(): void
    {
        $response = $this->actingAs($this->user)
            ->putJson('/api/categories/' . $this->category->id, [
                'name' => 'Updated Upper Body',
            ]);

        $response->assertStatus(403);
    }

    public function test_admin_can_update_category(): void
    {
        $response = $this->actingAs($this->admin)
            ->putJson('/api/categories/' . $this->category->id, [
                'name' => 'Upper Body & Arms',
                'description' => 'Deskripsi diperbarui',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'Upper Body & Arms')
            ->assertJsonPath('data.description', 'Deskripsi diperbarui');

        $this->assertDatabaseHas('categories', [
            'id' => $this->category->id,
            'name' => 'Upper Body & Arms',
        ]);
    }

    public function test_non_admin_cannot_delete_category(): void
    {
        $response = $this->actingAs($this->user)
            ->deleteJson('/api/categories/' . $this->category->id);

        $response->assertStatus(403);
    }

    public function test_admin_can_delete_category(): void
    {
        $response = $this->actingAs($this->admin)
            ->deleteJson('/api/categories/' . $this->category->id);

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Category deleted successfully');

        $this->assertDatabaseMissing('categories', [
            'id' => $this->category->id,
        ]);
    }
}
