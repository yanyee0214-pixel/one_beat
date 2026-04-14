import 'package:flutter/material.dart';

/// 貓咪角色模型
class CatCharacter {
  final String id;                    // 貓咪唯一 ID (e.g., "jing_jing")
  final String name;                  // 貓咪名字 (e.g., "靜靜")
  final String description;           // 貓咪描述
  final int wave;                     // 波次 (1-5)
  final UnlockCondition unlockCondition; // 解鎖條件
  final List<Color> primaryColors;    // 主要顏色 (for Procreate design)
  final List<Color> accentColors;     // 強調顏色
  final String role;                  // 角色類型 ("meditation", "tapping", "companion")
  
  int affectionLevel;                 // 親密度 (1-5)
  DateTime? unlockedDate;             // 解鎖日期
  int totalTaps;                      // 累計點擊次數
  int totalMeditations;               // 累計冥想次數

  CatCharacter({
    required this.id,
    required this.name,
    required this.description,
    required this.wave,
    required this.unlockCondition,
    required this.primaryColors,
    required this.accentColors,
    required this.role,
    this.affectionLevel = 1,
    this.unlockedDate,
    this.totalTaps = 0,
    this.totalMeditations = 0,
  });

  /// 轉換為 JSON (for persistence)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'wave': wave,
      'unlockCondition': unlockCondition.toJson(),
      'primaryColors': primaryColors.map((c) => c.value).toList(),
      'accentColors': accentColors.map((c) => c.value).toList(),
      'role': role,
      'affectionLevel': affectionLevel,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'totalTaps': totalTaps,
      'totalMeditations': totalMeditations,
    };
  }

  /// 從 JSON 重構
  factory CatCharacter.fromJson(Map<String, dynamic> json) {
    return CatCharacter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      wave: json['wave'],
      unlockCondition: UnlockCondition.fromJson(json['unlockCondition']),
      primaryColors: (json['primaryColors'] as List)
          .map((c) => Color(c as int))
          .toList(),
      accentColors: (json['accentColors'] as List)
          .map((c) => Color(c as int))
          .toList(),
      role: json['role'],
      affectionLevel: json['affectionLevel'] ?? 1,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'])
          : null,
      totalTaps: json['totalTaps'] ?? 0,
      totalMeditations: json['totalMeditations'] ?? 0,
    );
  }

  /// 增加親密度
  void addAffection({int amount = 1}) {
    affectionLevel = (affectionLevel + amount).clamp(1, 5);
  }

  /// 檢查是否已解鎖
  bool isUnlocked() => unlockedDate != null;
}

/// 解鎖條件
class UnlockCondition {
  final UnlockType type;              // 解鎖類型
  final int? requiredDays;            // 所需天數 (null if not applicable)
  final int? requiredTaps;            // 所需點擊次數
  final int? requiredMeditations;     // 所需冥想次數

  UnlockCondition({
    required this.type,
    this.requiredDays,
    this.requiredTaps,
    this.requiredMeditations,
  });

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'requiredDays': requiredDays,
      'requiredTaps': requiredTaps,
      'requiredMeditations': requiredMeditations,
    };
  }

  /// 從 JSON 重構
  factory UnlockCondition.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    return UnlockCondition(
      type: UnlockType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
      ),
      requiredDays: json['requiredDays'],
      requiredTaps: json['requiredTaps'],
      requiredMeditations: json['requiredMeditations'],
    );
  }

  /// 檢查是否滿足解鎖條件
  bool isMet({
    required int daysActive,
    required int totalTaps,
    required int totalMeditations,
  }) {
    switch (type) {
      case UnlockType.daysActive:
        return daysActive >= (requiredDays ?? 0);
      case UnlockType.totalTaps:
        return totalTaps >= (requiredTaps ?? 0);
      case UnlockType.totalMeditations:
        return totalMeditations >= (requiredMeditations ?? 0);
      case UnlockType.immediate:
        return true;
    }
  }
}

enum UnlockType {
  immediate,           // 立即可用
  daysActive,          // 基於活躍天數
  totalTaps,           // 基於總點擊次數
  totalMeditations,    // 基於冥想次數
}
