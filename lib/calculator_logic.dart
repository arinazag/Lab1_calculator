class CalculatorLogic {
  static String factorial(String input) {
    final number = int.tryParse(input);

    if (number == null || number < 0) {
      return 'Ошибка: нужен целый неотрицательный номер';
    }

    if (number > 100) {
      return 'Ошибка: максимум 100!';
    }

    BigInt result = BigInt.one;

    for (int i = 2; i <= number; i++) {
      result *= BigInt.from(i);
    }

    return result.toString();
  }

  static String evaluate(
    double firstNum,
    double secondNum,
    String operation,
  ) {
    double value;

    if (operation == '+') {
      value = firstNum + secondNum;
    } else if (operation == '−') {
      value = firstNum - secondNum;
    } else if (operation == '×') {
      value = firstNum * secondNum;
    } else if (operation == '÷') {
      if (secondNum == 0) {
        return 'Ошибка: деление на ноль';
      }

      value = firstNum / secondNum;
    } else {
      return 'Ошибка: неизвестная операция';
    }

    return cleanFormat(value);
  }

  static String evaluateExpression(
    List<double> numbersList,
    List<String> opsList,
  ) {
    if (numbersList.isEmpty ||
        numbersList.length != opsList.length + 1) {
      return 'Ошибка';
    }

    final interimNumbers = <double>[];
    final interimOps = <String>[];

    double accumulator = numbersList[0];

    for (int idx = 0; idx < opsList.length; idx++) {
      final nextValue = numbersList[idx + 1];
      final currentOp = opsList[idx];

      if (currentOp == '×') {
        accumulator *= nextValue;
      } else if (currentOp == '÷') {
        if (nextValue == 0) {
          return 'Ошибка: деление на ноль';
        }

        accumulator /= nextValue;
      } else if (currentOp == '+' || currentOp == '−') {
        interimNumbers.add(accumulator);
        interimOps.add(currentOp);
        accumulator = nextValue;
      } else {
        return 'Ошибка: неизвестная операция';
      }

      if (!accumulator.isFinite) return 'Ошибка';
    }

    interimNumbers.add(accumulator);

    double totalResult = interimNumbers[0];

    for (int idx = 0; idx < interimOps.length; idx++) {
      if (interimOps[idx] == '+') {
        totalResult += interimNumbers[idx + 1];
      } else {
        totalResult -= interimNumbers[idx + 1];
      }

      if (!totalResult.isFinite) return 'Ошибка';
    }

    return cleanFormat(totalResult);
  }

  static String cleanFormat(double val) {
    if (!val.isFinite) return 'Ошибка';

    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }

    String rawStr = val.toStringAsFixed(10);
    int end = rawStr.length;

    while (end > 0 && rawStr[end - 1] == '0') {
      end--;
    }

    String cutStr = rawStr.substring(0, end);

    if (cutStr.endsWith('.')) {
      cutStr = cutStr.substring(0, cutStr.length - 1);
    }

    return cutStr;
  }
}
