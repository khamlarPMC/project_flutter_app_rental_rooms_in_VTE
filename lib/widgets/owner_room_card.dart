import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../screens/edit_room_screen.dart';
import '../services/room_service.dart';
import '../l10n/app_localizations.dart';

class OwnerRoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback? onRefresh;

  const OwnerRoomCard({super.key, required this.room, this.onRefresh});

  @override
  State<OwnerRoomCard> createState() => _OwnerRoomCardState();
}

class _OwnerRoomCardState extends State<OwnerRoomCard> {
  int _currentImageIndex = 0;
  final RoomService _roomService = RoomService();

  Future<void> _confirmEdit() async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tr('edit')),
        content: Text(l.tr('doYouWantToEdit')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(l.tr('edit')),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRoomScreen(room: widget.room),
        ),
      );
      if (result == true && widget.onRefresh != null) widget.onRefresh!();
    }
  }

  Future<void> _requestDelete() async {
    if (!mounted) return;
    try {
      final isPendingDeletion =
          widget.room.roomStatus.toLowerCase() == 'pending_deletion';

      final l = AppLocalizations.of(context);
      if (isPendingDeletion) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.tr('alreadyPending')),
            content: Text(l.tr('alreadyPendingMsg')),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A373),
                  foregroundColor: Colors.white,
                ),
                child: Text(l.tr('ok')),
              ),
            ],
          ),
        );
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.tr('requestRoomDeletion')),
          content: Text(l.tr('deletionRequestSentMsg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l.tr('sendRequest')),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        try {
          await _roomService.requestDeletion(widget.room.roomId!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).tr('deletionRequestSent')),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
            widget.onRefresh?.call();
          }
        } catch (e) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(AppLocalizations.of(context).tr('requestFailed')),
                content: Text(e.toString()),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context).tr('ok')),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('_requestDelete unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final int totalImages = room.images != null && room.images!.isNotEmpty
        ? room.images!.length
        : 1;
    final bool isAvailable = room.roomStatus.toLowerCase() == 'available';
    final bool isPendingDeletion =
        room.roomStatus.toLowerCase() == 'pending_deletion';

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image Carousel
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  itemCount: totalImages,
                  onPageChanged: (idx) =>
                      setState(() => _currentImageIndex = idx),
                  itemBuilder: (context, idx) {
                    if (room.images != null && room.images!.isNotEmpty) {
                      return CachedNetworkImage(
                        imageUrl: room.images![idx].fullImageUrl,
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
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
                // Indicator dots
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalImages,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == idx ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == idx
                              ? const Color(0xFFD4A373)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                // Pending Deletion badge
                if (isPendingDeletion)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 14,
                            color: Colors.red.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('pendingDeletion'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // Pending Approval badge
                else if (!room.isApproved)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 14,
                            color: Colors.orange.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('pendingApproval'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Status badge (top right)
                if (!isPendingDeletion)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAvailable
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                        ),
                      ),
                      child: Text(
                        isAvailable ? context.tr('available') : context.tr('occupied'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Room Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        room.roomName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${room.pricePerMonth.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4A373),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room.address != null
                          ? '${room.address!.village}, ${room.address!.district}'
                          : context.tr('notSet'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                // Pending deletion notice
                if (isPendingDeletion) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('deletionRequestSent'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Disable Edit while pending deletion
                    TextButton.icon(
                      onPressed: isPendingDeletion ? null : _confirmEdit,
                      icon: Icon(
                        Icons.edit,
                        color: isPendingDeletion ? Colors.grey : Colors.blue,
                      ),
                      label: Text(
                        context.tr('edit'),
                        style: TextStyle(
                          color: isPendingDeletion ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _requestDelete,
                      icon: Icon(
                        isPendingDeletion
                            ? Icons.hourglass_empty
                            : Icons.delete,
                        color: Colors.red,
                      ),
                      label: Text(
                        isPendingDeletion ? context.tr('pendingDots') : context.tr('delete'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
