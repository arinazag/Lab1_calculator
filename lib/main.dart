
import 'package:flutter/material.dart';
import 'calculator_state.dart';

void main() {
  runApp(const MainAppEntryPoint());
}

class MainAppEntryPoint extends StatefulWidget {
  const MainAppEntryPoint({super.key});

  @override
  State<MainAppEntryPoint> createState() =>
      _MainAppEntryPointState();
}

class _MainAppEntryPointState extends State<MainAppEntryPoint> {
  bool _darkThemeEnabled = false;

  void _switchTheme() {
    setState(() {
      _darkThemeEnabled = !_darkThemeEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFD9A3B0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Калькулятор',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: pink,
          brightness: Brightness.light,
          surface: const Color(0xFFFFFBF8),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBF8),
          foregroundColor: Color(0xFF49373D),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: pink,
          brightness: Brightness.dark,
          surface: const Color(0xFF292326),
        ),
        scaffoldBackgroundColor: const Color(0xFF201B1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF201B1E),
          foregroundColor: Color(0xFFFFE8EE),
          elevation: 0,
        ),
      ),
      themeMode:
          _darkThemeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: CustomCalculatorWorkspace(
        isDark: _darkThemeEnabled,
        onThemeChanged: _switchTheme,
      ),
    );
  }
}

class CustomCalculatorWorkspace extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const CustomCalculatorWorkspace({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<CustomCalculatorWorkspace> createState() =>
      _CustomCalculatorWorkspaceState();
}

class _CustomCalculatorWorkspaceState
    extends State<CustomCalculatorWorkspace> {
  final CalculatorState _calcState = CalculatorState();

  void _handleGridPress(String symbol) {
    setState(() {
      if (symbol == 'C') {
        _calcState.resetAll();
      } else if (symbol == '⌫') {
        _calcState.backspace();
      } else if (symbol == '=') {
        _calcState.equals();
      } else if (symbol == 'x!') {
        _calcState.factorial();
      } else if (['+', '−', '×', '÷'].contains(symbol)) {
        _calcState.setOperation(symbol);
      } else if (symbol == '+/−') {
        _calcState.toggleSign();
      } else if (symbol == '%') {
        _calcState.percent();
      } else {
        _calcState.inputDigit(symbol);
      }
    });
  }

  void _showHistory() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('История вычислений'),
          content: SizedBox(
            width: 360,
            height: 300,
            child: _calcState.history.isEmpty
                ? const Center(
                    child: Text(
                      'История пока пуста',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: _calcState.history.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 16),
                    itemBuilder: (context, index) {
                      return Text(
                        _calcState.history[index],
                        style: const TextStyle(fontSize: 16),
                      );
                    },
                  ),
          ),
          actions: [
            if (_calcState.history.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _calcState.clearHistory();
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('Очистить'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKeypadButton(String symbol) {
    final isOperation =
        ['+', '−', '×', '÷', '='].contains(symbol);

    final isUtility =
        ['C', '+/−', '%', '⌫', 'x!'].contains(symbol);

    final Color background;
    final Color foreground;

    if (isOperation) {
      background = widget.isDark
          ? const Color(0xFFB8788B)
          : const Color(0xFFE5B8C4);
      foreground = const Color(0xFF38252B);
    } else if (isUtility) {
      background = widget.isDark
          ? const Color(0xFF493740)
          : const Color(0xFFF3E1E5);
      foreground = widget.isDark
          ? const Color(0xFFFFE8EE)
          : const Color(0xFF49373D);
    } else {
      background = widget.isDark
          ? const Color(0xFF342D31)
          : Colors.white;
      foreground = widget.isDark
          ? const Color(0xFFFFF5F7)
          : const Color(0xFF382F32);
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.expand(
        child: FilledButton(
          onPressed: () => _handleGridPress(symbol),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(2),
            backgroundColor: background,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              symbol,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError =
        _calcState.display.startsWith('Ошибка');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final contentWidth =
                screenWidth > 500 ? 420.0 : screenWidth;

            final horizontalPadding =
                screenWidth < 360 ? 6.0 : 10.0;

            final displayFontSize =
                screenWidth < 360 ? 40.0 : 52.0;

            final displayFlex = screenHeight < 550 ? 2 : 3;
            final keypadFlex = screenHeight < 550 ? 5 : 6;

            return Center(
              child: SizedBox(
                width: contentWidth,
                height: screenHeight,
                child: Column(
                  children: [
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Калькулятор',
                              style: Theme.of(context)
                                      .appBarTheme
                                      .titleTextStyle ??
                                  Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: 'История вычислений',
                            onPressed: _showHistory,
                            icon: const Icon(
                              Icons.history_rounded,
                            ),
                          ),
                          IconButton(
                            tooltip: widget.isDark
                                ? 'Светлая тема'
                                : 'Тёмная тема',
                            onPressed: widget.onThemeChanged,
                            icon: Icon(
                              widget.isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: displayFlex,
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.bottomRight,
                                padding: EdgeInsets.all(
                                  screenWidth < 360 ? 10 : 18,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    if (_calcState
                                        .expression.isNotEmpty)
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          _calcState.expression,
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth < 360
                                                    ? 15
                                                    : 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment:
                                            Alignment.centerRight,
                                        child: Text(
                                          '${_calcState.display}${_calcState.isPercent ? '%' : ''}',
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: hasError
                                                ? 24
                                                : displayFontSize,
                                            height: 1.15,
                                            fontWeight:
                                                FontWeight.w400,
                                            color: hasError
                                                ? const Color(
                                                    0xFFD96C83,
                                                  )
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: keypadFlex,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 48,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildKeypadButton(
                                            'x!',
                                          ),
                                        ),
                                        const Expanded(
                                          child: SizedBox.shrink(),
                                        ),
                                        const Expanded(
                                          child: SizedBox.shrink(),
                                        ),
                                        const Expanded(
                                          child: SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: GridView.count(
                                      padding: EdgeInsets.zero,
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 0,
                                      mainAxisSpacing: 0,
                                      childAspectRatio:
                                          screenWidth < 360
                                              ? 0.9
                                              : 1.0,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: [
                                        _buildKeypadButton('C'),
                                        _buildKeypadButton('+/−'),
                                        _buildKeypadButton('%'),
                                        _buildKeypadButton('÷'),
                                        _buildKeypadButton('7'),
                                        _buildKeypadButton('8'),
                                        _buildKeypadButton('9'),
                                        _buildKeypadButton('×'),
                                        _buildKeypadButton('4'),
                                        _buildKeypadButton('5'),
                                        _buildKeypadButton('6'),
                                        _buildKeypadButton('−'),
                                        _buildKeypadButton('1'),
                                        _buildKeypadButton('2'),
                                        _buildKeypadButton('3'),
                                        _buildKeypadButton('+'),
                                        _buildKeypadButton('0'),
                                        _buildKeypadButton('.'),
                                        _buildKeypadButton('⌫'),
                                        _buildKeypadButton('='),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
