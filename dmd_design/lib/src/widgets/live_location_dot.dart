import 'package:flutter/material.dart';

/// Classic "blue dot" live-location marker (Google Maps / Uber style): a
/// soft halo behind a solid, white-ringed dot. Used for whichever party is
/// actually moving right now — the courier, on the client's map.
class DmdLiveLocationDot extends StatelessWidget {
  final Color color;
  final double size;

  const DmdLiveLocationDot({super.key, this.color = const Color(0xFF2F6FED), this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.2,
      height: size * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 2.2,
            height: size * 2.2,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
