import 'package:flutter/material.dart';
import 'package:inventaris_app/notifiers/navbar_notifiers.dart';
import 'package:inventaris_app/route_destination.dart';

class NavbarWidget extends StatefulWidget {
  final String role;

  const NavbarWidget({super.key, required this.role});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: navIndexNotifier.value,
      onTap: (index) {
        switch (index) {
          case 0:
            RouteDestination.GoToHome(context, role: widget.role);
            break;
          case 1:
            RouteDestination.GoToInventory(context, role: widget.role);
            break;
          case 2:
            RouteDestination.GoToSetting(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
      ],
    );
  }
}
