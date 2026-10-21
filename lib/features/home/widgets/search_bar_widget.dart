import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/common/widgets/app_search_bar.dart';
import 'package:workout/core/constants/app_routes.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      readOnly: true,
      onTap: () => context.push(AppRoutes.search),
    );
  }
}
