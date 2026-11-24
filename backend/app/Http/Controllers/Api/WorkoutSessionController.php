<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WorkoutRepetition;
use App\Models\WorkoutSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WorkoutSessionController extends Controller
{
    /**
     * Display a listing of workout sessions for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $query = WorkoutSession::with(['exercise:id,name,target_muscle,thumbnail_url', 'device:id,device_code,mac_address'])
            ->where('user_id', $request->user()->id);

        // Filter by exercise
        if ($request->filled('exercise_id')) {
            $query->where('exercise_id', $request->query('exercise_id'));
        }

        // Filter by date range
        if ($request->filled('start_date')) {
            $query->whereDate('started_at', '>=', $request->query('start_date'));
        }
        if ($request->filled('end_date')) {
            $query->whereDate('started_at', '<=', $request->query('end_date'));
        }

        $sessions = $query->orderBy('started_at', 'desc')
            ->paginate($request->query('per_page', 15));

        return response()->json([
            'message' => 'Workout sessions retrieved successfully',
            'data' => $sessions,
        ], 200);
    }

    /**
     * Display the specified workout session with all its repetitions and telemetry.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $session = WorkoutSession::with([
            'exercise',
            'device',
            'repetitions' => function ($q) {
                $q->orderBy('rep_number', 'asc');
            },
        ])
        ->where('id', $id)
        ->where('user_id', $request->user()->id)
        ->firstOrFail();

        return response()->json([
            'message' => 'Workout session detail retrieved successfully',
            'data' => $session,
        ], 200);
    }

    /**
     * Store a newly completed workout session and process telemetry repetitions.
     * Includes automated data processing:
     * - Counts valid vs anomaly reps
     * - Calculates overall form accuracy percentage
     * - Estimates calories burned using MET formula and user physical profile
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'exercise_id' => 'required|exists:exercises,id',
            'device_id' => 'nullable|exists:devices,id',
            'started_at' => 'required|date',
            'ended_at' => 'nullable|date|after_or_equal:started_at',
            'duration_seconds' => 'required|integer|min:0',
            'notes' => 'nullable|string|max:500',
            'repetitions' => 'required|array|min:1',
            'repetitions.*.rep_number' => 'required|integer|min:1',
            'repetitions.*.is_valid' => 'required|boolean',
            'repetitions.*.anomaly_reason' => 'nullable|string|max:150',
            'repetitions.*.imu_confidence_score' => 'nullable|numeric|between:0,1',
            'repetitions.*.pose_confidence_score' => 'nullable|numeric|between:0,1',
            'repetitions.*.duration_seconds' => 'nullable|numeric|min:0',
            'repetitions.*.peak_joint_angle' => 'nullable|numeric',
            'repetitions.*.body_sway_angle' => 'nullable|numeric',
            'repetitions.*.peak_acceleration' => 'nullable|numeric',
        ]);

        $user = $request->user();
        $repetitionsData = $validated['repetitions'];

        // --- Data Processing & Calculation ---
        $totalReps = count($repetitionsData);
        $totalRepsValid = 0;
        $totalRepsAnomaly = 0;

        foreach ($repetitionsData as $rep) {
            if (!empty($rep['is_valid'])) {
                $totalRepsValid++;
            } else {
                $totalRepsAnomaly++;
            }
        }

        $formAccuracyPercentage = $totalReps > 0
            ? round(($totalRepsValid / $totalReps) * 100, 2)
            : 0.00;

        // Calculate estimated calories burned using MET formula (MET ~ 5.5 for dumbbell workout)
        // Formula: Calories = (MET * 3.5 * weight_in_kg / 200) * duration_in_minutes
        $weightKg = (float) ($user->weight_kg ?? 65.0); // Default to 65kg if not yet set in profile
        $durationMinutes = $validated['duration_seconds'] / 60.0;
        $caloriesBurned = round((5.5 * 3.5 * $weightKg / 200) * $durationMinutes, 2);

        // Execute storage in an atomic database transaction
        $session = DB::transaction(function () use ($user, $validated, $totalRepsValid, $totalRepsAnomaly, $formAccuracyPercentage, $caloriesBurned, $repetitionsData) {
            $session = WorkoutSession::create([
                'user_id' => $user->id,
                'exercise_id' => $validated['exercise_id'],
                'device_id' => $validated['device_id'] ?? null,
                'started_at' => $validated['started_at'],
                'ended_at' => $validated['ended_at'] ?? now(),
                'duration_seconds' => $validated['duration_seconds'],
                'total_reps_valid' => $totalRepsValid,
                'total_reps_anomaly' => $totalRepsAnomaly,
                'form_accuracy_percentage' => $formAccuracyPercentage,
                'calories_burned' => $caloriesBurned,
                'notes' => $validated['notes'] ?? null,
            ]);

            $now = now();
            $batchRepetitions = [];
            foreach ($repetitionsData as $rep) {
                $batchRepetitions[] = [
                    'session_id' => $session->id,
                    'rep_number' => $rep['rep_number'],
                    'is_valid' => (bool) $rep['is_valid'],
                    'anomaly_reason' => $rep['anomaly_reason'] ?? null,
                    'imu_confidence_score' => $rep['imu_confidence_score'] ?? null,
                    'pose_confidence_score' => $rep['pose_confidence_score'] ?? null,
                    'duration_seconds' => $rep['duration_seconds'] ?? null,
                    'peak_joint_angle' => $rep['peak_joint_angle'] ?? null,
                    'body_sway_angle' => $rep['body_sway_angle'] ?? null,
                    'peak_acceleration' => $rep['peak_acceleration'] ?? null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }

            WorkoutRepetition::insert($batchRepetitions);

            return $session;
        });

        // Load relations for response
        $session->load(['exercise', 'device', 'repetitions']);

        return response()->json([
            'message' => 'Workout session and repetition telemetry recorded successfully',
            'data' => $session,
        ], 201);
    }

    /**
     * Remove the specified workout session and associated telemetry.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $session = WorkoutSession::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $session->delete();

        return response()->json([
            'message' => 'Workout session deleted successfully',
        ], 200);
    }

    /**
     * Get aggregate workout statistics for the authenticated user's dashboard.
     */
    public function statistics(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $stats = WorkoutSession::where('user_id', $userId)
            ->selectRaw('
                COUNT(id) as total_sessions,
                COALESCE(SUM(duration_seconds), 0) as total_duration_seconds,
                COALESCE(SUM(total_reps_valid), 0) as total_reps_valid,
                COALESCE(SUM(total_reps_anomaly), 0) as total_reps_anomaly,
                COALESCE(AVG(form_accuracy_percentage), 0) as average_accuracy_percentage,
                COALESCE(SUM(calories_burned), 0) as total_calories_burned
            ')
            ->first();

        // Count sessions by exercise
        $exerciseBreakdown = WorkoutSession::where('workout_sessions.user_id', $userId)
            ->join('exercises', 'workout_sessions.exercise_id', '=', 'exercises.id')
            ->select('exercises.name as exercise_name', DB::raw('COUNT(workout_sessions.id) as session_count'))
            ->groupBy('exercises.name')
            ->get();

        return response()->json([
            'message' => 'Workout statistics calculated successfully',
            'data' => [
                'total_sessions' => (int) $stats->total_sessions,
                'total_duration_seconds' => (int) $stats->total_duration_seconds,
                'total_reps_valid' => (int) $stats->total_reps_valid,
                'total_reps_anomaly' => (int) $stats->total_reps_anomaly,
                'average_accuracy_percentage' => round((float) $stats->average_accuracy_percentage, 2),
                'total_calories_burned' => round((float) $stats->total_calories_burned, 2),
                'exercise_breakdown' => $exerciseBreakdown,
            ],
        ], 200);
    }
}
