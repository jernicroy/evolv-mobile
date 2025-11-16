class Family {
  final String id;
  final String name;
  final List<FamilyMember> members;

  Family({required this.id, required this.name, required this.members});
}

class FamilyMember {
  int id;
  String name;
  String relation;
  DateTime dob;
  String? avatarUrl;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.dob,
    this.avatarUrl,
  });
  
  int get age {
    final today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month || 
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  String get formattedAge {
    final now = DateTime.now();

    int years = now.year - dob.year;
    int months = now.month - dob.month;
    int days = now.day - dob.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return "$years years $months months";
  }
}
