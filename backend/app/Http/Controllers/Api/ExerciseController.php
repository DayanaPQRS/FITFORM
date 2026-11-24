<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Exercise;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    /**
     * Display a listing of exercises.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Exercise::query();

        // Non-admin users only see active exercises
        if (!$request->user() || $request->user()->role !== 'admin') {
            $query->where('is_active', true);
        }

        // Filter by category_id
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->query('category_id'));
        }

        // Filter by target muscle
        if ($request->filled('target_muscle')) {
            $query->where('target_muscle', $request->query('target_muscle'));
        }

        // Search by exercise name
        if ($request->filled('search')) {
            $searchTerm = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('name', 'like', $searchTerm)
                  ->orWhere('target_muscle', 'like', $searchTerm);
            });
        }

        $exercises = $query->orderBy('name', 'asc')->get();

        return response()->json([
            'message' => 'Exercises retrieved successfully',
            'data' => $exercises,
        ], 200);
    }

    /**
     * Display the specified exercise.
     */
    public function show(int $id): JsonResponse
    {
        $exercise = Exercise::findOrFail($id);

        return response()->json([
            'message' => 'Exercise detail retrieved successfully',
            'data' => $exercise,
        ], 200);
    }

    /**
     * Store a newly created exercise (Admin only).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category_id' => 'nullable|exists:categories,id',
            'name' => 'required|string|max:100|unique:exercises,name',
            'description' => 'nullable|string',
            'target_muscle' => 'required|string|max:100',
            'min_elbow_angle' => 'nullable|numeric|between:0,180',
            'max_elbow_angle' => 'nullable|numeric|between:0,180',
            'max_torso_sway_angle' => 'nullable|numeric|between:0,90',
            'thumbnail_url' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $exercise = Exercise::create($validated);

        return response()->json([
            'message' => 'Exercise created successfully',
            'data' => $exercise->load('category'),
        ], 201);
    }

    /**
     * Update the specified exercise (Admin only).
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $exercise = Exercise::findOrFail($id);

        $validated = $request->validate([
            'category_id' => 'nullable|exists:categories,id',
            'name' => 'sometimes|string|max:100|unique:exercises,name,' . $exercise->id,
            'description' => 'nullable|string',
            'target_muscle' => 'sometimes|string|max:100',
            'min_elbow_angle' => 'nullable|numeric|between:0,180',
            'max_elbow_angle' => 'nullable|numeric|between:0,180',
            'max_torso_sway_angle' => 'nullable|numeric|between:0,90',
            'thumbnail_url' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $exercise->update($validated);

        return response()->json([
            'message' => 'Exercise updated successfully',
            'data' => $exercise->load('category'),
        ], 200);
    }

    /**
     * Remove the specified exercise (Admin only).
     */
    public function destroy(int $id): JsonResponse
    {
        $exercise = Exercise::findOrFail($id);
        $exercise->delete();

        return response()->json([
            'message' => 'Exercise deleted successfully',
        ], 200);
    }
}
