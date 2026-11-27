
import 'calculator_logic.dart';

class CalculatorState {
  String display = '0';
  String expression = '';

  final List<String> history = [];
  final List<double> _storedNumbers = [];
  final List<String> _storedOperators = [];

  bool _isWaitingNewInput = true;
  bool _percentApplied = false;

  bool get isPercent => _percentApplied;

  void inputDigit(String character) {
    if (display.startsWith('Ошибка')) {
      resetAll();
    }

    if (_isWaitingNewInput || _percentApplied) {
      display = character == '.' ? '0.' : character;
      _isWaitingNewInput = false;
      _percentApplied = false;
      _updateExpression();
      return;
    }

    if (character == '.' && display.contains('.')) return;

    if (display == '0' && character != '.') {
      display = character;
    } else {
      display += character;
    }

    _updateExpression();
  }

  void backspace() {
    if (display.startsWith('Ошибка') || _isWaitingNewInput) {
      display = '0';
      _isWaitingNewInput = true;
      _percentApplied = false;
      _updateExpression();
      return;
    }

    _percentApplied = false;

    if (display.length <= 1) {
      display = '0';
    } else {
      display = display.substring(0, display.length - 1);
    }

    if (display.isEmpty || display == '-') {
      display = '0';
    }

    _updateExpression();
  }

  void resetAll() {
    display = '0';
    expression = '';
    _storedNumbers.clear();
    _storedOperators.clear();
    _isWaitingNewInput = true;
    _percentApplied = false;
  }

  void clearHistory() {
    history.clear();
  }

  void setOperation(String opSymbol) {
    if (display.startsWith('Ошибка')) {
      resetAll();
    }

    if (_isWaitingNewInput && _storedOperators.isNotEmpty) {
      _storedOperators[_storedOperators.length - 1] = opSymbol;
      _updateExpression();
      return;
    }

    final current = double.tryParse(display);
    if (current == null || !current.isFinite) return;

    final numberToStore = _percentApplied
        ? _calculatePercentValue(current)
        : current;

    _storedNumbers.add(numberToStore);
    _storedOperators.add(opSymbol);

    display = CalculatorLogic.cleanFormat(numberToStore);
    _isWaitingNewInput = true;
    _percentApplied = false;

    _updateExpression();
  }

  void equals() {
    if (_storedOperators.isEmpty) {
      if (_percentApplied) {
        final current = double.tryParse(display);
        if (current == null) return;

        final original = display;
        final result = CalculatorLogic.cleanFormat(current / 100);

        expression = '$original % =';
        display = result;
        history.insert(0, '$expression $result');

        _percentApplied = false;
        _isWaitingNewInput = true;
      }
      return;
    }

    if (_isWaitingNewInput) return;

    final current = double.tryParse(display);
    if (current == null || !current.isFinite) {
      display = 'Ошибка';
      _storedNumbers.clear();
      _storedOperators.clear();
      _isWaitingNewInput = true;
      _percentApplied = false;
      return;
    }

    final visibleExpression = _buildVisibleExpression();

    final numberToStore = _percentApplied
        ? _calculatePercentValue(current)
        : current;

    _storedNumbers.add(numberToStore);

    final result = CalculatorLogic.evaluateExpression(
      List<double>.from(_storedNumbers),
      List<String>.from(_storedOperators),
    );

    expression = '$visibleExpression =';
    display = result;

    if (!result.startsWith('Ошибка')) {
      history.insert(0, '$expression $result');
    }

    _storedNumbers.clear();
    _storedOperators.clear();
    _isWaitingNewInput = true;
    _percentApplied = false;
  }

  void toggleSign() {
    if (display == '0' || display.startsWith('Ошибка')) return;

    _percentApplied = false;

    if (display.startsWith('-')) {
      display = display.substring(1);
    } else {
      display = '-$display';
    }

    _updateExpression();
  }

  void percent() {
    if (display.startsWith('Ошибка') || _isWaitingNewInput) return;
    if (_percentApplied) return;

    _percentApplied = true;
    _updateExpression();
  }

  void factorial() {
    if (display.startsWith('Ошибка')) {
      resetAll();
    }

    if (_isWaitingNewInput && _storedOperators.isNotEmpty) {
      return;
    }

    final original = display;
    final result = CalculatorLogic.factorial(original);

    _percentApplied = false;

    if (result.startsWith('Ошибка')) {
      display = result;
      expression = '$original!';
      _isWaitingNewInput = true;
      return;
    }

    display = result;

    if (_storedOperators.isEmpty) {
      expression = '$original! =';
      history.insert(0, '$expression $result');
      _isWaitingNewInput = true;
    } else {
      _isWaitingNewInput = false;
      _updateExpression();
    }
  }

  double _calculatePercentValue(double current) {
    if (_storedNumbers.isEmpty || _storedOperators.isEmpty) {
      return current / 100;
    }

    final lastOperator = _storedOperators.last;

    if (lastOperator == '+' || lastOperator == '−') {
      return _storedNumbers.last * current / 100;
    }

    return current / 100;
  }

  String _buildVisibleExpression() {
    final parts = <String>[];

    for (int i = 0; i < _storedNumbers.length; i++) {
      parts.add(
        CalculatorLogic.cleanFormat(_storedNumbers[i]),
      );

      if (i < _storedOperators.length) {
        parts.add(_storedOperators[i]);
      }
    }

    parts.add(_percentApplied ? '$display %' : display);

    return parts.join(' ');
  }

  void _updateExpression() {
    final parts = <String>[];

    for (int i = 0; i < _storedNumbers.length; i++) {
      parts.add(
        CalculatorLogic.cleanFormat(_storedNumbers[i]),
      );

      if (i < _storedOperators.length) {
        parts.add(_storedOperators[i]);
      }
    }

    if (!_isWaitingNewInput) {
      parts.add(_percentApplied ? '$display %' : display);
    }

    expression = parts.join(' ');
  }
}
