import 'package:fish_caster/bloc/criteria/criteria_bloc.dart';
import 'package:fish_caster/bloc/criteria/criteria_event.dart';
import 'package:fish_caster/bloc/criteria/criteria_state.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/widgets/TextField/custom_textfield.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_services/criteria_services/criteriaServices.dart';
import '../../model/criteria_model/criteriaModel.dart';
import '../criteria_screen/create_criteria_screen.dart';

class CriteriaBottomSheet extends StatefulWidget {
  final String authToken;

  const CriteriaBottomSheet({super.key, required this.authToken});

  @override
  State<CriteriaBottomSheet> createState() => _CriteriaBottomSheetState();
}

class _CriteriaBottomSheetState extends State<CriteriaBottomSheet> {
  TextEditingController searchController = TextEditingController();
  List<CriteriaProfile> _allProfiles = [];
  List<CriteriaProfile> _filteredProfiles = [];
  bool _loading = false;
  String _searchText = '';
  String? _editingCriteriaId; // Track which criteria is being edited

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _loading = true);
    try {
      final service = CriteriaService(
        // tokenBloc: context.read<TokenBloc>(),
        // context: context,
      );
      final result = await service.getAllProfiles(widget.authToken);
      if (mounted) {
        setState(() {
          _allProfiles = result;
          _filteredProfiles = result;
          // _loading = false;
        });
      }
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    } catch (e) {
      // setState(() => _loading = false);
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    }
  }

  void _filter(String query) {
    setState(() {
      _searchText = query;
      _filteredProfiles =
          _allProfiles
              .where(
                (profile) =>
                    profile.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _selectCriteria(CriteriaProfile profile) {
    // Dispatch the event to save the selected criteria
    BlocProvider.of<CriteriaBloc>(context).add(SaveSelectedCriteria(profile));

    // Close the bottom sheet after selection
    Navigator.pop(context, profile);
  }

  Map<String, List<CriteriaProfile>> _groupProfiles(
    List<CriteriaProfile> profiles,
  ) {
    final Map<String, List<CriteriaProfile>> grouped = {};
    for (final profile in profiles) {
      final type = profile.type;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(profile);
    }
    return grouped;
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final groupedProfiles = _groupProfiles(_filteredProfiles);

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
      ),
      child:
          _loading
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 40),
                  Center(child: FastGifWidget()),
                  SizedBox(height: 40),
                ],
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomText(
                    text: 'Select Criteria',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ClrCons.whiteColor,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: searchController,
                    hintText: 'Search by name',
                    onChanged: _filter,
                    suffixIcon: ImgCons.searchIcon,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          groupedProfiles.entries.expand((entry) {
                            final type = entry.key;
                            final profiles = entry.value;

                            return [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: CustomText(
                                  text:
                                      type, // e.g., "Predefined", "Custom", "Hot Fishing"
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              ...profiles.map(
                                (profile) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomButtonTextField(
                                    isHeight: true,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Stack(
                                        children: [
                                          ListTile(
                                            title: CustomText(
                                              text: profile.name,
                                              color: ClrCons.whiteColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            subtitle: CustomText(
                                              text: '${profile.type}',
                                              color: ClrCons.whiteColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            onTap: () => _selectCriteria(profile),
                                          ),
                                          // Edit button in top right corner
                                          if (profile.type.toLowerCase() != 'predefined')
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                                                                     // Edit button
                                                   GestureDetector(
                                                     onTap: _editingCriteriaId == profile.id ? null : () async {
                                                       final criteriaState = context.read<CriteriaBloc>().state;
                                                       
                                                       if (criteriaState is CriteriaSelected &&
                                                           criteriaState.criteriaProfile.id == profile.id) {
                                                         globalSnack.showErrorSnackBar(
                                                           context,
                                                           'Cannot edit the selected criteria',
                                                         );
                                                         return;
                                                       }
                                                       
                                                                                                                if (mounted) {
                                                           setState(() {
                                                             _editingCriteriaId = profile.id;
                                                           });
                                                         }
                                                       
                                                       try {
                                                         final service = CriteriaService();
                                                         final criteriaData = await service.getCriteriaForEdit(
                                                           token: widget.authToken,
                                                           id: profile.id,
                                                           context: context,
                                                         );
                                                         
                                                         if (criteriaData != null && criteriaData.isNotEmpty) {
                                                           // Close the current bottom sheet
                                                           Navigator.pop(context);
                                                           
                                                           // Navigate to edit criteria screen
                                                           Navigator.push(
                                                             context,
                                                             MaterialPageRoute(
                                                               builder: (context) => CreateCriteriaScreen(
                                                                 token: widget.authToken,
                                                                 criteriaId: profile.id,
                                                                 existingData: criteriaData,
                                                                 isEditMode: true,
                                                               ),
                                                             ),
                                                           );
                                                           
                                                           // Refresh the profiles list after editing
                                                           if (mounted) {
                                                             _loadProfiles();
                                                           }
                                                         } else {
                                                           globalSnack.showErrorSnackBar(
                                                             context,
                                                             'No criteria data found to edit',
                                                           );
                                                         }
                                                       } catch (e) {
                                                         print('Error fetching criteria data: $e');
                                                         globalSnack.showErrorSnackBar(
                                                           context,
                                                           'Failed to load criteria data. Please try again.',
                                                         );
                                                                              } finally {
                         if (mounted) {
                           setState(() {
                             _editingCriteriaId = null;
                           });
                         }
                       }
                                                     },
                                                                                                         child: Container(
                                                       padding: EdgeInsets.all(8),
                                                       decoration: BoxDecoration(
                                                         color: _editingCriteriaId == profile.id 
                                                             ? Colors.grey.withOpacity(0.8)
                                                             : Colors.blue.withOpacity(0.8),
                                                         borderRadius: BorderRadius.circular(8),
                                                       ),
                                                       child: _editingCriteriaId == profile.id
                                                           ? SizedBox(
                                                               width: 16,
                                                               height: 16,
                                                               child: CircularProgressIndicator(
                                                                 strokeWidth: 2,
                                                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                               ),
                                                             )
                                                           : Icon(
                                                               Icons.edit,
                                                               color: Colors.white,
                                                               size: 16,
                                                             ),
                                                     ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  // Delete button
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final criteriaState = context.read<CriteriaBloc>().state;
                                                      
                                                      if (criteriaState is CriteriaSelected &&
                                                          criteriaState.criteriaProfile.id == profile.id) {
                                                        globalSnack.showErrorSnackBar(
                                                          context,
                                                          'Cannot delete the selected criteria',
                                                        );
                                                        return;
                                                      }
                                                      
                                                      final result = await showModalBottomSheet<bool>(
                                                        context: context,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.vertical(
                                                            top: Radius.circular(20),
                                                          ),
                                                        ),
                                                        backgroundColor: ClrCons.primaryColor,
                                                        builder: (context) {
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 24,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  Icons.warning,
                                                                  color: Colors.red,
                                                                  size: 40,
                                                                ),
                                                                SizedBox(height: 12),
                                                                Text(
                                                                  'You want to delete!',
                                                                  style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(height: 8),
                                                                Text(
                                                                  'This action cannot be undone.',
                                                                  style: TextStyle(
                                                                    color: Colors.white70,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(height: 20),
                                                                Row(
                                                                  children: [
                                                                    CustomButton(
                                                                      text: 'Cancel',
                                                                      width: SizeCons.getWidth(context) * 0.4,
                                                                      onPressed: () => Navigator.pop(context, false),
                                                                    ),
                                                                    SizedBox(width: 12),
                                                                    CustomButton(
                                                                      text: 'Delete',
                                                                      fillColor: [
                                                                        Color.fromARGB(255, 93, 18, 18),
                                                                        Color(0xFF00182E),
                                                                      ],
                                                                      width: SizeCons.getWidth(context) * 0.4,
                                                                      onPressed: () => Navigator.pop(context, true),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                      
                                                      if (result == true) {
                                                        final service = CriteriaService();
                                                        await service.deleteProfile(
                                                          widget.authToken,
                                                          profile.id,
                                                        );
                                                        setState(() {
                                                          _allProfiles.remove(profile);
                                                          _filteredProfiles.remove(profile);
                                                        });
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Deleted "${profile.name}"'),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.withOpacity(0.8),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }
}
