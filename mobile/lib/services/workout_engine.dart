import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
import '../models/repetition_telemetry.dart';
import '../models/user_model.dart';

enum WorkoutState { idle, active, paused, completed }

enum FormStatus { good, anomaly, neutral }

class WorkoutEngine extends ChangeNotifier {
  final ExerciseModel exercise;
  final UserModel? user;

  WorkoutState _state = WorkoutState.idle;
  WorkoutState get state => _state;

  FormStatus _formStatus = FormStatus.neutral;
  FormStatus get formStatus => _formStatus;

  String _feedbackMessage = 'Posisikan tubuh 1.5 - 3 meter di depan kamera';
  String get feedbackMessage => _feedbackMessage;

  // Waktu & Durasi
  DateTime? _startedAt;
  DateTime? get startedAt => _startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _endedAt;

  int _durationSeconds = 0;
  int get durationSeconds => _durationSeconds;
  Timer? _sessionTimer;

  // Repetisi & Performa
  int _validReps = 0;
  int get validReps => _validReps;

  int _anomalyReps = 0;
  int get anomalyReps => _anomalyReps;

  int get totalReps => _validReps + _anomalyReps;

  double get formAccuracyPercentage {
    if (totalReps == 0) return 100.0;
    return double.parse(((_validReps / totalReps) * 100).toStringAsFixed(1));
  }

  // Estimasi Kalori Terbakar (MET Formula)
  // Calories = (5.5 * 3.5 * weightKg / 200) * (durationSeconds / 60)
  double get caloriesBurned {
    final weight = (user?.weightKg != null && user!.weightKg! > 0)
        ? user!.weightKg!
        : 65.0;
    final minutes = _durationSeconds / 60.0;
    final cal = (5.5 * 3.5 * weight / 200.0) * minutes;
    return double.parse(cal.toStringAsFixed(1));
  }

  // Live Kinematika & Biomekanika
  double _currentElbowAngle = 150.0;
  double get currentElbowAngle => _currentElbowAngle;

  double _currentTorsoSwayAngle = 3.5;
  double get currentTorsoSwayAngle => _currentTorsoSwayAngle;

  double _currentAcceleration = 1.2;
  double get currentAcceleration => _currentAcceleration;

  // Log Repetisi
  final List<RepetitionTelemetry> _repetitions = [];
  List<RepetitionTelemetry> get repetitions => List.unmodifiable(_repetitions);

  WorkoutEngine({
    required this.exercise,
    this.user,
  });

