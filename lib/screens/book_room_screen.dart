import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../services/room_service.dart';
import '../services/booking_service.dart';
import '../l10n/app_localizations.dart';

class BookRoomScreen extends StatefulWidget {
  final Room room;
  final Booking? booking; // If provided, we are in Edit Mode

  const BookRoomScreen({super.key, required this.room, this.booking});

  @override
  State<BookRoomScreen> createState() => _BookRoomScreenState();
}

class _BookRoomScreenState extends State<BookRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoomService _roomService = RoomService();
  final BookingService _bookingService = BookingService();
  bool _isSubmitting = false;

  DateTime? _selectedDate; // Move-in
  DateTime? _moveOutDate;
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize if in Edit Mode
    if (widget.booking != null) {
      _selectedDate = widget.booking!.moveInDate;
      _moveOutDate = widget.booking!.moveOutDate;
      _durationController.text = widget.booking!.totalMonths.toString();
      // Message is not currently in the model, but we could add it if needed
    }
  }

  @override
  void dispose() {
    _durationController.dispose();

    super.dispose();
  }

  Future<void> _selectMoveInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _buildDatePickerTheme(context, child!),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (_moveOutDate != null && _moveOutDate!.isBefore(_selectedDate!)) {
          _moveOutDate = null;
          _durationController.clear();
        } else {
          _calculateAndSetDuration();
        }
      });
    }
  }

  Future<void> _selectMoveOutDate(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('pleaseSelectMoveInFirst'))),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _moveOutDate ?? _selectedDate!.add(const Duration(days: 30)),
      firstDate: _selectedDate!.add(const Duration(days: 1)),
      lastDate: _selectedDate!.add(const Duration(days: 1825)), // Up to 5 years
      builder: (context, child) => _buildDatePickerTheme(context, child!),
    );

    if (picked != null && picked != _moveOutDate) {
      setState(() {
        _moveOutDate = picked;
        _calculateAndSetDuration();
      });
    }
  }

  void _calculateAndSetDuration() {
    if (_selectedDate != null && _moveOutDate != null) {
      int months =
          (_moveOutDate!.year - _selectedDate!.year) * 12 +
          (_moveOutDate!.month - _selectedDate!.month);
      _durationController.text = months > 0 ? months.toString() : '1';
    }
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD4A373),
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String roomName = widget.room.roomName;
    final double roomPrice = widget.room.pricePerMonth;
    final bool isEditMode = widget.booking != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        title: Text(isEditMode ? context.tr('editBooking') : context.tr('bookThisRoom')),
        backgroundColor: const Color(0xFFD4A373),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room Summary Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            widget.room.images != null &&
                                widget.room.images!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.room.images!.first.fullImageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFD4A373),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                              )
                            : Icon(
                                Icons.image,
                                color: Colors.grey.shade500,
                                size: 32,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$$roomPrice / month',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A373),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Move-in Date
              Text(
                context.tr('moveInDate'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectMoveInDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? context.tr('selectADate')
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Move-out Date
              Text(
                context.tr('moveOutDate'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectMoveOutDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _moveOutDate == null
                            ? context.tr('selectADate')
                            : '${_moveOutDate!.day}/${_moveOutDate!.month}/${_moveOutDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _moveOutDate == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Duration
              Text(
                context.tr('durationMonths'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: context.tr('autoCalculated'),
                  prefixIcon: const Icon(Icons.timer_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? context.tr('pleaseSelectDates')
                    : null,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() &&
                            _selectedDate != null &&
                            _moveOutDate != null) {
                          setState(() => _isSubmitting = true);

                          bool success;
                          if (isEditMode) {
                            final result = await _bookingService
                                .updateBooking(widget.booking!.bookingId!, {
                                  'move_in_date': _selectedDate!
                                      .toIso8601String()
                                      .split('T')[0],
                                  'move_out_date': _moveOutDate!
                                      .toIso8601String()
                                      .split('T')[0],
                                  'total_months': int.parse(
                                    _durationController.text,
                                  ),
                                });
                            success = result['success'] == true;
                          } else {
                            success = await _roomService.bookRoom(
                              widget.room.roomId!,
                              _selectedDate!,
                              _moveOutDate!,
                              int.parse(_durationController.text),
                            );
                          }

                          setState(() => _isSubmitting = false);

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditMode
                                        ? context.tr('bookingUpdatedSuccess')
                                        : context.tr('bookingRequestSentSuccess'),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(
                                context,
                                true,
                              ); // Return true to indicate change
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('operationFailed')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else if (_selectedDate == null ||
                            _moveOutDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('pleaseSelectBothDates')),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A373),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditMode ? context.tr('updateBookingBtn') : context.tr('confirmBookingBtn'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
