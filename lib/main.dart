import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Standaard Tokio Regels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFae0a2d), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late LinkedScrollControllerGroup controllerGroup;
  List<ScrollController> controllers = [];

  @override
  void initState() {
    super.initState();
    controllerGroup = LinkedScrollControllerGroup();
    for (var i = 0; i < 4; i++) {
      controllers.add(controllerGroup.addAndGet());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Standaard Tokio Regels'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const DiceRow(label: 'Target', low: 17, high: 36),
              const DiceRow(label: '2 Minigame', low: 1, high: 4),
              const DiceRow(label: '3 Minigame', low: 1, high: 8),
              for (var i = 0; i < controllers.length; i++)
                PlayerScore(
                  key: ValueKey(i),
                  controller: controllers[i],
                ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => controllers.clear()),
                    child: const Text('Reset'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => setState(() => controllers.removeLast()),
                    child: const Text('Remove player'),
                  ),
                  FilledButton(
                    onPressed: () => setState(
                        () => controllers.add(controllerGroup.addAndGet())),
                    child: const Text('Add player'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class DiceRow extends StatefulWidget {
  const DiceRow(
      {super.key, required this.label, required this.low, required this.high});

  final String label;
  final int low;
  final int high;

  @override
  State<DiceRow> createState() => _DiceRowState();
}

class _DiceRowState extends State<DiceRow> {
  int _value = 0;
  bool _switch = false;

  @override
  Widget build(BuildContext context) {
    final color = {
      'Target': Theme.of(context).colorScheme.primaryContainer,
      '2 Minigame': Theme.of(context).colorScheme.secondaryContainer,
      '3 Minigame': Theme.of(context).colorScheme.tertiaryContainer,
    }[widget.label]!;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: GestureDetector(
            onTap: () {
              // Generate a random number between low and high
              setState(() {
                _switch = !_switch;
                _value =
                    widget.low + Random().nextInt(widget.high - widget.low + 1);
              });
            },
            child: AspectRatio(
              aspectRatio: 4 / 2,
              child: Card(
                color: color,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(fontSize: 40),
                      ),
                      Text("${widget.low} - ${widget.high}")
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1,
            child: Card.filled(
              color: color.withOpacity(0.5),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text('$_value',
                      key: ValueKey(_switch),
                      style: const TextStyle(fontSize: 54)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerScore extends StatefulWidget {
  const PlayerScore({super.key, required this.controller});

  final ScrollController controller;

  @override
  State<PlayerScore> createState() => _PlayerScoreState();
}

class _PlayerScoreState extends State<PlayerScore> {
  final List<int?> _scores = List.filled(20, null);
  bool hasStopped = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: SizedBox(
            height: 48,
            child: Card(
              child: Center(
                  child: TextField(
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Player',
                  isDense: true,
                  border: InputBorder.none,
                ),
              )),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.controller,
            child: Row(
              children: _scores
                  .asMap()
                  .entries
                  .map((entry) => SizedBox.square(
                        dimension: 48,
                        child: Card.outlined(
                          color: (entry.key % 2 == 0)
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                          child: Center(
                            child: TextField(
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => setState(() =>
                                  _scores[entry.key] = int.tryParse(value)),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        // Show the total score
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => hasStopped = !hasStopped),
            child: SizedBox(
              height: 48,
              child: Card(
                color: hasStopped
                    ? Theme.of(context).colorScheme.errorContainer
                    : null,
                child: Center(
                  child: Text(_scores
                      .where((score) => score != null)
                      .fold(0, (a, b) => a + (b ?? 0))
                      .toString()),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
