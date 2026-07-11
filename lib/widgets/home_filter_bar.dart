import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../utils/district_villages.dart';
import '../utils/app_constants.dart';

class HomeFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> districts;
  final List<String> villages;
  final String? selectedDistrict;
  final String? selectedVillage;
  final Function(String) onSearchChanged;
  final Function(String?) onDistrictChanged;
  final Function(String?) onVillageChanged;

  const HomeFilterBar({
    super.key,
    required this.searchController,
    required this.districts,
    required this.villages,
    required this.selectedDistrict,
    required this.selectedVillage,
    required this.onSearchChanged,
    required this.onDistrictChanged,
    required this.onVillageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isLao = LanguageProvider.instance.isLao;

    return Column(
      children: [
        // Search Box
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 8,
            top: 4,
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: l.tr('searchForRooms'),
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.backgroundCard,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // District & Village Dropdowns
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              // District Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedDistrict,
                      dropdownColor: AppColors.backgroundCard,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l.tr('allDistricts'),
                            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...districts.map((String district) {
                          return DropdownMenuItem<String?>(
                            value: district,
                            child: Text(
                              getDistrictDisplay(district, isLao),
                              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: onDistrictChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Village Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      key: ValueKey('village_$selectedDistrict'),
                      value: selectedVillage,
                      dropdownColor: AppColors.backgroundCard,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l.tr('allVillages'),
                            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...villages.map((String village) {
                          return DropdownMenuItem<String?>(
                            value: village,
                            child: Text(
                              getVillageDisplay(village, isLao),
                              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: onVillageChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
