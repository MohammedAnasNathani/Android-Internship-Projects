class MathEval{
  static double evaluate({required double num1, required double num2, required String operand})
  {
    switch(operand)
    {
      case '+':
        return num1+num2;
      case '-':
        return num1-num2;
      case 'x':
        return num1*num2;
      case '/':
        if (num2 == 0) {
          return double.infinity;
        }
        return num1/num2;
      case '%':
        return num1 % num2;
      default:
        throw Exception('Invalid operator');
    }
  }
}