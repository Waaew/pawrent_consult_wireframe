import 'package:flutter/material.dart';

enum ConsultCategory {
  health('Health', '🩺', Color(0xFFEF4444)),
  nutrition('Nutrition', '🥗', Color(0xFF22C55E)),
  behavior('Behavior', '🐾', Color(0xFF6C4AB6)),
  grooming('Grooming', '✂️', Color(0xFF06B6D4)),
  emergency('Emergency', '🚨', Color(0xFFDC2626)),
  other('Other', '💬', Color(0xFF6B7280));

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
  final bool verified;
  final String? bio;

  const Author({
    required this.name,
    this.clinic,
    required this.avatarSeed,
    required this.role,
    this.specialty,
    this.verified = false,
    this.bio,
  });

  Author copyWith({
    String? name,
    String? clinic,
    String? avatarSeed,
    AuthorRole? role,
    String? specialty,
    bool? verified,
    String? bio,
  }) {
    return Author(
      name: name ?? this.name,
      clinic: clinic ?? this.clinic,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
    );
  }
}

class Pet {
  final String name;
  final String breed;
  final String species;
  final int ageMonths;
  final String avatarSeed;

  const Pet({
    required this.name,
    required this.breed,
    required this.species,
    required this.ageMonths,
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
