import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class PdfReportHelper {
  static Future<void> generateAndDownloadReport({
    required Map<String, dynamic> stats,
    required List<User> users,
    required List<Room> rooms,
    required List<Booking> bookings,
  }) async {
    final pdf = pw.Document();

    // Load Sarabun font to support both English and any Thai characters in database content.
    // Fall back to built-in Helvetica if offline or blocked.
    pw.Font fontRegular;
    pw.Font fontBold;
    bool isFallback = false;
    try {
      fontRegular = await PdfGoogleFonts.sarabunRegular();
      fontBold = await PdfGoogleFonts.sarabunBold();
    } catch (e) {
      print('Network error loading Sarabun font, falling back to Helvetica: $e');
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
      isFallback = true;
    }

    // Helper to sanitize strings when falling back to Helvetica, avoiding Latin-1 StateErrors
    String safeText(String? text) {
      if (text == null) return '';
      if (!isFallback) return text;
      final filtered = text.runes
          .where((rune) => rune <= 255)
          .map((rune) => String.fromCharCode(rune))
          .join('')
          .trim();
      return filtered.isEmpty ? 'N/A' : filtered;
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Rental Room System Summary Report',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900,
                    ),
                  ),
                  pw.Text(
                    dateFormat.format(DateTime.now()),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // Summary Section Title
            pw.Text(
              '1. System Overview & Statistics',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo700,
              ),
            ),
            pw.SizedBox(height: 10),

            // KPI Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Category',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total Value',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total System Users'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${stats['total_users'] ?? 0}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Rooms Listed'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${stats['total_rooms'] ?? 0}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Bookings Made'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${stats['total_bookings'] ?? 0}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Estimated Monthly Revenue'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '\$${stats['total_revenue']?.toStringAsFixed(2) ?? '0.00'}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // Bookings Section Title
            pw.Text(
              '2. Recent Bookings History',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo700,
              ),
            ),
            pw.SizedBox(height: 10),

            // Bookings Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Room Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Tenant Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Move In Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Status',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...bookings.map(
                  (booking) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(safeText(booking.room?.roomName ?? 'N/A')),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(safeText(booking.tenant?.name ?? 'N/A')),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          DateFormat('yyyy-MM-dd').format(booking.moveInDate),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          booking.bookingStatus.toUpperCase(),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: booking.bookingStatus == 'approved'
                                ? PdfColors.green700
                                : booking.bookingStatus == 'pending'
                                    ? PdfColors.orange700
                                    : PdfColors.red700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // Rooms Section Title
            pw.Text(
              '3. Room Directory & Inventory',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo700,
              ),
            ),
            pw.SizedBox(height: 10),

            // Rooms Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Room Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Monthly Rent',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Availability',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...rooms.map(
                  (room) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(safeText(room.roomName)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '\$${room.pricePerMonth.toStringAsFixed(0)}',
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          room.roomStatus.toUpperCase(),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: room.roomStatus == 'occupied'
                                ? PdfColors.red700
                                : PdfColors.green700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Open system layout dialog to Save as PDF / Download / Print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'rental_room_system_report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
