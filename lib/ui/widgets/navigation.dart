import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ScreenType { dashboard, vectorize, collection, setting }

class Navigation extends StatelessWidget {
  const Navigation({
    super.key,
    required this.currentScreen,
    required this.onTabClick,
  });
  final ScreenType currentScreen;
  final ValueChanged<ScreenType> onTabClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: BoxBorder.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SelectedScreen(
              iconImg: 'assets/icons/dashboard.svg',
              label: "Dashboard",
              screenType: ScreenType.dashboard,
              isSelected: currentScreen == ScreenType.dashboard,
              onTabClick: onTabClick,
            ),
            SelectedScreen(
              iconImg: 'assets/icons/vectorize.svg',
              label: "Vectorize",
              screenType: ScreenType.vectorize,
              isSelected: currentScreen == ScreenType.vectorize,
              onTabClick: onTabClick,
            ),
            SelectedScreen(
              iconImg: 'assets/icons/collection.svg',
              label: "Collection",
              screenType: ScreenType.collection,
              isSelected: currentScreen == ScreenType.collection,
              onTabClick: onTabClick,
            ),
            SelectedScreen(
              iconImg: 'assets/icons/setting.svg',
              label: "Settings",
              screenType: ScreenType.setting,
              isSelected: currentScreen == ScreenType.setting,
              onTabClick: onTabClick,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedScreen extends StatelessWidget {
  const SelectedScreen({
    super.key,
    required this.iconImg,
    required this.label,
    required this.isSelected,
    required this.onTabClick,
    required this.screenType,
  });
  final String iconImg;
  final String label;
  final bool isSelected;
  final ValueChanged<ScreenType> onTabClick;
  final ScreenType screenType;

  Color get iconColor => isSelected ? Colors.white : Colors.black;

  Widget get labelWidget {
    return isSelected
        ? Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        : const SizedBox.shrink();
  }

  BoxDecoration? get decoration {
    return isSelected
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.black,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTabClick(screenType),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: decoration,
        child: Row(
          spacing: 9,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SvgPicture.asset(
              iconImg,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: labelWidget,
            ),
          ],
        ),
      ),
    );
  }
}
