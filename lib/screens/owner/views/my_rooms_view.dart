import 'package:flutter/material.dart';
import 'package:app_rental_room/models/room_model.dart';
import 'package:app_rental_room/services/room_service.dart';
import 'package:app_rental_room/widgets/owner_room_card.dart';
import 'package:app_rental_room/screens/detail_user_screen.dart';
import 'package:app_rental_room/screens/login_screen.dart';
import 'package:app_rental_room/l10n/app_localizations.dart';
import 'package:app_rental_room/utils/app_constants.dart';

class MyRoomsView extends StatefulWidget {
  const MyRoomsView({super.key});

  @override
  State<MyRoomsView> createState() => _MyRoomsViewState();
}

class _MyRoomsViewState extends State<MyRoomsView> {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyRooms();
  }

  Future<void> _fetchMyRooms() async {
    setState(() => _isLoading = true);
    final rooms = await _roomService.getMyRooms();
    setState(() {
      _rooms = rooms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('myRooms')),
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
                  builder: (context) =>
                      const DetailUserScreen(initialRole: 'Owner'),
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
        onRefresh: _fetchMyRooms,
        child: _isLoading
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : _rooms.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('noRoomsYet'),
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('addFirstRoom'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  return OwnerRoomCard(
                    room: _rooms[index],
                    onRefresh: _fetchMyRooms,
                  );
                },
              ),
      ),
    );
  }
}
