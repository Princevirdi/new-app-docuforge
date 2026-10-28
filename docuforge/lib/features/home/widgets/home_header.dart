import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.onProfileTap, super.key});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF536DFE),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.auto_awesome_mosaic_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'docu',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontSize: 20, letterSpacing: -0.7),
        ),
        Text(
          'forge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF536DFE),
            fontSize: 20,
            letterSpacing: -0.7,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onProfileTap,
          tooltip: 'Profile',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF536DFE),
          ),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }
}
