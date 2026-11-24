class ExerciseModel {
  final int id;
  final String name;
  final String? description;
  final String? targetMuscle;
  final String category;
  final String level;
  final double minElbowAngle;
  final double maxElbowAngle;
  final double maxTorsoSwayAngle;
  final String? thumbnailUrl;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    this.targetMuscle,
    this.category = 'Lengan',
    this.level = 'PEMULA',
    this.minElbowAngle = 40.0,
    this.maxElbowAngle = 160.0,
    this.maxTorsoSwayAngle = 15.0,
    this.thumbnailUrl,
  });

  static String resolveThumbnail(String name, String? existingUrl) {
    if (existingUrl != null && existingUrl.isNotEmpty) {
      return existingUrl;
    }
    final lower = name.toLowerCase();
    if (lower.contains('bicep')) {
      return 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=600&q=80';
    } else if (lower.contains('hammer')) {
      return 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=600&q=80';
    } else if (lower.contains('shoulder')) {
      return 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=600&q=80';
    } else if (lower.contains('lateral')) {
      return 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80';
    } else if (lower.contains('row')) {
      return 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?auto=format&fit=crop&w=600&q=80';
    } else if (lower.contains('press')) {
      return 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=600&q=80';
    }
    return 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=600&q=80';
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Latihan';
    String cat = 'Lengan';
    if (json['category'] is Map && json['category']['name'] != null) {
      cat = json['category']['name'].toString();
    } else if (json['category_name'] != null) {
      cat = json['category_name'].toString();
    } else {
      final lower = name.toLowerCase();
      if (lower.contains('shoulder') || lower.contains('lateral')) cat = 'Bahu';
      if (lower.contains('row')) cat = 'Punggung';
      if (lower.contains('press') && !lower.contains('shoulder')) cat = 'Dada';
    }

    String lvl = json['level'] as String? ?? (name.toLowerCase().contains('shoulder') ? 'MENENGAH' : 'PEMULA');

    return ExerciseModel(
      id: json['id'] as int? ?? 1,
      name: name,
      description: json['description'] as String?,
      targetMuscle: json['target_muscle'] as String?,
      category: cat,
      level: lvl,
      minElbowAngle: (json['min_elbow_angle'] != null)
          ? double.tryParse(json['min_elbow_angle'].toString()) ?? 40.0
          : 40.0,
      maxElbowAngle: (json['max_elbow_angle'] != null)
          ? double.tryParse(json['max_elbow_angle'].toString()) ?? 160.0
          : 160.0,
      maxTorsoSwayAngle: (json['max_torso_sway_angle'] != null)
          ? double.tryParse(json['max_torso_sway_angle'].toString()) ?? 15.0
          : 15.0,
      thumbnailUrl: resolveThumbnail(name, json['thumbnail_url'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_muscle': targetMuscle,
      'category': category,
      'level': level,
      'min_elbow_angle': minElbowAngle,
      'max_elbow_angle': maxElbowAngle,
      'max_torso_sway_angle': maxTorsoSwayAngle,
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Pre-configured default exercises yang lengkap dan sesuai dengan tema gym modern
  static List<ExerciseModel> defaultExercises = const [
    ExerciseModel(
      id: 1,
      name: 'Bicep Curl',
      description: 'Bentuk lengan lebih kuat dengan rentang gerak penuh dan terkontrol.',
      targetMuscle: 'Bisep',
      category: 'Lengan',
      level: 'PEMULA',
      minElbowAngle: 40.0,
      maxElbowAngle: 160.0,
      maxTorsoSwayAngle: 15.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=600&q=80',
    ),
    ExerciseModel(
      id: 2,
      name: 'Hammer Curl',
      description: 'Variasi pegangan netral untuk melatih kekuatan bisep dan lengan bawah.',
      targetMuscle: 'Bisep • Lengan Bawah',
      category: 'Lengan',
      level: 'PEMULA',
      minElbowAngle: 40.0,
      maxElbowAngle: 155.0,
      maxTorsoSwayAngle: 15.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=600&q=80',
    ),
    ExerciseModel(
      id: 3,
      name: 'Shoulder Press',
      description: 'Latih kekuatan dorong overhead dan stabilitas bahu secara terkoordinasi.',
      targetMuscle: 'Bahu • Trisep',
      category: 'Bahu',
      level: 'MENENGAH',
      minElbowAngle: 70.0,
      maxElbowAngle: 175.0,
      maxTorsoSwayAngle: 12.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=600&q=80',
    ),
    ExerciseModel(
      id: 4,
      name: 'Lateral Raise',
      description: 'Isolasi deltoid samping dengan gerakan halus, teratur, dan seimbang.',
      targetMuscle: 'Deltoid Samping',
      category: 'Bahu',
      level: 'PEMULA',
      minElbowAngle: 15.0,
      maxElbowAngle: 90.0,
      maxTorsoSwayAngle: 10.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80',
    ),
    ExerciseModel(
      id: 5,
      name: 'Dumbbell Row',
      description: 'Tarik dumbel ke arah pinggul untuk melatih ketebalan otot punggung atas.',
      targetMuscle: 'Punggung • Sayap',
      category: 'Punggung',
      level: 'MENENGAH',
      minElbowAngle: 45.0,
      maxElbowAngle: 130.0,
      maxTorsoSwayAngle: 20.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?auto=format&fit=crop&w=600&q=80',
    ),
    ExerciseModel(
      id: 6,
      name: 'Floor Press',
      description: 'Dorongan dumbel dari lantai untuk kekuatan dada dan trisep yang stabil.',
      targetMuscle: 'Dada • Trisep',
      category: 'Dada',
      level: 'PEMULA',
      minElbowAngle: 60.0,
      maxElbowAngle: 165.0,
      maxTorsoSwayAngle: 10.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=600&q=80',
    ),
  ];
}
