class CropModel {
  final String id;
  final String name;
  final String variety;
  final DateTime plantedDate;
  String stage;
  List<CareTask> careTasks;
  List<GrowthRecord> growthHistory;

  CropModel({
    required this.id,
    required this.name,
    required this.variety,
    required this.plantedDate,
    required this.stage,
    required this.careTasks,
    required this.growthHistory,
  });

  CropModel copyWith({
    String? id,
    String? name,
    String? variety,
    DateTime? plantedDate,
    String? stage,
    List<CareTask>? careTasks,
    List<GrowthRecord>? growthHistory,
  }) {
    return CropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      plantedDate: plantedDate ?? this.plantedDate,
      stage: stage ?? this.stage,
      careTasks: careTasks ?? this.careTasks,
      growthHistory: growthHistory ?? this.growthHistory,
    );
  }

  int get daysGrown => DateTime.now().difference(plantedDate).inDays;

  double get progress {
    if (name == 'Paddy') {
      if (daysGrown <= 30) return daysGrown / 30;
      if (daysGrown <= 90) return 0.5 + (daysGrown - 30) / 120;
      return 1.0;
    } else if (name == 'Tomato') {
      if (daysGrown <= 20) return daysGrown / 20;
      if (daysGrown <= 70) return 0.5 + (daysGrown - 20) / 100;
      return 1.0;
    }
    return daysGrown / 90;
  }

  List<CareTask> getUpcomingTasks({int days = 7}) {
    final now = DateTime.now();
    return careTasks.where((task) {
      final daysUntil = task.dueDate.difference(now).inDays;
      return daysUntil <= days && daysUntil >= 0 && !task.isCompleted;
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'plantedDate': plantedDate.toIso8601String(),
      'stage': stage,
      'careTasks': careTasks.map((e) => e.toJson()).toList(),
      'growthHistory': growthHistory.map((e) => e.toJson()).toList(),
    };
  }

  static DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    if (dateVal is String) return DateTime.parse(dateVal);
    if (dateVal.runtimeType.toString() == 'Timestamp') {
      return dateVal.toDate();
    }
    return DateTime.now();
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      variety: json['variety'] ?? '',
      plantedDate: _parseDate(json['plantedDate']),
      stage: json['stage'] ?? '',
      careTasks: (json['careTasks'] as List?)
              ?.map((e) => CareTask.fromJson(e))
              .toList() ?? [],
      growthHistory: (json['growthHistory'] as List?)
              ?.map((e) => GrowthRecord.fromJson(e))
              .toList() ?? [],
    );
  }
}

class CareTask {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority;
  final String taskType;

  CareTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.priority,
    required this.taskType,
  });

  CareTask copyWith({bool? isCompleted}) {
    return CareTask(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority,
      taskType: taskType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'taskType': taskType,
    };
  }

  factory CareTask.fromJson(Map<String, dynamic> json) {
    return CareTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: CropModel._parseDate(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 'MEDIUM',
      taskType: json['taskType'] ?? 'GENERAL',
    );
  }
}

class GrowthRecord {
  final DateTime date;
  final double height;
  final String notes;
  final List<String> images;

  GrowthRecord({
    required this.date,
    required this.height,
    required this.notes,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'height': height,
      'notes': notes,
      'images': images,
    };
  }

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    return GrowthRecord(
      date: CropModel._parseDate(json['date']),
      height: (json['height'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }
}
