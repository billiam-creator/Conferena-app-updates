import 'package:flutter/material.dart';
import 'package:ticketkona/services/event.dart';
import 'package:ticketkona/services/feedback_service.dart';
import 'package:ticketkona/theme/colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';

class ScanCode extends StatefulWidget {
  final Map event;
  final String token;
  final String eventToken;

  const ScanCode({
    super.key,
    required this.event,
    required this.token,
    required this.eventToken,
  });

  @override
  State<ScanCode> createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode>
    with SingleTickerProviderStateMixin {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  bool? valid;
  bool? alreadyUsed;
  bool validating = false;
  String? scanCount;
  String? bookingCount;
  String? lastScannedCode;

  // Result panel slide animation
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    final count = widget.event['bookings_count'] ??
        widget.event['tickets_sold'] ??
        widget.event['total_bookings'];
    bookingCount = count != null ? count.toString() : '0';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    controller?.dispose();
    super.dispose();
  }

  void _showResult() => _animController.forward(from: 0);

  void _resetScan() {
    setState(() {
      valid = null;
      alreadyUsed = null;
      validating = false;
      scanCount = null;
      lastScannedCode = null;
    });
    _animController.reverse();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final eventName =
        widget.event['event_name'] ?? widget.event['name'] ?? 'Event';
    final location =
        widget.event['event_location'] ?? widget.event['location'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Stack(
          children: [

            // ── Main column ────────────────────────────────────────────────
            Column(
              children: [

                // Top bar
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: 8),
                  child: Row(
                    children: [
                      _NavButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        label: 'Back',
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _NavButton(
                        icon: Icons.refresh_rounded,
                        label: 'Resume',
                        onTap: _resetScan,
                      ),
                    ],
                  ),
                ),

                // Event info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                  child: Column(
                    children: [
                      Text(
                        eventName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw / 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on,
                                size: 13, color: Colors.white54),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                location,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: CustomColors.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  CustomColors.primaryColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people,
                                size: 13,
                                color: CustomColors.primaryColor),
                            const SizedBox(width: 5),
                            Text(
                              '$bookingCount bookings',
                              style: TextStyle(
                                color: CustomColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.02),

                // Scan hint
                Text(
                  'Point camera at QR code',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: sw / 28,
                  ),
                ),

                SizedBox(height: sh * 0.015),

                // QR Viewfinder
                Expanded(
                  child: Stack(
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                      _ScanOverlay(size: sw * 0.65),
                      if (validating)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Validating...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sw / 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.015),
              ],
            ),

            // ── Sliding result panel ───────────────────────────────────────
            if (valid != null || alreadyUsed != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _ResultPanel(
                    valid: valid,
                    alreadyUsed: alreadyUsed,
                    scanCount: scanCount,
                    scannedCode: lastScannedCode,
                    onResume: _resetScan,
                    screenWidth: sw,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && !validating) {
        ctrl.pauseCamera();
        setState(() {
          valid = null;
          alreadyUsed = null;
          validating = true;
          scanCount = null;
          lastScannedCode = scanData.code;
        });

        try {
          final value =
              await validateTicket(widget.eventToken, scanData.code!);

          if (value['status'] == 200) {
            var data;
            try {
              data = jsonDecode(value['data']);
            } catch (_) {
              data = value['data'];
            }

            final int count =
                int.tryParse(data['scan_count'].toString()) ?? 0;

            if (count == 1) {
              setState(() {
                validating = false;
                valid = true;
                alreadyUsed = false;
                scanCount = data['scan_count'].toString();
              });
              await FeedbackService.onValid();        // ✅ sound + vibration
            } else {
              setState(() {
                validating = false;
                valid = false;
                alreadyUsed = true;
                scanCount = data['scan_count'].toString();
              });
              await FeedbackService.onAlreadyUsed(); // ✅ sound + vibration
            }
          } else {
            setState(() {
              valid = false;
              alreadyUsed = false;
              validating = false;
            });
            await FeedbackService.onInvalid();       // ✅ sound + vibration
          }
          _showResult();
        } catch (e) {
          setState(() => validating = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Network error. Please try again.'),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    });
  }

  Future<Map> validateTicket(String token, String code) async {
    return await EventService().validateTicket(token, code);
  }
}

// ── Nav button ────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 15),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── Scan overlay ──────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  final double size;
  const _ScanOverlay({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(size: size),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double size;
  const _OverlayPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final half = size / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: size, height: size),
        const Radius.circular(12),
      ))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    final bracketPaint = Paint()
      ..color = const Color(0xFF01875f)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const bracketLen = 24.0;
    final left   = cx - half;
    final top    = cy - half;
    final right  = cx + half;
    final bottom = cy + half;
    const r = 12.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(left + r + bracketLen, top)
        ..lineTo(left + r, top)
        ..arcToPoint(Offset(left, top + r), radius: const Radius.circular(r))
        ..lineTo(left, top + r + bracketLen),
      bracketPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(right - r - bracketLen, top)
        ..lineTo(right - r, top)
        ..arcToPoint(Offset(right, top + r),
            radius: const Radius.circular(r), clockwise: false)
        ..lineTo(right, top + r + bracketLen),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - r - bracketLen)
        ..lineTo(left, bottom - r)
        ..arcToPoint(Offset(left + r, bottom),
            radius: const Radius.circular(r), clockwise: false)
        ..lineTo(left + r + bracketLen, bottom),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - r - bracketLen)
        ..lineTo(right, bottom - r)
        ..arcToPoint(Offset(right - r, bottom),
            radius: const Radius.circular(r))
        ..lineTo(right - r - bracketLen, bottom),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Result panel ──────────────────────────────────────────────────────────────
class _ResultPanel extends StatelessWidget {
  final bool? valid;
  final bool? alreadyUsed;
  final String? scanCount;
  final String? scannedCode;
  final VoidCallback onResume;
  final double screenWidth;

  const _ResultPanel({
    required this.valid,
    required this.alreadyUsed,
    required this.scanCount,
    required this.scannedCode,
    required this.onResume,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;

    if (valid == true) {
      bgColor   = const Color(0xFF1A7A4A);
      iconColor = const Color(0xFF4ADE80);
      icon      = Icons.check_circle_rounded;
      title     = 'Valid Ticket';
      subtitle  = 'Attendee checked in successfully';
    } else if (alreadyUsed == true) {
      bgColor   = const Color(0xFF7A5A1A);
      iconColor = const Color(0xFFFBBF24);
      icon      = Icons.warning_amber_rounded;
      title     = 'Already Used';
      subtitle  = 'This ticket is already checked in...';
    } else {
      bgColor   = const Color(0xFF7A1A1A);
      iconColor = const Color(0xFFF87171);
      icon      = Icons.cancel_rounded;
      title     = 'Invalid Ticket';
      subtitle  = 'This ticket is not valid for this event';
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (scanCount != null || scannedCode != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (scannedCode != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Booking Code',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          Text(
                            scannedCode!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (scanCount != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Scan count',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        Text(
                          scanCount!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onResume,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text(
                'Scan Next Ticket',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}