class RepetitionTelemetry {
  final int repNumber;
  final bool isValid;
  final String? anomalyReason;
  final double? imuConfidenceScore;
  final double? poseConfidenceScore;
  final double? durationSeconds;
  final double? peakJointAngle;
  final double? bodySwayAngle;
  final double? peakAcceleration;

  const RepetitionTelemetry({
    required this.repNumber,
    required this.isValid,
    this.anomalyReason,
    this.imuConfidenceScore,
    this.poseConfidenceScore,
    this.durationSeconds,
    this.peakJointAngle,
    this.bodySwayAngle,
    this.peakAcceleration,
  });

  factory RepetitionTelemetry.fromJson(Map<String, dynamic> json) {
    return RepetitionTelemetry(
      repNumber: json['rep_number'] as int,
      isValid: json['is_valid'] as bool? ?? false,
      anomalyReason: json['anomaly_reason'] as String?,
      imuConfidenceScore: json['imu_confidence_score'] != null
          ? double.tryParse(json['imu_confidence_score'].toString())
          : null,
      poseConfidenceScore: json['pose_confidence_score'] != null
          ? double.tryParse(json['pose_confidence_score'].toString())
          : null,
      durationSeconds: json['duration_seconds'] != null
          ? double.tryParse(json['duration_seconds'].toString())
          : null,
      peakJointAngle: json['peak_joint_angle'] != null
          ? double.tryParse(json['peak_joint_angle'].toString())
          : null,
      bodySwayAngle: json['body_sway_angle'] != null
          ? double.tryParse(json['body_sway_angle'].toString())
          : null,
      peakAcceleration: json['peak_acceleration'] != null
          ? double.tryParse(json['peak_acceleration'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rep_number': repNumber,
      'is_valid': isValid,
      if (anomalyReason != null) 'anomaly_reason': anomalyReason,
      if (imuConfidenceScore != null) 'imu_confidence_score': imuConfidenceScore,
      if (poseConfidenceScore != null) 'pose_confidence_score': poseConfidenceScore,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (peakJointAngle != null) 'peak_joint_angle': peakJointAngle,
      if (bodySwayAngle != null) 'body_sway_angle': bodySwayAngle,
      if (peakAcceleration != null) 'peak_acceleration': peakAcceleration,
    };
  }
}
