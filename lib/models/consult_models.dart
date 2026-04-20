import 'package:flutter/material.dart';

/// Category accent colors pulled from the brand palette (primary/accent/vetBadge
/// family) so tags read as muted brand variants — not candy-shop rainbow.
/// Semantic red stays only for true emergency.
enum ConsultCategory {
  health('Health', '🩺', Color(0xFF6C4AB6)),        // primary purple
  nutrition('Nutrition', '🥗', Color(0xFF34C9B7)),  // accent teal
  behavior('Behavior', '🐾', Color(0xFF2563EB)),    // vetBadge blue
  grooming('Grooming', '✂️', Color(0xFF2BA99B)),   // muted accent
  emergency('Emergency', '🚨', Color(0xFFEF4444)),  // danger (reserved)
  other('Other', '💬', Color(0xFF6B6480));          // textSecondary

  final String label;
  final String emoji;
  final Color color;
  const ConsultCategory(this.label, this.emoji, this.color);
}

enum AuthorRole { owner, vet, brand }

class Author {
  final String name;
  final String? clinic;
  final String avatarSeed;
  final AuthorRole role;
  final String? specialty;
  final List<String> treatsSpecies;
  final bool verified;
  final String? bio;

  const Author({
    required this.name,
    this.clinic,
    required this.avatarSeed,
    required this.role,
    this.specialty,
    this.treatsSpecies = const [],
    this.verified = false,
    this.bio,
  });

  Author copyWith({
    String? name,
    String? clinic,
    String? avatarSeed,
    AuthorRole? role,
    String? specialty,
    List<String>? treatsSpecies,
    bool? verified,
    String? bio,
  }) {
    return Author(
      name: name ?? this.name,
      clinic: clinic ?? this.clinic,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      treatsSpecies: treatsSpecies ?? this.treatsSpecies,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
    );
  }
}

/// Common vet specialty presets for quick-pick. Free-text still allowed.
const vetSpecialtyPresets = <String>[
  'Internal Medicine',
  'Dermatology',
  'Nutrition',
  'Surgery',
  'Dentistry',
  'Ophthalmology',
  'Cardiology',
  'Orthopedics',
  'Behavior',
  'Emergency',
  'Exotic Animals',
];

class Pet {
  final String name;
  final String breed;
  final String species;
  final int ageMonths;
  final double? weightKg;
  final String? sex; // 'male' / 'female' / 'unknown'
  final bool neutered;
  final String avatarSeed;

  const Pet({
    required this.name,
    required this.breed,
    required this.species,
    required this.ageMonths,
    this.weightKg,
    this.sex,
    this.neutered = false,
    required this.avatarSeed,
  });
}

enum HealthLogType { weight, vaccine, grooming, checkup, medication, note }

extension HealthLogTypeX on HealthLogType {
  String get label {
    switch (this) {
      case HealthLogType.weight:
        return 'Weight';
      case HealthLogType.vaccine:
        return 'Vaccine';
      case HealthLogType.grooming:
        return 'Grooming';
      case HealthLogType.checkup:
        return 'Check-up';
      case HealthLogType.medication:
        return 'Medication';
      case HealthLogType.note:
        return 'Note';
    }
  }

  String get emoji {
    switch (this) {
      case HealthLogType.weight:
        return '⚖️';
      case HealthLogType.vaccine:
        return '💉';
      case HealthLogType.grooming:
        return '✂️';
      case HealthLogType.checkup:
        return '🩺';
      case HealthLogType.medication:
        return '💊';
      case HealthLogType.note:
        return '📝';
    }
  }
}

class HealthLogEntry {
  final HealthLogType type;
  final String petSeed;
  final String title;
  final String? note;
  final DateTime loggedAt;

  const HealthLogEntry({
    required this.type,
    required this.petSeed,
    required this.title,
    this.note,
    required this.loggedAt,
  });
}

enum ActivityType { telemetBooked, shopPurchased, privateConsult }

extension ActivityTypeX on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.telemetBooked:
        return 'Telemet';
      case ActivityType.shopPurchased:
        return 'Shop';
      case ActivityType.privateConsult:
        return 'Private Consult';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.telemetBooked:
        return Icons.videocam_outlined;
      case ActivityType.shopPurchased:
        return Icons.shopping_bag_outlined;
      case ActivityType.privateConsult:
        return Icons.lock_outline;
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.telemetBooked:
        return const Color(0xFFF59E0B);
      case ActivityType.shopPurchased:
        return const Color(0xFFD946EF);
      case ActivityType.privateConsult:
        return const Color(0xFF6C4AB6);
    }
  }
}

class ActivityEntry {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String? amount;
  final String? relatedAvatarSeed;
  final DateTime at;

  const ActivityEntry({
    required this.type,
    required this.title,
    required this.subtitle,
    this.amount,
    this.relatedAvatarSeed,
    required this.at,
  });
}

class Answer {
  final String id;
  final Author author;
  final String body;
  final int upvotes;
  final bool accepted;
  final DateTime postedAt;
  final bool suggestsClinicVisit;
  final List<String> photos;
  final bool isBrandSponsored;
  final String? brandCta;

  const Answer({
    required this.id,
    required this.author,
    required this.body,
    required this.upvotes,
    required this.accepted,
    required this.postedAt,
    this.suggestsClinicVisit = false,
    this.photos = const [],
    this.isBrandSponsored = false,
    this.brandCta,
  });
}

class Question {
  final String id;
  final String title;
  final String body;
  final ConsultCategory category;
  final Author author;
  final Pet? pet;
  final List<String> photos;
  final int upvotes;
  final List<Answer> answers;
  final DateTime postedAt;
  final bool isUrgent;

  const Question({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.author,
    this.pet,
    this.photos = const [],
    required this.upvotes,
    required this.answers,
    required this.postedAt,
    this.isUrgent = false,
  });

  int get answerCount => answers.length;
  bool get hasAcceptedAnswer => answers.any((a) => a.accepted);
}
