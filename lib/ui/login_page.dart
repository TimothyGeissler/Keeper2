import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_keeper_2/style/theme.dart' as Theme;
import 'package:new_keeper_2/utils/bubble_indication_painter.dart';
import 'package:new_keeper_2/ui/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_keeper_2/utils/slide_right_transition.dart';
import 'package:new_keeper_2/utils/slide_left_transition.dart';
import 'package:new_keeper_2/ui/FirstLaunch.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  final cryptor = new PlatformStringCryptor();
  String key;

  TextEditingController loginPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= 775.0 ? MediaQuery.of(context).size.height : 775.0,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Theme.Colors.loginGradientStart, Theme.Colors.loginGradientEnd],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: _buildSignIn(context)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _getEncryptionKey();

    _pageController = PageController();
    _checkFirstLaunch();
  }

   _getEncryptionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //get encryption key
    key = prefs.getString("key");
    print("encryption key retrieved -> " + key);
  }

  _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int firstLaunch = null;
    firstLaunch = prefs.getInt("firstLaunch");
    //print('firstLaunch: ${firstLaunch.toString()}');
    if (firstLaunch == null) {
      //Firstlaunch true
      Navigator.push(
        context,
        SlideRightRoute(widget: FirstLaunch()),
      );
      prefs.setInt("firstLaunch", 1);
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 70.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Icon(
              Icons.lock_open,
              size: 180.0,
              color: Colors.white,
            ),
          ),
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 3.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 110.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 05.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                FontAwesomeIcons.eye,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.Colors.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  color: const Color(0xFF2C365E)
                ),
                child: MaterialButton(
                    elevation: 3,
                    highlightColor: Colors.transparent,
                    splashColor: Theme.Colors.loginGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.white, fontSize: 25.0, fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int incorrectCount = prefs.getInt("tries");
                      String encryptedPassword = prefs.getString("password");
                      String decryptedPassword;
                      try {
                        decryptedPassword = await cryptor.decrypt(encryptedPassword, key);
                        print("DECRYPTED PASSWORD: " + encryptedPassword + " -> " + decryptedPassword);
                      } on MacMismatchException {
                        print("unable to decrypt password, wrong key/forged data");
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            child: new AlertDialog(
                              title: new Text(
                                "Password has been compromised!",
                                style: new TextStyle(fontSize: 16.0),
                              ),
                              content: ConstrainedBox(
                                constraints: new BoxConstraints.expand(height: 25.0),
                                child: Column(
                                    children: [new Text("Erase data and reset password?")]),
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: new Text("CANCEL"),
                                ),
                                new FlatButton(
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                      Navigator.pop(context);
                                      Navigator.pushReplacementNamed(context, "/first");
                                      incorrectCount = 0;
                                      prefs.setInt("tries", incorrectCount);
                                      prefs.clear();
                                      prefs.setInt("firstLaunch", 1);
                                    },
                                    child: new Text("OK"))
                              ],
                            ));
                      }
                      if (incorrectCount == null) {
                        incorrectCount = 0;
                      }
                      if (loginPasswordController.text == decryptedPassword) {
                        incorrectCount = 0;
                        prefs.setInt("tries", incorrectCount);
                        loginPasswordController.clear();
                        Navigator.of(context).pushAndRemoveUntil(
                            new MaterialPageRoute(builder: (BuildContext context) => new MyHomePage(title: 'My Passwords')),
                                (Route<dynamic> route) => false);
                      } else {
                        incorrectCount = incorrectCount + 1;
                        print("tries: " + incorrectCount.toString());
                        if (incorrectCount > 3) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: new AlertDialog(
                                title: new Text(
                                  "Reset password?",
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                content: ConstrainedBox(
                                  constraints: new BoxConstraints.expand(height: 25.0),
                                  child: Column(
                                      children: [new Text("Erase data and reset password?")]),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: new Text("CANCEL"),
                                  ),
                                  new FlatButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                        Navigator.pop(context);
                                        Navigator.pushReplacementNamed(context, "/first");
                                        incorrectCount = 0;
                                        prefs.setInt("tries", incorrectCount);
                                        prefs.clear();
                                        prefs.setInt("firstLaunch", 1);
                                      },
                                      child: new Text("OK"))
                                ],
                              ));
                        } else {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: new AlertDialog(
                                title: new Text(
                                  "Incorrect password",
                                  style: new TextStyle(
                                      fontSize: 16.0,
                                      color: const Color(0xFF2C365E),
                                  ),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: new Text("OK"))
                                ],
                              ));
                        }
                        prefs.setInt("tries", incorrectCount);
                      }
                    }),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
            child: FlatButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text(
                          "Change Password?",
                          style: new TextStyle(
                            color: const Color(0xFF2C365E),
                          ),
                        ),
                        content: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Changing your password will erase all data",
                              style: new TextStyle(
                                color: const Color(0xFF2C365E),
                              ),
                            )
                          ],
                        ),
                        actions: <Widget>[
                          new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: new Text(
                                "CANCEL",
                                style: new TextStyle(
                                  color: const Color(0xFF2C365E),
                                ),
                              )),
                          new FlatButton(
                            child: new Text(
                              "OK",
                              style: new TextStyle(
                                color: const Color(0xFF2C365E),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlideRightRoute(widget: FirstLaunch()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(decoration: TextDecoration.underline, color: Colors.white, fontSize: 16.0, fontFamily: "WorkSansMedium"),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        Colors.white10,
                        Colors.white,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                width: 100.0,
                height: 1.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 00.0),
                child: Text(
                  "Or",
                  style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: "WorkSansMedium"),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white10,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                width: 100.0,
                height: 1.0,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0, right: 0.0),
                child: GestureDetector(
                  onTap: () async {
                    var localAuth = new LocalAuthentication();
                    bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason: 'Use fingerprint to login');
                    if (didAuthenticate) {
                      Navigator.of(context).pushAndRemoveUntil(
                          new MaterialPageRoute(builder: (BuildContext context) => new MyHomePage(title: 'My Passwords')),
                          (Route<dynamic> route) => false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: new Icon(
                      FontAwesomeIcons.fingerprint,
                      color: const Color(0xFF2C365E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
}
