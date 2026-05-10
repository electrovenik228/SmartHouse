import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/providers/auth_provider.dart';
import 'package:smarthome/screens/login_screen.dart';
import 'package:smarthome/screens/home_screen.dart';
import 'package:smarthome/screens/room_screen.dart';
import 'package:smarthome/screens/history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.loading;
      final isAuthed = authState.status == AuthStatus.authenticated;
      final onLogin = state.matchedLocation == '/login';

      if (isLoading) return null;
      if (!isAuthed && !onLogin) return '/login';
      if (isAuthed && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/rooms/:id',
        builder: (context, state) {
          final roomId = int.parse(state.pathParameters['id']!);
          final roomName = state.extra as String? ?? 'Комната';
          return RoomScreen(roomId: roomId, roomName: roomName);
        },
      ),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    ],
  );
});
