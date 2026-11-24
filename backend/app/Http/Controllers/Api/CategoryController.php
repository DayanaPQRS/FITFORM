<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CategoryController extends Controller
{
    /**
     * Display a listing of categories.
     *
     * Query Parameters:
     * - search: string (search by name or description)
     * - is_active: boolean (filter by active status)
     * - include_exercises: boolean (eager load associated exercises)
     */
    public function index(Request $request): JsonResponse
    {
        $query = Category::query();

        // Non-admin users only see active categories by default unless specified
        if (!$request->user() || $request->user()->role !== 'admin') {
            $query->where('is_active', true);
        } elseif ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->query('is_active'), FILTER_VALIDATE_BOOLEAN));
        }

        // Search by name or description
        if ($request->filled('search')) {
            $searchTerm = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('name', 'like', $searchTerm)
                  ->orWhere('description', 'like', $searchTerm);
            });
        }

        // Eager load associated exercises if requested
        if (filter_var($request->query('include_exercises'), FILTER_VALIDATE_BOOLEAN)) {
            $query->with(['exercises' => function ($q) use ($request) {
                if (!$request->user() || $request->user()->role !== 'admin') {
                    $q->where('is_active', true);
                }
            }]);
        }

        $categories = $query->orderBy('name', 'asc')->get();

        return response()->json([
            'message' => 'Categories retrieved successfully',
            'data' => $categories,
        ], 200);
    }

    /**
     * Display the specified category with its exercises.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $category = Category::with(['exercises' => function ($q) use ($request) {
            if (!$request->user() || $request->user()->role !== 'admin') {
                $q->where('is_active', true);
            }
        }])->findOrFail($id);

        return response()->json([
            'message' => 'Category detail retrieved successfully',
            'data' => $category,
        ], 200);
    }

    /**
     * Store a newly created category in storage (Admin only).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name',
            'slug' => 'nullable|string|max:100|unique:categories,slug',
            'description' => 'nullable|string',
            'icon' => 'nullable|string|max:255',
            'is_active' => 'nullable|boolean',
        ]);

        if (empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $category = Category::create($validated);

        return response()->json([
            'message' => 'Category created successfully',
            'data' => $category,
        ], 201);
    }

    /**
     * Update the specified category in storage (Admin only).
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $category = Category::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:100|unique:categories,name,' . $category->id,
            'slug' => 'sometimes|nullable|string|max:100|unique:categories,slug,' . $category->id,
            'description' => 'nullable|string',
            'icon' => 'nullable|string|max:255',
            'is_active' => 'nullable|boolean',
        ]);

        if (array_key_exists('name', $validated) && empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $category->update($validated);

        return response()->json([
            'message' => 'Category updated successfully',
            'data' => $category,
        ], 200);
    }

    /**
     * Remove the specified category from storage (Admin only).
     */
    public function destroy(int $id): JsonResponse
    {
        $category = Category::findOrFail($id);
        $category->delete();

        return response()->json([
            'message' => 'Category deleted successfully',
        ], 200);
    }
}
