import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tic_tac_toe/custom_dialog.dart';
import 'package:tic_tac_toe/game_button.dart';
import 'dart:math';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primaryColor: Colors.black),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MainPage(),
      navigatorKey: navigatorKey,
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage(
                title: 'Tic Tac Toe',
              );
            } else {
              return LoginWidget();
            }
          },
        ),
      );
}

class HomePage extends StatefulWidget {
  HomePage({required this.title});

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<GameButton> buttonsList;
  var player1;
  var player2;
  var activePlayer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buttonsList = doInit();
  }

  List<GameButton> doInit() {
    player1 = [];
    player2 = [];
    activePlayer = 1;

    var gameButtons = <GameButton>[
      GameButton(id: 1),
      GameButton(id: 2),
      GameButton(id: 3),
      GameButton(id: 4),
      GameButton(id: 5),
      GameButton(id: 6),
      GameButton(id: 7),
      GameButton(id: 8),
      GameButton(id: 9),
    ];
    return gameButtons;
  }

  void playGame(GameButton gb) {
    setState(() {
      if (activePlayer == 1) {
        gb.text = "X";
        gb.bg = Colors.blue;
        activePlayer = 2;
        player1.add(gb.id);
      } else {
        gb.text = "0";
        gb.bg = Colors.black;
        activePlayer = 1;
        player2.add(gb.id);
      }
      gb.enabled = false;
      int winner = checkWinner();
      if (winner == -1) {
        if (buttonsList.every((p) => p.text != "")) {
          showDialog(
              context: context,
              builder: (_) => CustomDialog("Game Tied",
                  "Press the reset button to start again.", resetGame));
        } else {
          activePlayer == 2 ? autoPlay() : null;
        }
      }
    });
  }

  void autoPlay() {
    var emptyCells = [];
    var list = List.generate(9, (i) => i + 1);
    for (var cellID in list) {
      if (!(player1.contains(cellID) || player2.contains(cellID))) {
        emptyCells.add(cellID);
      }
    }

    var r = Random();
    var randIndex = r.nextInt(emptyCells.length - 1);
    var cellID = emptyCells[randIndex];
    int i = buttonsList.indexWhere((p) => p.id == cellID);
    playGame(buttonsList[i]);
  }

  int checkWinner() {
    var winner = -1;
    if (player1.contains(1) && player1.contains(2) && player1.contains(3)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(2) && player2.contains(3)) {
      winner = 2;
    }

    // row 2
    if (player1.contains(4) && player1.contains(5) && player1.contains(6)) {
      winner = 1;
    }
    if (player2.contains(4) && player2.contains(5) && player2.contains(6)) {
      winner = 2;
    }

    // row 3
    if (player1.contains(7) && player1.contains(8) && player1.contains(9)) {
      winner = 1;
    }
    if (player2.contains(7) && player2.contains(8) && player2.contains(9)) {
      winner = 2;
    }

    // col 1
    if (player1.contains(1) && player1.contains(4) && player1.contains(7)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(4) && player2.contains(7)) {
      winner = 2;
    }

    // col 2
    if (player1.contains(2) && player1.contains(5) && player1.contains(8)) {
      winner = 1;
    }
    if (player2.contains(2) && player2.contains(5) && player2.contains(8)) {
      winner = 2;
    }

    // col 3
    if (player1.contains(3) && player1.contains(6) && player1.contains(9)) {
      winner = 1;
    }
    if (player2.contains(3) && player2.contains(6) && player2.contains(9)) {
      winner = 2;
    }

    //diagonal
    if (player1.contains(1) && player1.contains(5) && player1.contains(9)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(5) && player2.contains(9)) {
      winner = 2;
    }

    if (player1.contains(3) && player1.contains(5) && player1.contains(7)) {
      winner = 1;
    }
    if (player2.contains(3) && player2.contains(5) && player2.contains(7)) {
      winner = 2;
    }

    if (winner != -1) {
      if (winner == 1) {
        showDialog(
            context: context,
            builder: (_) => CustomDialog("Player 1 Won",
                "Press the reset button to start again.", resetGame));
      } else {
        showDialog(
            context: context,
            builder: (_) => CustomDialog("Player 2 Won",
                "Press the reset button to start again.", resetGame));
      }
    }

    return winner;
  }

  void resetGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() {
      buttonsList = doInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.arrow_back,
                size: 32,
                color: Colors.black,
              ),
              label: Text(
                'Sign Out',
                style: TextStyle(fontSize: 27, color: Colors.black),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 9.0,
                    mainAxisSpacing: 9.0),
                itemCount: buttonsList.length,
                itemBuilder: (context, i) => SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: RaisedButton(
                    padding: const EdgeInsets.all(8.0),
                    onPressed: buttonsList[i].enabled
                        ? () => playGame(buttonsList[i])
                        : null,
                    child: Text(
                      buttonsList[i].text,
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    color: buttonsList[i].bg,
                    disabledColor: buttonsList[i].bg,
                  ),
                ),
              ),
            ),
            RaisedButton(
              child: Text(
                "Reset",
                style: TextStyle(color: Colors.black, fontSize: 30.0),
              ),
              color: Colors.blue,
              onPressed: resetGame,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
          color: Colors.black,
          child: Text(
            'Developed by Tejvir Singh [102116076]',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          )),
    );
  }
}

class LoginWidget extends StatefulWidget {
  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            TextField(
              controller: emailController,
              cursorColor: Colors.blue,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(
                  50,
                ),
              ),
              icon: Icon(
                Icons.lock_open,
                size: 32,
              ),
              label: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onPressed: signIn,
            )
          ],
        ),
      );

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
