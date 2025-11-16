import 'package:evolv_mobile/app/config/app_constants.dart';
import 'package:evolv_mobile/core/dto/family_model.dart';
import 'package:evolv_mobile/core/utils/app_notifications.dart';
import 'package:flutter/material.dart';

class FamilyListScreen extends StatefulWidget {
  const FamilyListScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _FamilyListScreenState createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends State<FamilyListScreen> {
  List<Family> families = [
    Family(
      id: "F1",
      name: "Rao Bai",
      members: [
        FamilyMember(
          id: 1,
          name: "Jernic",
          relation: "Self",
          dob: DateTime(2001, 5, 5), // 26 yrs approx
        ),
        FamilyMember(
          id: 2,
          name: "Yesu Anna Bai",
          relation: "Mother",
          dob: DateTime(1973, 7, 20), // 50 yrs approx
        ),
        FamilyMember(
          id: 3,
          name: "Abraham",
          relation: "Father",
          dob: DateTime(1974, 3, 27), // 54 yrs
        ),
        FamilyMember(
          id: 4,
          name: "Jerilsha",
          relation: "Sibling",
          dob: DateTime(2003, 8, 5), // 21 yrs
        ),
        FamilyMember(
          id: 5,
          name: "Jershal",
          relation: "Sibling",
          dob: DateTime(2004, 12, 19), // 21 yrs
        ),
      ],
    ),

    Family(
      id: "F2",
      name: "Cousin Side",
      members: [
        FamilyMember(
          id: 5,
          name: "Arun",
          relation: "Cousin",
          dob: DateTime(2000, 3, 18),
        ),
        FamilyMember(
          id: 6,
          name: "Anitha",
          relation: "Aunt",
          dob: DateTime(1978, 11, 9),
        ),
        FamilyMember(
          id: 7,
          name: "Rajesh",
          relation: "Uncle",
          dob: DateTime(1975, 4, 2),
        ),
      ],
    ),

    Family(
      id: "F3",
      name: "Extended Family",
      members: [
        FamilyMember(
          id: 8,
          name: "Joseph",
          relation: "Grandfather",
          dob: DateTime(1950, 1, 15),
        ),
        FamilyMember(
          id: 9,
          name: "Mary",
          relation: "Grandmother",
          dob: DateTime(1953, 6, 30),
        ),
      ],
    ),
  ];


  final List<String> relations = [
    'Self',
    'Spouse',
    'Child',
    'Father',
    'Mother',
    'Sibling',
    'Friend',
    'Grandfather',
    'Grandmother',
    'Other'
  ];

  int selectedFamilyIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activeFamily = families[selectedFamilyIndex];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(activeFamily),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ FAMILY SELECTION ----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Families (${families.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Add new family
                IconButton(
                  onPressed: _showAddFamilyDialog,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final theme = Theme.of(context);

                return SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: families.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final family = families[index];
                      final bool isSelected = index == selectedFamilyIndex;

                      final bgColor = isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHigh;

                      final textColor = isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface;

                      return GestureDetector(
                        onTap: () => setState(() => selectedFamilyIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              family.name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // -------------------- MEMBERS LIST ------------------------------
            Text(
              "Members",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: activeFamily.members.length,
                itemBuilder: (context, index) {
                  final member = activeFamily.members[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: ListTile(
                      title: Text(member.name),
                      subtitle: Text("${member.relation} • Age ${member.formattedAge}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditMemberDialog(activeFamily, member);
                              }),
                          IconButton(
                              icon: Icon(Icons.delete,color: Theme.of(context).colorScheme.error),
                              onPressed: () {
                                _deleteMember(activeFamily, member);
                              }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(Family activeFamily) {
    final nameCtrl = TextEditingController();
    String relation = 'Child';
    DateTime? selectedDob;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final today = DateTime.now();
                    final dob = await showDatePicker(
                      context: context,
                      initialDate: DateTime(today.year - 18),
                      firstDate: DateTime(1900),
                      lastDate: today,
                    );

                    if (dob != null) {
                      selectedDob = dob;
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDob == null
                              ? "Select Date of Birth"
                              : "${selectedDob!.day}-${selectedDob!.month}-${selectedDob!.year}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Icon(Icons.calendar_month),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                    children: [
                      const Text("Relation:"),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          child: DropdownButton<String>(
                            value: relation,
                            hint: const Text("Select"),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: relations
                                .map((r) =>
                                    DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) {
                              setState(() => relation = v ?? relation);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final name = nameCtrl.text.trim();

                if (name.isEmpty) {
                  AppNotifications.showToast(AppConstants.fillNameMessage);
                  return;
                }
                if (selectedDob == null) {
                  AppNotifications.showToast(AppConstants.fillDOBMessage);
                  return;
                }
                setState(() {
                  final newMember = FamilyMember(
                    id: 0,//DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    relation: relation,
                    dob: selectedDob!,
                  );
                  activeFamily.members.add(newMember);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMemberDialog(Family activeFamily, FamilyMember member) {
    final nameCtrl = TextEditingController(text: member.name);
    String relation = relations.contains(member.relation) ? member.relation : 'Other';
    DateTime? selectedDob = member.dob;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final today = DateTime.now();
                    final dob = await showDatePicker(
                      context: context,
                      initialDate: selectedDob ?? DateTime(today.year - 18),
                      firstDate: DateTime(1900),
                      lastDate: today,
                    );

                    if (dob != null) {
                      selectedDob = dob;
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDob == null
                              ? "Select Date of Birth"
                              : "${selectedDob!.day}-${selectedDob!.month}-${selectedDob!.year}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Icon(Icons.calendar_month),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Relation:"),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        child: DropdownButton<String>(
                          value: relations.contains(relation) ? relation : null,
                          hint: const Text("Select"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: relations
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => relation = v ?? relation);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  AppNotifications.showToast(AppConstants.fillNameMessage);
                  return;
                }
                if (selectedDob == null) {
                  AppNotifications.showToast(AppConstants.fillDOBMessage);
                  return;
                }

                setState(() {
                  final mIndex = activeFamily.members.indexWhere((m) => m.id == member.id);
                  if (mIndex != -1) {
                    activeFamily.members[mIndex].name = name;
                    activeFamily.members[mIndex].relation = relation;
                    activeFamily.members[mIndex].dob = selectedDob!;
                  }
                });

                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMember(Family activeFamily, FamilyMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member'),
        content: Text('Are you sure you want to remove ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                activeFamily.members.removeWhere((m) => m.id == member.id);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHOW ADD FAMILY DIALOG
  // ─────────────────────────────────────────────
  void _showAddFamilyDialog() {
    final TextEditingController nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Create New Family"),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: "Family Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  families.add(Family(
                    id: DateTime.now().toString(),
                    name: nameCtrl.text.trim(),
                    members: [],
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }
}
