import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'button.dart';
import 'jumpingmario.dart';
import 'mario.dart';
import 'shrooms.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double marioX = 0;
  static double marioY = 1;
  double marioSize = 50;
  double shroomX = 0.5;
  double shroomY = 1;
  double time = 0;
  double height = 0;
  double initialHeight = marioY;
  String direction = "right";
  bool midrun = false;
  bool midjump = false;
  var gameFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: Colors.white, fontSize: 20));
  static double blockX = -0.3;
  static double blockY = 0.3;
  double moneyX = blockX;
  double moneyY = blockY;
  int money = 0;

  void checkIfAteShrooms() {
    if ((marioX - shroomX).abs() < 0.05 && (marioY - shroomY).abs() < 0.05) {
      setState(() {
        // if eaten, move the shroom off the screen
        shroomX = 2;
        marioSize = 100;
      });
    }
  }

  // SHOW ME THE MONEY
  void releaseMoney() {
    money++;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        moneyY -= 0.1;
      });
      if (moneyY < -1) {
        timer.cancel();
        moneyY = blockY;
      }
    });
  }

  // FALL OFF THE PLATFORM
  void fall() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        marioY += 0.05;
      });
      if (marioY > 1) {
        marioY = 1;
        timer.cancel();
        midjump = false;
      }
    });
  }

  // CHECK IF MARIO IS ON THE PLATFORM
  bool onPlatform(double x, double y) {
    if ((x - blockX).abs() < 0.05 && (y - blockY).abs() < 0.3) {
      midjump = false;
      marioY = blockY - 0.28;
      return true;
    } else {
      return false;
    }
  }

  void preJump() {
    time = 0;
    initialHeight = marioY;
  }

  void jump() {
    // this first if statement disables the double jump

    if (midjump == false) {
      preJump();
      midjump = true;
      Timer.periodic(Duration(milliseconds: 50), (timer) {
        time += 0.05;
        height = -4.9 * time * time + 5 * time;

        print("marioX = " + marioX.toString());
        print("marioY = " + marioY.toString());

        // this prevents mario from going lower than the ground
        if (initialHeight - height > 1) {
          setState(() {
            marioY = 1;
          });
          midjump = false;
          timer.cancel();
        }
        // this prevents mario from jumping through the block
        else if (initialHeight - height < blockY + 0.3 &&
            initialHeight - height > blockY - 0.2 &&
            time < 0.5 &&
            (marioX - blockX).abs() < 0.05) {
          timer.cancel();
          fall();
          releaseMoney();
        }
        // this sets the new height
        else {
          setState(() {
            marioY = initialHeight - height;
          });
        }

        // stop jump if we land on the platform
        if (onPlatform(marioX, marioY)) {
          timer.cancel();
        }
      });
    }
  }

  // MOVE RIGHT
  void moveRight() {
    checkIfAteShrooms();
    direction = "right";
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      checkIfAteShrooms();
      if (MyButton().userIsHoldingButton() == true && marioX + 0.02 < 1) {
        setState(() {
          marioX += 0.02;
          midrun = !midrun;
        });
      } else {
        timer.cancel();
      }
      if (!onPlatform(marioX, marioY) && onPlatform(marioX - 0.1, marioY)) {
        fall();
      }
    });
    if (marioX + 0.02 < 1) {
      setState(() {
        marioX += 0.02;
        midrun = !midrun;
      });
    }

    if (!onPlatform(marioX, marioY) && onPlatform(marioX - 0.1, marioY)) {
      fall();
    }
  }

  // MOVE LEFT
  void moveLeft() {
    checkIfAteShrooms();
    direction = "left";
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      checkIfAteShrooms();
      if (MyButton().userIsHoldingButton() == true && marioX - 0.02 > -1) {
        setState(() {
          marioX -= 0.02;
          midrun = !midrun;
        });
      } else {
        timer.cancel();
      }

      // this checks if now mario is off the platform, and before it was on the platform
      if (!onPlatform(marioX, marioY) && onPlatform(marioX + 0.1, marioY)) {
        fall();
      }
    });

    if (marioX - 0.02 > -1) {
      setState(() {
        marioX -= 0.02;
        midrun = !midrun;
      });
    }

    if (!onPlatform(marioX, marioY) && onPlatform(marioX + 0.1, marioY)) {
      fall();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  color: Colors.blue,
                  child: AnimatedContainer(
                    alignment: Alignment(marioX, marioY),
                    duration: Duration(milliseconds: 0),
                    child: midjump
                        ? JumpingMario(
                            direction: direction,
                            size: marioSize,
                          )
                        : MyMario(
                            direction: direction,
                            midrun: midrun,
                            size: marioSize,
                          ),
                  ),
                ),
                Container(
                  alignment: Alignment(shroomX, shroomY),
                  child: MyShroom(),
                ),

                // money is hiding behind the block1
                Container(
                  alignment: Alignment(moneyX, moneyY),
                  child: Container(
                    color: Colors.green,
                    height: 30,
                    width: 30,
                    child: Center(
                        child: Text("\$",
                            style:
                                TextStyle(color: Colors.white, fontSize: 30))),
                  ),
                ),

                // block
                Container(
                  alignment: Alignment(blockX, blockY),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 30,
                      width: 30,
                      color: Colors.brown,
                      child: Center(
                          child: Text("?",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20))),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "MARIO",
                            style: gameFont,
                          ),
                          SizedBox(height: 10),
                          Text(money.toString(), style: gameFont)
                        ],
                      ),
                      Column(
                        children: [
                          Text("WORLD", style: gameFont),
                          SizedBox(height: 10),
                          Text("1-1", style: gameFont)
                        ],
                      ),
                      Column(
                        children: [
                          Text("TIME", style: gameFont),
                          SizedBox(height: 10),
                          Text("9999", style: gameFont)
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 10,
            color: Colors.green,
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.brown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    function: moveLeft,
                  ),
                  MyButton(
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    function: jump,
                  ),
                  MyButton(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    function: moveRight,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
