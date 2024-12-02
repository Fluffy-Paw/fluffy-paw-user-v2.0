// import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class AppLifecycleNotifier extends WidgetsBindingObserver {
//   final Ref ref;
  
//   AppLifecycleNotifier(this.ref) {
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         ref.read(notificationControllerProvider.notifier).initializeSignalR();
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         ref.read(notificationControllerProvider.notifier).dispose();
//         break;
//       default:
//         break;
//     }
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//   }
// }