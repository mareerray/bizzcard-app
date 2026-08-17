import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/skill.dart';
import '../data/skill_catalog.dart';

const _kAccent = Color.fromARGB(255, 32, 133, 206);
const _kSurface = Color(0xFF1E1E1E);
const _kBg = Color(0xFF0A0A0A);
const _categoryOrder = ['Frontend', 'Backend', 'Database', 'Platform', 'Mobile', 'Other'];

class SkillsEditorDialog extends StatefulWidget {
  final List<Skill> initialSkills;
  const SkillsEditorDialog({super.key, required this.initialSkills});

  @override
  State<SkillsEditorDialog> createState() => _SkillsEditorDialogState();
}

class _SkillsEditorDialogState extends State<SkillsEditorDialog> {
  late Set<String> _selectedNames;

  @override
  void initState() {
    super.initState();
    _selectedNames = widget.initialSkills.map((s) => s.name).toSet();
  }

  void _toggle(String name) {
    setState(() {
      if (_selectedNames.contains(name)) {
        _selectedNames.remove(name);
      } else {
        _selectedNames.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Skill>>{};
    for (final skill in skillCatalog) {
      grouped.putIfAbsent(skill.category, () => []).add(skill);
    }
    final categories = _categoryOrder.where(grouped.containsKey).toList();

    return Dialog(
      backgroundColor: _kBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Your Skills',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedNames.length} selected',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
              ),
              const Divider(color: Colors.white12, height: 20),
              Expanded(
                child: ListView(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kAccent,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: grouped[category]!.map((skill) {
                              final selected = _selectedNames.contains(skill.name);
                              return GestureDetector(
                                onTap: () => _toggle(skill.name),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected ? _kAccent.withValues(alpha: 0.2) : _kSurface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected ? _kAccent : Colors.white12,
                                      width: selected ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (selected) ...[
                                        const Icon(Icons.check, size: 14, color: _kAccent),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        skill.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: selected ? Colors.white : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final result = skillCatalog
                          .where((s) => _selectedNames.contains(s.name))
                          .toList();
                      Navigator.pop(context, result);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _kAccent, foregroundColor: Colors.white),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}