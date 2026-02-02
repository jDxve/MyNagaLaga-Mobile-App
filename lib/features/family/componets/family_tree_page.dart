import 'package:flutter/material.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../componets/add_member_dialog.dart';
import '../componets/delete_member_dialog.dart';
import '../componets/family_tree_view.dart';
import '../componets/select_generation_bottom.dart';
import '../models/family_ledger_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/household_member_model.dart';
import '../repository/family_ledger_repository_impl.dart';


class FamilyTreePage extends ConsumerStatefulWidget {
  static const String routeName = '/family-tree';
  final String? householdId; // Pass household ID from previous screen
  
  const FamilyTreePage({super.key, this.householdId});

  @override
  ConsumerState<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends ConsumerState<FamilyTreePage> {
  List<FamilyMember> generation1 = [];
  List<FamilyMember> generation2 = [];
  List<FamilyMember> generation3 = [];
  
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.householdId != null) {
      _loadHouseholdData();
    } else {
      _initializeDefaultMembers();
    }
  }

  Future<void> _loadHouseholdData() async {
    if (widget.householdId == null) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Call your repository to get household by ID
    final repository = ref.read(familyLedgerRepositoryProvider);
    final result = await repository.getHouseholdById(widget.householdId!);

    result.when(
      started: () {},
      loading: () {},
      success: (household) {
        _mapHouseholdToGenerations(household.members);
        setState(() {
          isLoading = false;
        });
      },
      error: (message) {
        setState(() {
          errorMessage = message;
          isLoading = false;
        });
        _initializeDefaultMembers();
      },
    );
  }

  void _mapHouseholdToGenerations(List<HouseholdMemberModel> members) {
    generation1.clear();
    generation2.clear();
    generation3.clear();

    for (var member in members) {
      final familyMember = FamilyMember(
        id: member.id,
        name: member.fullName,
        role: member.roleLabel,
        color: _getColorForRole(member.relationshipToHead),
      );

      // Map based on relationship
      if (member.relationshipToHead == 'Head' || 
          member.relationshipToHead == 'Spouse') {
        generation1.add(familyMember);
      } else if (member.relationshipToHead == 'Child' || 
                 member.relationshipToHead == 'Sibling') {
        generation2.add(familyMember);
      } else if (member.relationshipToHead == 'Grandchild' || 
                 member.relationshipToHead == 'Grandparent') {
        generation3.add(familyMember);
      } else {
        // Default to generation 2 for other relationships
        generation2.add(familyMember);
      }
    }

    setState(() {});
  }

  Color _getColorForRole(String role) {
    switch (role) {
      case 'Head':
        return AppColors.lightBlue;
      case 'Spouse':
        return AppColors.lightPurple;
      case 'Child':
      case 'Sibling':
        return AppColors.lightGrey;
      case 'Grandchild':
      case 'Grandparent':
        return AppColors.lightYellow;
      default:
        return AppColors.lightPink;
    }
  }

  void _initializeDefaultMembers() {
    generation1 = [
      FamilyMember(
        id: '1',
        name: 'John',
        role: 'Father',
        color: AppColors.lightBlue,
      ),
      FamilyMember(
        id: '2',
        name: 'Maria',
        role: 'Mother',
        color: AppColors.lightPurple,
      ),
    ];
    
    generation2 = [
      FamilyMember(
        id: '3',
        name: 'Alice',
        role: 'Daughter',
        color: AppColors.lightGrey,
      ),
      FamilyMember(
        id: '4',
        name: 'Bob',
        role: 'Son',
        color: AppColors.lightGrey,
      ),
    ];
    
    generation3 = [];
    
    setState(() {});
  }

  void _showSelectGenerationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SelectGenerationBottomSheet(
        onGenerationSelected: _showAddMemberDialog,
      ),
    );
  }

  void _showAddMemberDialog(int generation) {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        generation: generation,
        onAdd: (name, role, color) {
          _addMember(generation, name, role, color);
        },
      ),
    );
  }

  void _addMember(int generation, String name, String role, Color color) {
    setState(() {
      final newMember = FamilyMember(
        id: DateTime.now().toString(),
        name: name,
        role: role,
        color: color,
      );

      if (generation == 1) {
        generation1.add(newMember);
      } else if (generation == 2) {
        generation2.add(newMember);
      } else {
        generation3.add(newMember);
      }
    });
  }

  void _showDeleteDialog(FamilyMember member, int generation) {
    showDialog(
      context: context,
      builder: (context) => DeleteMemberDialog(
        memberName: member.name,
        onDelete: () => _deleteMember(member.id, generation),
      ),
    );
  }

  void _deleteMember(String id, int generation) {
    setState(() {
      if (generation == 1) {
        generation1.removeWhere((member) => member.id == id);
      } else if (generation == 2) {
        generation2.removeWhere((member) => member.id == id);
      } else {
        generation3.removeWhere((member) => member.id == id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    D.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textlogo,
            size: D.iconSM,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Family Registry',
          style: TextStyle(
            fontSize: D.textMD,
            fontWeight: D.bold,
            color: AppColors.textlogo,
            fontFamily: 'Segoe UI',
          ),
        ),
        actions: [
          if (widget.householdId != null)
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _loadHouseholdData,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      16.gapH,
                      ElevatedButton(
                        onPressed: _loadHouseholdData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      children: [
                        Text(
                          'Family Registry',
                          style: TextStyle(
                            fontSize: D.textLG,
                            fontWeight: D.bold,
                            color: AppColors.textlogo,
                          ),
                        ),
                        8.gapH,
                        Text(
                          'Easily manage your family tree. Add users, track ages, and define roles within your family structure.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: D.textSM,
                            color: AppColors.grey,
                            height: 1.4,
                          ),
                        ),
                        32.gapH,
                        FamilyTreeView(
                          generation1: generation1,
                          generation2: generation2,
                          generation3: generation3,
                          onMemberLongPress: _showDeleteDialog,
                        ),
                        40.gapH,
                        _buildAddButton(),
                        24.gapH,
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showSelectGenerationSheet,
          borderRadius: BorderRadius.circular(28.w),
          child: Center(
            child: Icon(
              Icons.add,
              color: AppColors.primary,
              size: D.iconMD,
            ),
          ),
        ),
      ),
    );
  }
}