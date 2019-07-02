import 'package:flutter/material.dart';
import 'package:practice_math/question_item.dart';
import 'package:practice_math/widgets/practice_button.dart';

void main() => runApp(PracticeMathApp());

class PracticeMathApp extends StatelessWidget {



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practice Math',
      home: MyHomePage(title: 'Practice Math'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  List<QuestionItem> _questionsList = List();
  List<QuestionItem> _optionsList = List();

  final GlobalKey<ScaffoldState> _scaffoldKey = new
  GlobalKey<ScaffoldState>();

  bool _isChecked = false;
  String _buttonText = "Check Now";

  Animatable<Color> background = TweenSequence<Color>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.red,
          end: Colors.green,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.green,
          end: Colors.blue,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.blue,
          end: Colors.pink,
        ),
      ),
    ],
  );

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    startAnimation();
    generateQuestions();
  }

  void generateQuestions() {

    _questionsList.clear();
    _questionsList.add(QuestionItem(2, QuestionItem.TYPE_ADD));
    _questionsList.add(QuestionItem(2, QuestionItem.TYPE_MOD));
    _questionsList.add(QuestionItem(2, QuestionItem.TYPE_MUL));
    _questionsList.add(QuestionItem(2, QuestionItem.TYPE_DIV));
    _questionsList.add(QuestionItem(2, QuestionItem.TYPE_SUB));
    _questionsList.add(QuestionItem(2, QuestionItem.TYPE_DIV));
    _questionsList.shuffle();

    _optionsList.clear();
    _optionsList.addAll(_questionsList);
    _optionsList.shuffle();

  }

  TextStyle buildTextStyle( double fontSize ) {
    return TextStyle(
      fontFamily: 'VarelaRound-Regular',
      fontSize: fontSize,
      color: Colors.white,
    );
  }

  TextStyle buildTextStyleBlack( double fontSize ) {
    return TextStyle(
      fontFamily: 'VarelaRound-Regular',
      fontSize: fontSize,
      color: Colors.black,
    );
  }

  TextStyle buildTextStyleGreen( double fontSize ) {
    return TextStyle(
      fontFamily: 'VarelaRound-Regular',
      fontSize: fontSize,
      color: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) { return Scaffold(
            appBar: _buildAppBar(context),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildQuestionsListView(),
                  _buildOptionsContainer(),
                ],
              ),
            ),
            bottomNavigationBar: PracticeButton(buttonColor: Colors.green,
              onClick: (){
                if( !_isChecked ) {

                  int correctCount = 0;
                  String solution = "\n";
                  _questionsList.forEach((item) {
                    item.isCorrect = item.userSolution == item.solution;
                    solution += item.question + " = " + item.solution.toString() + "\n";
                    correctCount += item.isCorrect ? 1 : 0;
                  });

                  setState(() {
                    _isChecked = true;
                    _buttonText = "Reset";
                  });
                  _showBottomSheet(correctCount > 2, "You got $correctCount / ${_questionsList.length}", solution);
                }
                else {
                  generateQuestions();
                  setState(() {
                    _isChecked = false;
                    _buttonText = "Check Now";
                  });
                }
              },
              buttonText: _buttonText,)
        );
        }
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 8,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(widget.title,
        style: buildTextStyle(22),),
      actions: <Widget>[
        GestureDetector(
            onTap: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context)
              {
                return AlertDialog(
                  title: Text("How to..?", style: buildTextStyleGreen(18),),
                  elevation: 20,
                  content: Text(
                      "1. Drag and drop options from below to appropriate question cards displayed."
                          "\n\n2. Click \"Check now\" once done.",),
                  actions: <Widget>[
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Okay", style: buildTextStyleGreen(16),),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.help_outline, color : Colors.white),
            )
        )
      ],
    );
  }

  Expanded _buildQuestionsListView() {
    return Expanded(
      child: Container(
        color: _isChecked ? background
            .evaluate(AlwaysStoppedAnimation(_controller.value)) : Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: _questionsList.map<Widget>(_buildDragTarget).toList(),
          ),
        ),

      ),
    );
  }

  Widget _buildDragTarget(QuestionItem item) {
    if( !_isChecked ) {
      return DragTarget(
        builder: (context, List<QuestionItem> candidateData, rejectedData) {
          return _buildQuestionListTitle(item);
        },
        onAccept:(data) {
          item.userSolution = data.solution;
          setState(() {

          });
        },
        onWillAccept: (data) {
          return true;
        },
      );
    }
    else return _buildQuestionListTitle(item);

  }

  Container _buildOptionsContainer() {
    return Container(
      color: Colors.black54,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: _buildOptionsGrid(),
        ),
      ),
      alignment: Alignment(-1, 1),
    );
  }

  Widget _buildDraggableListTitle(QuestionItem item) {
    Widget listTile = _buildListTitle(item);
    if( !_isChecked ) {
      return Draggable(
        data: item,
        child: listTile,
        feedback: listTile,
        childWhenDragging: listTile,
      );
    }
    else return listTile;
  }

  Widget _buildListTitle(QuestionItem item) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(item.solution.toString(), style: TextStyle(
              fontFamily: 'VarelaRound-Regular',
              fontSize: 20,
              color: Colors.black,
            )),
          ],
        ),
      )
  );

  Padding _buildOptionsGrid() => Padding( padding: EdgeInsets.all(4),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: _optionsList.map<Widget>(_buildDraggableListTitle).toList(),
      ));

  Widget _buildQuestionListTitle(QuestionItem item) => Card(
      color: !_isChecked ? Colors.white : item.isCorrect ? Colors.green : Colors.red,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(item.userSolution == -999 ? item.question : item.question + " = " + item.userSolution.toString(), style: TextStyle(
              fontFamily: 'VarelaRound-Regular',
              fontSize: 20,
              color: !_isChecked ? Colors.black : Colors.white,
            )),
          ],
        ),
      )
  );

  void startAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  _showBottomSheet(bool isCorrect, String message, String solution) {
    showModalBottomSheet(context: context, builder: (BuildContext builderContext) {
      return Container(
        key: _scaffoldKey,
        color: Colors.white,
        padding: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(message, style: TextStyle(
                    fontFamily: 'VarelaRound-Regular',
                    fontSize: 16,
                    color:  isCorrect ? Colors.green : Colors.red,
                  ),
                  ),
                  Expanded(child: Text("The solution is :\n" + solution, style: buildTextStyle(16),)),
                ],
              )),
        ),

      );
    });
  }

}
