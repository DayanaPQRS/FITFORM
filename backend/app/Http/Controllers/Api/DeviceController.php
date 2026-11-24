<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    /**
     * Display a listing of devices paired with the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $devices = Device::where('user_id', $request->user()->id)
            ->orderBy('updated_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'Devices retrieved successfully',
            'data' => $devices,
        ], 200);
    }

    /**
     * Display the specified device.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $device = Device::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        return response()->json([
            'message' => 'Device details retrieved successfully',
            'data' => $device,
        ], 200);
    }

    /**
     * Pair or register a smart dumbbell device with the authenticated user.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mac_address' => 'required|string|regex:/^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/',
            'device_code' => 'required|string|max:50',
            'firmware_version' => 'nullable|string|max:20',
        ]);

        $device = Device::updateOrCreate(
            ['mac_address' => strtoupper($validated['mac_address'])],
            [
                'user_id' => $request->user()->id,
                'device_code' => $validated['device_code'],
                'firmware_version' => $validated['firmware_version'] ?? null,
                'status' => 'active',
            ]
        );

        return response()->json([
            'message' => 'Device paired successfully',
            'data' => $device,
        ], 201);
    }

    /**
     * Update the specified device status or firmware.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $device = Device::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $validated = $request->validate([
            'device_code' => 'sometimes|string|max:50',
            'firmware_version' => 'nullable|string|max:20',
            'status' => 'sometimes|in:active,maintenance,inactive',
        ]);

        $device->update($validated);

        return response()->json([
            'message' => 'Device updated successfully',
            'data' => $device,
        ], 200);
    }

    /**
     * Unpair the device from the authenticated user.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $device = Device::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        // Release the device pairing
        $device->update([
            'user_id' => null,
            'status' => 'inactive',
        ]);

        return response()->json([
            'message' => 'Device unpaired successfully',
        ], 200);
    }
}
