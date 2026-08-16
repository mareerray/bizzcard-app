class Skill {
  final String name;
  final String category; // e.g. 'Frontend', 'Backend', 'Database', 'Platform'
  final String? logoAsset; // Unused for now, but could be used to display a logo for the skill.

  const Skill({required this.name, required this.category, this.logoAsset});

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'logoAsset': logoAsset,
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        name: json['name'] as String,
        category: json['category'] as String,
        logoAsset: json['logoAsset'] as String?,
      );
}