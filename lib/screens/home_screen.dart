import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../widgets/home_filter_bar.dart';
import '../widgets/room_list_view.dart';
import '../utils/district_villages.dart';
import 'login_screen.dart';
import 'detail_user_screen.dart';
import '../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoomService _roomService = RoomService();
  final TextEditingController _searchController = TextEditingController();
  List<Room> _rooms = [];
  bool _isLoading = true;

  String? _selectedDistrict; // null = All Districts
  String? _selectedVillage;  // null = All Villages
  String _searchQuery = '';

  List<String> get _districts => districtVillages.keys.toList();

  List<String> get _villageOptions {
    if (_selectedDistrict == null) {
      final allVillages = districtVillages.values
          .expand((villages) => villages)
          .toSet()
          .toList();
      allVillages.sort();
      return allVillages;
    }
    return districtVillages[_selectedDistrict] ?? [];
  }

  List<Room> get _filteredRooms {
    final query = _searchQuery.toLowerCase().trim();

    return _rooms.where((room) {
      final address = room.address;
      final district = address?.district?.toLowerCase() ?? '';
      final village = address?.village?.toLowerCase() ?? '';
      final roomName = room.roomName.toLowerCase();
      final description = room.description?.toLowerCase() ?? '';

      final matchesSearch =
          query.isEmpty ||
          roomName.contains(query) ||
          description.contains(query) ||
          district.contains(query) ||
          village.contains(query);

      final matchesDistrict =
          _selectedDistrict == null ||
          district == _selectedDistrict!.toLowerCase();

      final matchesVillage =
          _selectedVillage == null ||
          village == _selectedVillage!.toLowerCase();

      return matchesSearch && matchesDistrict && matchesVillage;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _roomService.getAllRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching rooms: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Rental Room'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailUserScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRooms,
        child: Column(
          children: [
            HomeFilterBar(
              searchController: _searchController,
              districts: _districts,
              villages: _villageOptions,
              selectedDistrict: _selectedDistrict,
              selectedVillage: _selectedVillage,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onDistrictChanged: (newValue) {
                setState(() {
                  _selectedDistrict = newValue;
                  _selectedVillage = null;
                });
              },
              onVillageChanged: (newValue) {
                setState(() {
                  _selectedVillage = newValue;
                });
              },
            ),
            RoomListView(rooms: _filteredRooms, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
