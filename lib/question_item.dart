import 'dart:math';

class QuestionItem {

  final int variableCount;
  final int questionType;
  String question;
  int solution;
  int userSolution = -999;
  bool isCorrect;

  final _random = new Random();

  /// Generates a positive random integer uniformly distributed on the range
  /// from [min], inclusive, to [max], exclusive.
  int next(int min, int max) => min + _random.nextInt(max - min);

  QuestionItem(this.variableCount, this.questionType) {

    if( questionType == TYPE_MUL )
      solution = 1;
    else
      solution = 0;

    question = "";
    List<int> variables = List();

    for( int i = 0; i < variableCount; i++ ) {
      int variable = next(1, 9);
      variables.add(variable);
      switch( questionType ) {
        case TYPE_ADD : {
          question += question.isEmpty ?  variable.toString() : " + " + variable.toString();
          break;
        }
        case TYPE_SUB : {
          question += question.isEmpty ?  variable.toString() : " - " + variable.toString();
          break;
        }
        case TYPE_DIV : {
          question += question.isEmpty ?  variable.toString() : " / " + variable.toString();
          break;
        }
        case TYPE_MUL : {
          question += question.isEmpty ?  variable.toString() : " * " + variable.toString();
          break;
        }
        case TYPE_MOD : {
          question += question.isEmpty ?  variable.toString() : " % " + variable.toString();
          break;
        }
      }
    }

    int variableIndex = 0;
    variables.forEach((variable) {
      switch(questionType) {
        case TYPE_ADD :
          solution += variable;
          break;
        case TYPE_MUL :
          solution *= variable;
          break;
        case TYPE_SUB :
          if( variableIndex == 0 ) solution = variable;
          else solution -= variable;
          break;
        case TYPE_DIV :
          if( variableIndex == 0 ) solution = variable;
          else solution = solution ~/ variable;
          break;
        case TYPE_MOD :
          if( variableIndex == 0 ) solution = variable;
          else solution = solution % variable;
          break;
      }
      variableIndex++;
    });


  }

  static const int TYPE_ADD = 0;
  static const int TYPE_SUB = 1;
  static const int TYPE_MUL = 2;
  static const int TYPE_DIV = 3;
  static const int TYPE_MOD = 4;

}