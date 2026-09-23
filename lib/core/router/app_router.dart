import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/storage_repository.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/recipes/models/recipe_model.dart';
import '../../features/recipes/views/catalog_view.dart';
import '../../features/recipe_details/views/recipe_details_view.dart';
import '../../features/recipe_details/views/recipe_in_progress_view.dart';
import '../../features/favorites/views/favorites_view.dart';
import '../../features/done_recipes/views/done_recipes_view.dart';
import '../../features/profile/views/profile_view.dart';
import 'main_shell_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorExploreKey = GlobalKey<NavigatorState>(debugLabel: 'explore');
final _shellNavigatorFavKey = GlobalKey<NavigatorState>(debugLabel: 'favorites');
final _shellNavigatorDoneKey = GlobalKey<NavigatorState>(debugLabel: 'done');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(storageRepositoryProvider);
  final hasUser = storage.getUserEmail() != null;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: hasUser ? '/catalog' : '/login',
    routes: [
      // Tela de Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),

      // Stateful Shell Route com as 4 abas principais
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellView(navigationShell: navigationShell);
        },
        branches: [
          // Aba 1: Explorar (Catálogo)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorExploreKey,
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogView(),
              ),
            ],
          ),

          // Aba 2: Favoritos
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFavKey,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesView(),
              ),
            ],
          ),

          // Aba 3: Concluídas
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDoneKey,
            routes: [
              GoRoute(
                path: '/done-recipes',
                builder: (context, state) => const DoneRecipesView(),
              ),
            ],
          ),

          // Aba 4: Perfil
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),

      // Detalhes da Receita (Empilhada no root navigator)
      GoRoute(
        path: '/recipe/:type/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final typeStr = state.pathParameters['type'] ?? 'meal';
          final type = typeStr == 'drink' ? RecipeType.drink : RecipeType.meal;
          return RecipeDetailsView(id: id, type: type);
        },
      ),

      // Modo Receita em Progresso (Interactive Cooking Mode)
      GoRoute(
        path: '/recipe/:type/:id/in-progress',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final typeStr = state.pathParameters['type'] ?? 'meal';
          final type = typeStr == 'drink' ? RecipeType.drink : RecipeType.meal;
          return RecipeInProgressView(id: id, type: type);
        },
      ),
    ],
  );
});
