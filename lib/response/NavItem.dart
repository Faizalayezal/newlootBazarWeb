class NavItem {
  final String icon;
  final String label;
  final bool badge;

  const NavItem(
      this.icon,
      this.label, {
        this.badge = false,
      });

  static const List<NavItem?> items = [
    NavItem(
      'assets/images/home.svg',
      'Home',
    ),
    NavItem(
      'assets/images/shop.svg',
      'Shop',
    ),

    // Center FAB Space
    null,

    NavItem(
      'assets/images/notification.svg',
      'Notification',
      badge: true,
    ),
    NavItem(
      'assets/images/profile.svg',
      'Profile',
    ),
  ];
}