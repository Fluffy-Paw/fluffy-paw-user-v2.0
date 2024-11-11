import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/views/booking/booking_history_view.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/components/app_bottom_navbar.dart';
import 'package:fluffypawuser/views/home_screen/home_view.dart';
import 'package:fluffypawuser/views/profile/profile_view.dart';
import 'package:fluffypawuser/views/wallet/wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomItem {
  final String icon;
  final String activeIcon;
  final String name;
  BottomItem({
    required this.icon,
    required this.activeIcon,
    required this.name,
  });
}
class BottomNavigationLayout extends ConsumerStatefulWidget {
  const BottomNavigationLayout({super.key});

  @override
  ConsumerState<BottomNavigationLayout> createState() =>
      _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState
    extends ConsumerState<BottomNavigationLayout> {
      late PageController pageController;
      @override
  void initState() {
    super.initState();
    // Initialize with current selected index
    final initialIndex = ref.read(selectedIndexProvider);
    pageController = PageController(initialPage: initialIndex);
  }
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.page?.round() != selectedIndex) {
        pageController.jumpToPage(selectedIndex);
      }
    });
    return Scaffold(
      bottomNavigationBar: AppBottomNavbar(
        bottomItem: getBottomItems(context: context),
        onSelect: (index) {
          if (index != null) {
            ref.read(selectedIndexProvider.notifier).state = index;
          }
        },
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) {
          if (ref.read(selectedIndexProvider) != index) {
            ref.read(selectedIndexProvider.notifier).state = index;
          }
        },
        children: const [
          HomeView(),
          BookingHistoryView(),
          WalletView(),
          ProfileView(),
          ProfileView(),
        ],
      ),
    );
  }

  List<BottomItem> getBottomItems({required BuildContext context}) {
    return [
      BottomItem(
        icon: Assets.svg.explorer,
        activeIcon: Assets.svg.activeExplorer,
        name: S.of(context).explorer,
      ),
      BottomItem(
        icon: Assets.svg.activity,
        activeIcon: Assets.svg.activeActivity,
        name: S.of(context).activity,
      ),
      BottomItem(
        icon: Assets.svg.wallet,
        activeIcon: Assets.svg.activeWallet,
        name: S.of(context).payment,
      ),
      BottomItem(
        icon: Assets.svg.inbox,
        activeIcon: Assets.svg.activeInbox,
        name: S.of(context).inbox,
      ),
      BottomItem(
        icon: Assets.svg.account,
        activeIcon: Assets.svg.activeAccount,
        name: S.of(context).account,
      ),
    ];
  }
}