import 'package:flutter/material.dart';
import 'package:app_rental_room/models/room_model.dart';
import 'package:app_rental_room/services/room_service.dart';
import 'package:app_rental_room/widgets/owner_room_card.dart';
import 'package:app_rental_room/screens/detail_user_screen.dart';
import 'package:app_rental_room/screens/login_screen.dart';
import 'package:app_rental_room/l10n/app_localizations.dart';

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
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        title: Text(context.tr('myRooms')),
        backgroundColor: const Color(0xFFD4A373),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailUserScreen(initialRole: 'Owner'),
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
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('noRoomsYet'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('addFirstRoom'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black38,
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
