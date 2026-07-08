import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

enum PdfReportType { overview, users, rooms, bookings, full }

class PdfReportHelper {
  static Future<void> generateAndDownloadReport({
    required Map<String, dynamic> stats,
    required List<User> users,
    required List<Room> rooms,
    required List<Booking> bookings,
    PdfReportType reportType = PdfReportType.overview,
  }) async {
    final pdf = pw.Document();

    pw.Font fontRegular;
    pw.Font fontBold;
    bool isFallback = false;
    try {
      fontRegular = await PdfGoogleFonts.sarabunRegular();
      fontBold    = await PdfGoogleFonts.sarabunBold();
    } catch (e) {
      fontRegular = pw.Font.helvetica();
      fontBold    = pw.Font.helveticaBold();
      isFallback  = true;
    }

    String safeText(String? text) {
      if (text == null) return '';
      if (!isFallback) return text;
      final filtered = text.runes
          .where((r) => r <= 255)
          .map((r) => String.fromCharCode(r))
          .join()
          .trim();
      return filtered.isEmpty ? 'N/A' : filtered;
    }

    final nowStr   = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final dateOnly = DateFormat('yyyy-MM-dd');

    // ─── shared header builder ───────────────────────────────
    pw.Widget _header(String title) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Rental Room System', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Text(nowStr,               style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
        pw.Divider(color: PdfColors.indigo200, thickness: 1),
        pw.SizedBox(height: 10),
      ],
    );

    pw.Widget _tableHeader(List<String> cols, List<pw.FlexColumnWidth> widths) =>
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
          columnWidths: { for (int i = 0; i < widths.length; i++) i: widths[i] },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
              children: cols.map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              )).toList(),
            ),
          ],
        );

    // ─────────────────────────────────────────────────────────
    switch (reportType) {

      // ── OVERVIEW ──────────────────────────────────────────
      case PdfReportType.overview:
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (ctx) => [
            _header('System Overview & Statistics'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: ['Category', 'Value'].map((c) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  )).toList(),
                ),
                _kpiRow('Total System Users',        '${stats['total_users'] ?? 0}'),
                _kpiRow('Total Rooms Listed',         '${stats['total_rooms'] ?? 0}'),
                _kpiRow('Total Bookings Made',        '${stats['total_bookings'] ?? 0}'),
                _kpiRow('Estimated Monthly Revenue', '\$${(stats['total_revenue'] ?? 0.0).toStringAsFixed(2)}',
                    valueColor: PdfColors.green700),
              ],
            ),
          ],
        ));
        break;

      // ── USERS ─────────────────────────────────────────────
      case PdfReportType.users:
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (ctx) => [
            _header('Users Report  (${users.length} total)'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.5),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: ['Name', 'Email', 'Phone', 'Role'].map((c) => pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  )).toList(),
                ),
                ...users.map((u) {
                  final roleName = u.role?.roleName ??
                      (u.roleId == 3 ? 'Admin' : u.roleId == 2 ? 'Owner' : 'User');
                  return pw.TableRow(children: [
                    _cell(safeText(u.name)),
                    _cell(safeText(u.email)),
                    _cell(safeText(u.phone ?? '—')),
                    _cell(roleName),
                  ]);
                }),
              ],
            ),
          ],
        ));
        break;

      // ── ROOMS ─────────────────────────────────────────────
      case PdfReportType.rooms:
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (ctx) => [
            _header('Rooms Report  (${rooms.length} total)'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.5),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: ['Room Name', 'Owner', 'Price/mo', 'Status'].map((c) => pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  )).toList(),
                ),
                ...rooms.map((r) {
                  PdfColor statusColor;
                  switch (r.roomStatus) {
                    case 'occupied':         statusColor = PdfColors.orange700; break;
                    case 'pending_deletion': statusColor = PdfColors.red700;    break;
                    default:                 statusColor = PdfColors.green700;
                  }
                  return pw.TableRow(children: [
                    _cell(safeText(r.roomName)),
                    _cell(safeText(r.owner?.name ?? '—')),
                    _cell('\$${r.pricePerMonth.toStringAsFixed(0)}'),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(7),
                      child: pw.Text(
                        r.roomStatus.toUpperCase().replaceAll('_', ' '),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: statusColor, fontSize: 9),
                      ),
                    ),
                  ]);
                }),
              ],
            ),
          ],
        ));
        break;

      // ── FULL ──────────────────────────────────────────────
      case PdfReportType.full:
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (ctx) => [
            _header('Full System Report'),

            // 1. Overview
            pw.Text('1. System Overview', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              children: [
                pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.indigo50), children: ['Category', 'Value'].map((c) => pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)))).toList()),
                _kpiRow('Total System Users',       '${stats['total_users'] ?? 0}'),
                _kpiRow('Total Rooms Listed',        '${stats['total_rooms'] ?? 0}'),
                _kpiRow('Total Bookings Made',       '${stats['total_bookings'] ?? 0}'),
                _kpiRow('Estimated Monthly Revenue','\$${(stats['total_revenue'] ?? 0.0).toStringAsFixed(2)}', valueColor: PdfColors.green700),
              ],
            ),
            pw.SizedBox(height: 20),

            // 2. Users
            pw.Text('2. Users  (${users.length} total)', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: const { 0: pw.FlexColumnWidth(2.5), 1: pw.FlexColumnWidth(3), 2: pw.FlexColumnWidth(1.5), 3: pw.FlexColumnWidth(1.5) },
              children: [
                pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.indigo50), children: ['Name', 'Email', 'Phone', 'Role'].map((c) => pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)))).toList()),
                ...users.map((u) {
                  final roleName = u.role?.roleName ?? (u.roleId == 3 ? 'Admin' : u.roleId == 2 ? 'Owner' : 'User');
                  return pw.TableRow(children: [_cell(safeText(u.name)), _cell(safeText(u.email)), _cell(safeText(u.phone ?? '—')), _cell(roleName)]);
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // 3. Rooms
            pw.Text('3. Rooms  (${rooms.length} total)', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: const { 0: pw.FlexColumnWidth(2.5), 1: pw.FlexColumnWidth(2), 2: pw.FlexColumnWidth(1.5), 3: pw.FlexColumnWidth(1.5) },
              children: [
                pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.indigo50), children: ['Room Name', 'Owner', 'Price/mo', 'Status'].map((c) => pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)))).toList()),
                ...rooms.map((r) {
                  PdfColor sc = r.roomStatus == 'occupied' ? PdfColors.orange700 : r.roomStatus == 'pending_deletion' ? PdfColors.red700 : PdfColors.green700;
                  return pw.TableRow(children: [_cell(safeText(r.roomName)), _cell(safeText(r.owner?.name ?? '—')), _cell('\$${r.pricePerMonth.toStringAsFixed(0)}'), pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(r.roomStatus.toUpperCase().replaceAll('_', ' '), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: sc, fontSize: 9)))]);
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // 4. Bookings
            pw.Text('4. Bookings  (${bookings.length} total)', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: const { 0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(2), 2: pw.FlexColumnWidth(1.8), 3: pw.FlexColumnWidth(1.8), 4: pw.FlexColumnWidth(1.5) },
              children: [
                pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.indigo50), children: ['Tenant', 'Room', 'Move-in', 'Move-out', 'Status'].map((c) => pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)))).toList()),
                ...bookings.map((b) {
                  PdfColor sc = b.bookingStatus == 'confirmed' ? PdfColors.green700 : b.bookingStatus == 'cancelled' ? PdfColors.red700 : PdfColors.orange700;
                  return pw.TableRow(children: [_cell(safeText(b.tenant?.name ?? 'N/A')), _cell(safeText(b.room?.roomName ?? 'Deleted')), _cell(dateOnly.format(b.moveInDate)), _cell(b.moveOutDate != null ? dateOnly.format(b.moveOutDate!) : '—'), pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(b.bookingStatus.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: sc, fontSize: 9)))]);
                }),
              ],
            ),
          ],
        ));
        break;

      // ── BOOKINGS ──────────────────────────────────────────
      case PdfReportType.bookings:
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (ctx) => [
            _header('Bookings Report  (${bookings.length} total)'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(1.8),
                3: pw.FlexColumnWidth(1.8),
                4: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: ['Tenant', 'Room', 'Move-in', 'Move-out', 'Status'].map((c) => pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  )).toList(),
                ),
                ...bookings.map((b) {
                  PdfColor statusColor;
                  switch (b.bookingStatus.toLowerCase()) {
                    case 'confirmed': statusColor = PdfColors.green700;  break;
                    case 'cancelled': statusColor = PdfColors.red700;    break;
                    default:          statusColor = PdfColors.orange700;
                  }
                  return pw.TableRow(children: [
                    _cell(safeText(b.tenant?.name ?? 'N/A')),
                    _cell(safeText(b.room?.roomName ?? 'Deleted')),
                    _cell(dateOnly.format(b.moveInDate)),
                    _cell(b.moveOutDate != null ? dateOnly.format(b.moveOutDate!) : '—'),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(7),
                      child: pw.Text(
                        b.bookingStatus.toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: statusColor, fontSize: 9),
                      ),
                    ),
                  ]);
                }),
              ],
            ),
          ],
        ));
        break;
    }

    final reportName = reportType.name;
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'rental_room_${reportName}_report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.TableRow _kpiRow(String label, String value, {PdfColor? valueColor}) =>
      pw.TableRow(children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value,
              style: pw.TextStyle(
                fontWeight: valueColor != null ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: valueColor,
              )),
        ),
      ]);

  static pw.Widget _cell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
  );
}
