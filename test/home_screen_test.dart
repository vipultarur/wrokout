import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/home/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"onboardingComplete": true, "name": "Test User"}',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    
    // Check if HOME WORKOUT is found
    expect(find.text('HOME WORKOUT'), findsOneWidget);
    
    // Pump frames for async exercise loader
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  });
}
