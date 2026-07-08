import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../utils/district_villages.dart';

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
          color: const Color(0xFFD4A373),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 8,
            top: 4,
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: l.tr('searchForRooms'),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
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
          color: const Color(0xFFD4A373),
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              // District Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedDistrict,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFFD4A373),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l.tr('allDistricts'),
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...districts.map((String district) {
                          return DropdownMenuItem<String?>(
                            value: district,
                            child: Text(
                              getDistrictDisplay(district, isLao),
                              style: const TextStyle(fontSize: 14),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      key: ValueKey('village_$selectedDistrict'),
                      value: selectedVillage,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFFD4A373),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l.tr('allVillages'),
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...villages.map((String village) {
                          return DropdownMenuItem<String?>(
                            value: village,
                            child: Text(
                              getVillageDisplay(village, isLao),
                              style: const TextStyle(fontSize: 14),
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
