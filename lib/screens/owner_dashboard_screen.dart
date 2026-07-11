import 'package:flutter/material.dart';
import 'package:app_rental_room/screens/home_screen.dart';
import 'package:app_rental_room/screens/add_listing_screen.dart';
import 'package:app_rental_room/screens/owner/views/my_rooms_view.dart';
import 'package:app_rental_room/screens/owner/views/bookings_view.dart';
import 'package:app_rental_room/l10n/app_localizations.dart';
import '../utils/app_constants.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_currentIndex) {
      case 0:
        currentView = const HomeScreen();
        break;
      case 1:
        currentView = const MyRoomsView();
        break;
      case 2:
        currentView = const BookingsView();
        break;
      default:
        currentView = const HomeScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: currentView,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.backgroundCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.tr('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_work),
              label: context.tr('myRooms'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book_online),
              label: context.tr('bookings'),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddListingScreen(),
                  ),
                );
                // If a new room was added, refresh the list
                if (result == true && mounted) {
                  setState(() {}); // Re-build to refresh MyRoomsView
                }
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(context.tr('addRoom')),
            )
          : null,
    );
  }
}
