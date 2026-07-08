import 'package:flutter/material.dart';

class HomeFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> districts;
  final List<String> villages;
  final String selectedDistrict;
  final String selectedVillage;
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
    return Column(
      children: [
        // Search Box Container
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
              hintText: 'Search for rooms, locations...',
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
        // Filters Container (Districts & Villages)
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
                    child: DropdownButton<String>(
                      value: selectedDistrict,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFFD4A373),
                      ),
                      items: districts.map((String district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(
                            district,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
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
                    child: DropdownButton<String>(
                      value: selectedVillage,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFFD4A373),
                      ),
                      items: villages.map((String village) {
                        return DropdownMenuItem<String>(
                          value: village,
                          child: Text(
                            village,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
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
