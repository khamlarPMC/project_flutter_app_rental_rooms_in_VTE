import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../services/admin_service.dart';
import '../utils/app_constants.dart';
import '../utils/pdf_report_helper.dart' show PdfReportHelper, PdfReportType;

enum _ReportType { overview, users, rooms, bookings, full }

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final AdminService _adminService = AdminService();

  _ReportType _selected = _ReportType.overview;
  bool _isLoading = true;

  Map<String, dynamic>? _stats;
  List<User> _users = [];
  List<Room> _rooms = [];
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _adminService.getDashboardStats(),
      _adminService.getAllUsers(),
      _adminService.getAllRooms(),
      _adminService.getAllBookings(),
    ]);
    setState(() {
      _stats = results[0] as Map<String, dynamic>;
      _users = results[1] as List<User>;
      _rooms = results[2] as List<Room>;
      _bookings = results[3] as List<Booking>;
      _isLoading = false;
    });
  }

  PdfReportType get _pdfReportType {
    switch (_selected) {
      case _ReportType.users:
        return PdfReportType.users;
      case _ReportType.rooms:
        return PdfReportType.rooms;
      case _ReportType.bookings:
        return PdfReportType.bookings;
      case _ReportType.full:
        return PdfReportType.full;
      default:
        return PdfReportType.overview;
    }
  }

  Future<void> _downloadPdf() async {
    if (_stats == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Generating PDF report…',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      await PdfReportHelper.generateAndDownloadReport(
        stats: _stats!,
        users: _users,
        rooms: _rooms,
        bookings: _bookings,
        reportType: _pdfReportType,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error generating PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  // ─── Chips ───────────────────────────────────────────────
  Widget _reportChip(_ReportType type, String label, IconData icon) {
    final active = _selected == type;
    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Overview ────────────────────────────────────────────
  Widget _buildOverview() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statCard(
          'Total Users',
          '${_stats?['total_users'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _statCard(
          'Total Rooms',
          '${_stats?['total_rooms'] ?? 0}',
          Icons.meeting_room,
          Colors.green,
        ),
        _statCard(
          'Total Bookings',
          '${_stats?['total_bookings'] ?? 0}',
          Icons.book_online,
          Colors.orange,
        ),
        _statCard(
          'Revenue / Month',
          '\$${(_stats?['total_revenue'] ?? 0.0).toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: AppColors.backgroundCard,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Users ───────────────────────────────────────────────
  Widget _buildUsers() {
    if (_users.isEmpty) return const Center(child: Text('No users found'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('${_users.length} Users', Icons.people, Colors.blue),
        ..._users.map((u) {
          final roleName =
              u.role?.roleName ??
              (u.roleId == 3
                  ? 'Admin'
                  : u.roleId == 2
                  ? 'Owner'
                  : 'User');
          final roleColor = u.roleId == 3
              ? Colors.red
              : u.roleId == 2
              ? Colors.orange
              : Colors.blue;
          return Card(
            color: AppColors.backgroundCard,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: roleColor.withValues(alpha: 0.15),
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                u.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                u.email,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roleName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Rooms ───────────────────────────────────────────────
  Widget _buildRooms() {
    if (_rooms.isEmpty) return const Center(child: Text('No rooms found'));

    final available = _rooms.where((r) => r.roomStatus == 'available').length;
    final occupied = _rooms.where((r) => r.roomStatus == 'occupied').length;
    final pending = _rooms
        .where((r) => r.roomStatus == 'pending_deletion')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          '${_rooms.length} Rooms',
          Icons.meeting_room,
          Colors.green,
        ),
        // Summary chips
        Row(
          children: [
            _miniChip('Available $available', Colors.green),
            const SizedBox(width: 8),
            _miniChip('Occupied $occupied', Colors.orange),
            if (pending > 0) ...[
              const SizedBox(width: 8),
              _miniChip('Pending Del. $pending', Colors.red),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ..._rooms.map((r) {
          Color statusColor;
          String statusLabel;
          switch (r.roomStatus) {
            case 'occupied':
              statusColor = Colors.orange;
              statusLabel = 'Occupied';
              break;
            case 'pending_deletion':
              statusColor = Colors.red;
              statusLabel = 'Pending Del.';
              break;
            default:
              statusColor = Colors.green;
              statusLabel = 'Available';
          }
          return Card(
            color: AppColors.backgroundCard,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.12),
                child: Icon(Icons.meeting_room, color: statusColor, size: 20),
              ),
              title: Text(
                r.roomName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.address != null)
                    Text(
                      '${r.address!.village}, ${r.address!.district}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    'Owner: ${r.owner?.name ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${r.pricePerMonth.toStringAsFixed(0)}/mo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
    );
  }

  // ─── Bookings ────────────────────────────────────────────
  Widget _buildBookings() {
    if (_bookings.isEmpty)
      return const Center(child: Text('No bookings found'));

    final fmt = DateFormat('dd MMM yyyy');
    final confirmed = _bookings
        .where((b) => b.bookingStatus == 'confirmed')
        .length;
    final pending = _bookings.where((b) => b.bookingStatus == 'pending').length;
    final cancelled = _bookings
        .where((b) => b.bookingStatus == 'cancelled')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          '${_bookings.length} Bookings',
          Icons.book_online,
          Colors.orange,
        ),
        Row(
          children: [
            _miniChip('Confirmed $confirmed', Colors.green),
            const SizedBox(width: 8),
            _miniChip('Pending $pending', Colors.orange),
            const SizedBox(width: 8),
            _miniChip('Cancelled $cancelled', Colors.red),
          ],
        ),
        const SizedBox(height: 12),
        ..._bookings.map((b) {
          Color statusColor;
          switch (b.bookingStatus.toLowerCase()) {
            case 'confirmed':
              statusColor = Colors.green;
              break;
            case 'cancelled':
              statusColor = Colors.red;
              break;
            case 'expired':
              statusColor = Colors.grey;
              break;
            default:
              statusColor = Colors.orange;
          }
          return Card(
            color: AppColors.backgroundCard,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(Icons.person, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.tenant?.name ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          b.room?.roomName ?? 'Deleted Room',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${fmt.format(b.moveInDate)} → ${b.moveOutDate != null ? fmt.format(b.moveOutDate!) : '—'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      b.bookingStatus[0].toUpperCase() +
                          b.bookingStatus.substring(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFull() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverview(),
        const SizedBox(height: 24),
        const Divider(thickness: 1.5),
        const SizedBox(height: 16),
        _buildUsers(),
        const SizedBox(height: 24),
        const Divider(thickness: 1.5),
        const SizedBox(height: 16),
        _buildRooms(),
        const SizedBox(height: 24),
        const Divider(thickness: 1.5),
        const SizedBox(height: 16),
        _buildBookings(),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download PDF',
              onPressed: _downloadPdf,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ─── Filter navbar ───
                Container(
                  color: AppColors.backgroundCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _reportChip(
                              _ReportType.overview,
                              'Overview',
                              Icons.dashboard_outlined,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _reportChip(
                              _ReportType.users,
                              'Users',
                              Icons.people_outline,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _reportChip(
                              _ReportType.rooms,
                              'Rooms',
                              Icons.meeting_room_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _reportChip(
                              _ReportType.bookings,
                              'Bookings',
                              Icons.book_online_outlined,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: _reportChip(
                              _ReportType.full,
                              'Full Report',
                              Icons.summarize_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // ─── Content ────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchAll,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: () {
                        switch (_selected) {
                          case _ReportType.overview:
                            return _buildOverview();
                          case _ReportType.users:
                            return _buildUsers();
                          case _ReportType.rooms:
                            return _buildRooms();
                          case _ReportType.bookings:
                            return _buildBookings();
                          case _ReportType.full:
                            return _buildFull();
                        }
                      }(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
