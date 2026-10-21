import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/app.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('1. App smoke test renders WorkoutApp', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const WorkoutApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(WorkoutApp), findsOneWidget);
  });

  testWidgets('2. Onboarding screen renders step 1 gender selection', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const WorkoutApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("What's your gender?"), findsOneWidget);
  });

  testWidgets('3. Next button in onboarding advances step', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const WorkoutApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('NEXT'), findsOneWidget);
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('What is your main goal?'), findsOneWidget);
  });

  testWidgets('4. Onboarding screen renders Skip button', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const WorkoutApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('5. UserProfileNotifier correctly loads completed onboarding state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'user_profile': '{"onboardingComplete":true}'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final profile = container.read(userProfileProvider);
    expect(profile.onboardingComplete, isTrue);
  });
}
