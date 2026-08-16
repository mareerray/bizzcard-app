import 'package:flutter/material.dart';

/// Shared route observer used across screens that need to refresh
/// their data when returning from a pushed route (e.g. after editing
/// the profile or picking a new background in Settings), rather than
/// only on tab switch.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// Increments every time the app returns from a pushed route (e.g.
/// Settings, Edit Profile) back to MainScreen. Screens inside the
/// PageView listen to this instead of using RouteAware directly,
/// since they aren't separately routed — they're PageView children
/// sharing MainScreen's single route.
final ValueNotifier<int> refreshSignal = ValueNotifier<int>(0);