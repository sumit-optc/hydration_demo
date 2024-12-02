import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final counterHydrationProvider =
    StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  static const _counterKey = 'persistent_counter';

  CounterNotifier() : super(0) {
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCounter = prefs.getInt(_counterKey);
    if (savedCounter != null) {
      state = savedCounter;
    }
  }

  void increment() {
    state++;
    _saveCounter();
  }

  void decrement() {
    state--;
    _saveCounter();
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, state);
  }

  void reset() {
    state = 0;
    _saveCounter();
  }
}

void main() {
  runApp(
    ProviderScope(
      child: StateHydrationApp(),
    ),
  );
}

class StateHydrationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Hydration Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StateHydrationHomePage(),
    );
  }
}

class StateHydrationHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the counter state
    final counter = ref.watch(counterHydrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('State Hydration Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Counter Value:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => {
                    if (counter == 0)
                      null
                    else
                      ref.read(counterHydrationProvider.notifier).decrement()
                  },
                  child: Icon(Icons.remove),
                ),
                SizedBox(width: 20),
                FilledButton(
                  onPressed: () =>
                      ref.read(counterHydrationProvider.notifier).increment(),
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () =>
                  ref.read(counterHydrationProvider.notifier).reset(),
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
