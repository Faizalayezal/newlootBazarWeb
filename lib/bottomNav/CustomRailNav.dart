// custom_rail_nav.dart — Ultra advanced hover rail
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomRailNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  const CustomRailNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
  });

  @override
  State<CustomRailNav> createState() => _CustomRailNavState();
}

class _CustomRailNavState extends State<CustomRailNav> {
  bool _expanded = false;
  int _hoveredIndex = -1;

  static const _destinations = [
    _RailDest(
      'assets/images/home.svg',
      'assets/images/home.svg',
      'Home',
    ),
    _RailDest(
      'assets/images/shop.svg',
      'assets/images/shop.svg',
      'Shop',
    ),
    _RailDest(
      'assets/images/add.svg',
     'assets/images/add.svg',
      'Sell',
      isFab: true,
    ),
    _RailDest(
      'assets/images/notification.svg',
      'assets/images/notification.svg',
      'Notification',
      badge: 3,
    ),
    _RailDest(
      'assets/images/profile.svg',
      'assets/images/profile.svg',
      'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      width: _expanded ? 220 : 72,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          right: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggleButton(scheme),
          const SizedBox(height: 24),
          ...List.generate(_destinations.length, (i) {
            return _buildRailItem(context, _destinations[i], i, scheme);
          }),
          const Spacer(),
          _buildProfileTile(scheme),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: _expanded
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (_expanded)
                Text('Menu', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                )),
              AnimatedRotation(
                turns: _expanded ? 0 : 0.5,
                duration: const Duration(milliseconds: 280),
                child: Icon(Icons.chevron_right, color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailItem(
      BuildContext context,
      _RailDest dest,
      int index,
      ColorScheme scheme,
      ) {
    final isSelected = widget.selectedIndex == index;
    final isHovered = _hoveredIndex == index;
    final isFab = dest.isFab;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(
          onTap: () => widget.onDestinationSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 48,
            decoration: BoxDecoration(
              color: isFab
                  ? const Color(0xFFF57C00)
                  : isSelected
                  ? scheme.primaryContainer
                  : isHovered
                  ? scheme.onSurface.withOpacity(0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Stack(clipBehavior: Clip.none, children: [
                    SvgPicture.asset(
                      dest.icon,
                      width: 22.w,
                      height: 22.h,
                      colorFilter: ColorFilter.mode(
                        isFab
                            ? Colors.white
                            : isSelected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface.withOpacity(0.6),
                        BlendMode.srcIn,
                      ),
                    ),
                    if (dest.badge > 0)
                      Positioned(
                        top: -4, right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${dest.badge}',
                            style: const TextStyle(
                              fontSize: 9, color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ]),
                  if (_expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _expanded ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          dest.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isFab
                                ? Colors.white
                                : isSelected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primary,
              child: Text('A', style: TextStyle(color: scheme.onPrimary, fontSize: 13)),
            ),
            if (_expanded) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alex Kumar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: scheme.onSurface)),
                    Text('alex@example.com', style: TextStyle(fontSize: 10, color: scheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _RailDest {
  final String icon;
  final String activeIcon;
  final String label;
  final bool isFab;
  final int badge;

  const _RailDest(
      this.icon,
      this.activeIcon,
      this.label, {
        this.isFab = false,
        this.badge = 0,
      });
}