  // Mulai Sesi Latihan
  void start() {
    if (_state == WorkoutState.active) return;
    _state = WorkoutState.active;
    _startedAt = DateTime.now();
    _formStatus = FormStatus.good;
    _feedbackMessage = 'Sesi dimulai. Jaga postur dan ritme angkatan.';

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state == WorkoutState.active) {
        _durationSeconds++;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  // Jeda Sesi Latihan
  void pause() {
    if (_state != WorkoutState.active) return;
    _state = WorkoutState.paused;
    _feedbackMessage = 'Sesi latihan dijeda';
    notifyListeners();
  }

  // Lanjutkan Sesi Latihan
  void resume() {
    if (_state != WorkoutState.paused) return;
    _state = WorkoutState.active;
    _feedbackMessage = 'Melanjutkan latihan...';
    notifyListeners();
  }

  // Akhiri Sesi Latihan
  void stop() {
    if (_state == WorkoutState.completed) return;
    _state = WorkoutState.completed;
    _endedAt = DateTime.now();
    _sessionTimer?.cancel();
    _feedbackMessage = 'Sesi latihan selesai';
    notifyListeners();
  }

  // Catat Satu Repetisi Hasil Fusi Sensor-Visi
  void recordRepetition({
    required bool isValid,
    String? anomalyReason,
    double? peakJointAngle,
    double? bodySwayAngle,
    double? peakAcceleration,
    double? durationSeconds,
    double imuConfidence = 0.94,
    double poseConfidence = 0.96,
  }) {
    if (_state != WorkoutState.active) return;

    final repNum = totalReps + 1;
    final telemetry = RepetitionTelemetry(
      repNumber: repNum,
      isValid: isValid,
      anomalyReason: anomalyReason,
      peakJointAngle: peakJointAngle ?? _currentElbowAngle,
      bodySwayAngle: bodySwayAngle ?? _currentTorsoSwayAngle,
      peakAcceleration: peakAcceleration ?? _currentAcceleration,
      durationSeconds: durationSeconds ?? 2.4,
      imuConfidenceScore: imuConfidence,
      poseConfidenceScore: poseConfidence,
    );

    _repetitions.add(telemetry);

    if (isValid) {
      _validReps++;
      _formStatus = FormStatus.good;
      _feedbackMessage = 'Repetisi #$repNum Sah! Bentuk gerakan sangat baik.';
    } else {
      _anomalyReps++;
      _formStatus = FormStatus.anomaly;
      _feedbackMessage = 'Anomali #$repNum: ${anomalyReason ?? "Bentuk menyimpang"}';
    }

    notifyListeners();
  }

  // ==========================================
  // METODE SIMULASI & DEMO INTERAKTIF
  // (Digunakan untuk validasi visual & interaksi UI sebelum IoT fisik terpasang)
  // ==========================================

  void simulateValidRepetition() {
    _currentElbowAngle = exercise.minElbowAngle + 3.0;
    _currentTorsoSwayAngle = 4.2; // Aman di bawah batas toleransi
    _currentAcceleration = 2.4;

    recordRepetition(
      isValid: true,
      peakJointAngle: _currentElbowAngle,
      bodySwayAngle: _currentTorsoSwayAngle,
      peakAcceleration: _currentAcceleration,
      durationSeconds: 2.3,
    );
  }

  void simulateAnomalyBodySway() {
    _currentElbowAngle = exercise.minElbowAngle + 5.0;
    _currentTorsoSwayAngle = exercise.maxTorsoSwayAngle + 7.5; // Menyimpang jauh
    _currentAcceleration = 4.1;

    recordRepetition(
      isValid: false,
      anomalyReason: 'Ayunan Tubuh Berlebih (${_currentTorsoSwayAngle.toStringAsFixed(1)}° > ${exercise.maxTorsoSwayAngle}°)',
      peakJointAngle: _currentElbowAngle,
      bodySwayAngle: _currentTorsoSwayAngle,
      peakAcceleration: _currentAcceleration,
      durationSeconds: 1.8,
    );
  }

  void simulateAnomalyIncompleteROM() {
    _currentElbowAngle = exercise.minElbowAngle + 38.0; // Tidak mencapai fleksi penuh
    _currentTorsoSwayAngle = 5.0;
    _currentAcceleration = 1.9;

    recordRepetition(
      isValid: false,
      anomalyReason: 'Rentang Gerak Tidak Penuh (ROM ${ _currentElbowAngle.toStringAsFixed(0)}°)',
      peakJointAngle: _currentElbowAngle,
      bodySwayAngle: _currentTorsoSwayAngle,
      peakAcceleration: _currentAcceleration,
      durationSeconds: 1.5,
    );
  }

  // Mengubah sudut sendi live secara dinamis
  void updateLiveAngles({required double elbowAngle, required double swayAngle}) {
    _currentElbowAngle = elbowAngle;
    _currentTorsoSwayAngle = swayAngle;

    if (swayAngle > exercise.maxTorsoSwayAngle) {
      _formStatus = FormStatus.anomaly;
      _feedbackMessage = 'PERINGATAN: Tubuh mulai mengayun (${swayAngle.toStringAsFixed(1)}°)';
    } else {
      _formStatus = FormStatus.good;
      _feedbackMessage = 'Postur stabil. Lanjutkan angkatan.';
    }

    notifyListeners();
  }

  // Konversi seluruh sesi menjadi Payload Atomik untuk REST API Laravel Backend
  Map<String, dynamic> toApiPayload({int? deviceId, String? notes}) {
    return {
      'exercise_id': exercise.id,
      if (deviceId != null) 'device_id': deviceId,
      'started_at': (_startedAt ?? DateTime.now()).toIso8601String(),
      'ended_at': (_endedAt ?? DateTime.now()).toIso8601String(),
      'duration_seconds': _durationSeconds,
      'notes': notes ?? 'Sesi latihan mandiri via FITFORM Mobile Client',
      'repetitions': _repetitions.map((r) => r.toJson()).toList(),
    };
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
