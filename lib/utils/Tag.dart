class Tag {
  int id;
  String name;
  bool isSelected = false;

  Tag(this.id, this.name, this.isSelected);

  void reset() {
    this.isSelected = false;
  }

  @override
  String toString() => this.name;

  // Automatic Recruitment [EN]
  static var allTagsEN = <Tag>[
    new Tag(1, "Guard", false),
    new Tag(2, "Sniper", false),
    new Tag(3, "Defender", false),
    new Tag(4, "Medic", false),
    new Tag(5, "Supporter", false),
    new Tag(6, "Caster", false),
    new Tag(7, "Specialist", false),
    new Tag(8, "Vanguard", false),
    new Tag(9, "Melee", false),
    new Tag(10, "Ranged", false),
    new Tag(11, "Top Operator", false),
    new Tag(12, "Crowd-Control", false),
    new Tag(13, "Nuker", false),
    new Tag(14, "Senior Operator", false),
    new Tag(15, "Healing", false),
    new Tag(16, "Support", false),
    new Tag(17, "Starter", false),
    new Tag(18, "DP-Recovery", false),
    new Tag(19, "DPS", false),
    new Tag(20, "Survival", false),
    new Tag(21, "AoE", false),
    new Tag(22, "Defense", false),
    new Tag(23, "Slow", false),
    new Tag(24, "Debuff", false),
    new Tag(25, "Fast-Redeploy", false),
    new Tag(26, "Shift", false),
    new Tag(27, "Summon", false),
    new Tag(28, "Robot", false),
  ];

  static List<Tag> getTagsEN() {
    return allTagsEN;
  }

  static List<String> getNames() {
    return allTagsEN.map((tag) => tag.name).toList();
  }
}
