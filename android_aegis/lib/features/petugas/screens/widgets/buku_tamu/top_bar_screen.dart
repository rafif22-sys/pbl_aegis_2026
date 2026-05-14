import 'package:flutter/material.dart';

class TopBarScreen extends StatelessWidget {
  const TopBarScreen({super.key});

  static const String logoUrl =
      'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/new_logo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // LOGO
          Image.network(
            logoUrl,
            height: 44,
            width: 92,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.security,
                color: Colors.lightBlueAccent,
                size: 36,
              );
            },
          ),

          const SizedBox(width: 10),

          // TEXT (ANTI OVERFLOW FIX)
          const Expanded(
            child: Text(
              'ADVANCED EMERGENCY & GUARD INFORMATION SYSTEM',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
