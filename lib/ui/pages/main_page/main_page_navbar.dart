import 'package:flutter/material.dart';

class MainPageNavbar extends StatefulWidget {
  final int selectedInt;
  final Function(int) onNavigationChange;
  final Function() onAddPressed;
  const MainPageNavbar({required this.selectedInt, required this.onAddPressed, required this.onNavigationChange, super.key});

  @override
  State<MainPageNavbar> createState() => _MainPageNavbarState();
}

class _MainPageNavbarState extends State<MainPageNavbar> {
  @override
  Widget build(BuildContext context) {
    const items = [
      {"label": "Home", "icon": Icons.home_rounded},
      {"label": "Cal", "icon": Icons.calendar_today_rounded},
      {"label": "Add", "icon": Icons.add_rounded},
      {"label": "Stats", "icon": Icons.bar_chart_rounded},
      {"label": "Body", "icon": Icons.monitor_weight_rounded},
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                i ==
                        2 // "Add" button at index 2
                    ? ElevatedAddButton(
                        selected: i == widget.selectedInt,
                        icon: items[i]["icon"] as IconData,
                        label: items[i]["label"] as String,
                        onTap: () => widget.onAddPressed(),
                      )
                    : NavbarItem(
                        selected: (i >= 2 ? i - 1 : i) == widget.selectedInt,
                        icon: items[i]["icon"] as IconData,
                        label: items[i]["label"] as String,
                        onTap: () => widget.onNavigationChange(i >= 2 ? i - 1 : i),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavbarItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavbarItem({required this.icon, required this.label, required this.onTap, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: selected ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: selected
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElevatedAddButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ElevatedAddButton({required this.icon, required this.label, required this.onTap, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
