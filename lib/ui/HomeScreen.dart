import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:material_search/material_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_keeper_2/ui/login_page.dart';
import 'package:new_keeper_2/utils/slide_right_transition.dart';
import 'package:new_keeper_2/utils/slide_left_transition.dart';
import 'package:new_keeper_2/ui/GradientAppBar.dart';
import 'package:new_keeper_2/style/theme.dart' as Theme;
import 'package:new_keeper_2/ui/ChangePassword.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final titleInputController = new TextEditingController();
  final usernameInputController = TextEditingController();
  final passwordInputController = new TextEditingController();
  final oldPasswordInputController = new TextEditingController();
  final newPasswordInputController1 = new TextEditingController();
  final newPasswordInputController2 = new TextEditingController();
  static final searchInputController = new TextEditingController();

  List<Data> items = new List();
  List<Data> searchResults = new List();

  List<String> titles = [];
  List<String> usernames = [];
  List<String> passwords = [];
  List<String> decryptedTitles = [];

  final cryptor = new PlatformStringCryptor();
  String key;

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget password() {
    return Container(
      child: FloatingActionButton(
        elevation: 7.0,
        backgroundColor: const Color(0xFF2C365E),
        heroTag: 'PasswordFAB',
        //onPressed: changePasswordDialog,
        onPressed: () {
          Navigator.push(
            context,
            SlideLeftRoute(widget: ChangePassword()),
          );
        },
        tooltip: 'Change Password',
        child: Icon(
          Icons.account_circle,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        elevation: 7.0,
        backgroundColor: const Color(0xFF2C365E),
        heroTag: 'AddFAB',
        tooltip: 'Add',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          _showDialog("Add Details");
        },
      ),
    );
  }

  /*Widget thing() {
    return Container(
        child: FloatingActionButton(
            elevation: 7.0,
            backgroundColor: const Color(0xFF2C365E),
            heroTag: 'thingFAB',
            tooltip: "thing",
            child: Icon(
              Icons.ac_unit,
              color: Colors.white,
            ),
            onPressed: null));
  }*/

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        elevation: 7.0,
        backgroundColor: const Color(0xFF2C365E),
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          color: Colors.white,
          progress: _animateIcon,
        ),
      ),
    );
  }

  changePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Change Password",
            style: new TextStyle(color: const Color(0xFF2C365E)),
          ),
          content: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                decoration: InputDecoration(
                    hintText: 'Old',
                    fillColor: const Color(0xFF2C365E),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: const Color(0xFF2C365E)))),
                obscureText: true,
                controller: oldPasswordInputController,
              ),
              TextField(
                controller: newPasswordInputController1,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'New',
                    fillColor: const Color(0xFF2C365E),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: const Color(0xFF2C365E)))),
              ),
              TextField(
                controller: newPasswordInputController2,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'One more time',
                    fillColor: const Color(0xFF2C365E),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: const Color(0xFF2C365E)))),
              ),
            ]),
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  oldPasswordInputController.clear();
                  newPasswordInputController1.clear();
                  newPasswordInputController2.clear();
                  Navigator.of(context).pop();
                },
                child: new Text(
                  "CANCEL",
                  style: new TextStyle(color: const Color(0xFF2C365E)),
                )),
            new FlatButton(
              child: new Text(
                "SAVE",
                style: new TextStyle(color: const Color(0xFF2C365E)),
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var newPass1 = newPasswordInputController1.text;
                var newPass2 = newPasswordInputController2.text;
                var oldPass = oldPasswordInputController.text;
                if (newPass1 == newPass2 &&
                    oldPass == prefs.getString("password")) {
                  //Matches
                  prefs.setString("password", newPass1);
                  oldPasswordInputController.clear();
                  newPasswordInputController1.clear();
                  newPasswordInputController2.clear();
                  Navigator.of(context).pop();
                }
                if (newPass1 != newPass2) {
                  //Do not match

                  print("Passwords don't match");
                }
                if (prefs.getString("password") != oldPass) {
                  //Incorrect old pass
                  print("Incorrect Old Pass");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: const Color(0xFF2C365E),
      end: Colors.grey,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    loadCardData();
    _getEncryptionKey();
    setState(() {
      /*
      items.add(new Data("Google", "Username2", "Password2"));
      items.add(new Data("Twitter", "Username3", "Password3"));
      items.add(new Data("Uber", "Username4", "Password4"));
      items.add(new Data("Steam", "Username5", "Password5"));
      items.add(new Data("Apple", "Username1", "Password1"));
      */
    });
  }

  _getEncryptionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //get encryption key
    key = prefs.getString("key");
    print("encryption key retrieved -> " + key);
  }


  loadCardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    titles = prefs.getStringList("titles");
    usernames = prefs.getStringList("usernames");
    passwords = prefs.getStringList("passwords");
    print("retrieved encrypted data...");
    try {
      print("array not empty, populate list size: " + titles.length.toString());
      //Array not empty
      for (int i = 0; i < titles.length; i++) {
        String decryptedTitle = "", decryptedUsername = "", decryptedPassword = "";
        print("encrypted title: " + titles[i] + "\nencrypted username: " + usernames[i] + "\nencrypted password: " + passwords[i]);
        key = prefs.getString("key");
        try {
          decryptedTitle = await cryptor.decrypt(titles[i], key);
          decryptedUsername = await cryptor.decrypt(usernames[i], key);
          decryptedPassword = await cryptor.decrypt(passwords[i], key);
          print("DECRYPTED TITLE: " + titles[i] + " -> " + decryptedTitle + "\nDECRYPTED USERNAME: " + usernames[i] +
              " -> " + decryptedUsername + "\nDECRYPTED PASSWORD: " + passwords[i] + " -> " + decryptedPassword);
        } on MacMismatchException {
          print("mismatch exception");
        }
        /*try {

        } on MacMismatchException {
          // unable to decrypt (wrong key or forged data)
          print("unable to decrypt (wrong key or forged data)");
        }*/
        setState(() {
          items.add(new Data(decryptedTitle, decryptedUsername, decryptedPassword));
        });
      }
    } catch (e) {
      //Array empty
      print("array empty, show first-time dialogs");
      showDialog(
          context: context,
          barrierDismissible: false,
          child: new AlertDialog(
            title: new Text(
              "Add Passwords",
              style: new TextStyle(fontSize: 16.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  color: const Color(0xFF2C365E),
                  elevation: 3.0,
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 12.0, left: 12.0, bottom: 10.0),
                              child: Text(
                                'Title',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            Container(
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 30.0),
                                      child: Icon(
                                        Icons.account_box,
                                        size: 22.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                            top: 10.0, left: 10.0),
                                        child: Text(
                                          'Username',
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              color: Colors.white),
                                        ))
                                  ],
                                  //padding: const EdgeInsets.only(left: 8.0),
                                )),
                            Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, left: 30.0, bottom: 20.0),
                                      child: Icon(
                                        Icons.vpn_key,
                                        size: 22.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 15.0, bottom: 20.0),
                                        child: Text(
                                          'Password',
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              color: Colors.white),
                                        ))
                                  ],
                                ))
                          ]),
                    ),
                  ]),
                ),
                Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text("Use the add button to create a card"))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        child: new AlertDialog(
                          title: new Text(
                            "Delete Cards",
                            style: new TextStyle(fontSize: 16.0),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Dismissible(
                                key: Key("key"),
                                onDismissed: (direction) {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                    barrierDismissible: false,
                                    child: new AlertDialog(
                                      title: new Text(
                                        "Long press to edit",
                                          style: new TextStyle(
                                              fontSize: 16.0,
                                              //color: const Color(0xFF2C365E),
                                          )
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/img/long_press.png',
                                            color: const Color(0xFF2C365E),
                                          )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: new Text("OK")
                                        )
                                      ],
                                    )
                                  );
                                },
                                child: Card(
                                  elevation: 3.0,
                                  child: Row(children: [
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  top: 12.0,
                                                  left: 12.0,
                                                  bottom: 10.0),
                                              child: Text(
                                                'Title',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: const Color(
                                                        0xFF2C365E)
                                                ),
                                              ),
                                            ),
                                            Container(
                                                child: Row(
                                                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Container(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0,
                                                          left: 30.0),
                                                      child: Icon(
                                                        Icons.account_box,
                                                        size: 22.0,
                                                        color: const Color(
                                                            0xFF2C365E),
                                                      ),
                                                    ),
                                                    Container(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0,
                                                            left: 10.0),
                                                        child: Text(
                                                          'Username',
                                                          style: TextStyle(
                                                              fontSize: 17.0,
                                                              color: const Color(
                                                                  0xFF2C365E)),
                                                        ))
                                                  ],
                                                  //padding: const EdgeInsets.only(left: 8.0),
                                                )),
                                            Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          top: 15.0,
                                                          left: 30.0,
                                                          bottom: 20.0),
                                                      child: Icon(
                                                        Icons.vpn_key,
                                                        size: 22.0,
                                                        color: const Color(
                                                            0xFF2C365E),
                                                      ),
                                                    ),
                                                    Container(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            top: 15.0,
                                                            bottom: 20.0),
                                                        child: Text(
                                                          'Password',
                                                          style: TextStyle(
                                                              fontSize: 17.0,
                                                              color: const Color(
                                                                  0xFF2C365E)),
                                                        ))
                                                  ],
                                                ))
                                          ]),
                                    ),
                                  ]),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "Swipe to delete",
                                  )
                              )
                            ],
                          ),
                        ));
                  },
                  child: new Text(
                    "OK"/*,
                    style: TextStyle(
                        color: const Color(
                            0xFF2C365E)
                    ),*/
                  )
              )
            ],
          ));
    }
    items
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  void _showDialog(String dialogTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            dialogTitle,
            style: new TextStyle(color: const Color(0xFF2C365E)),
          ),
          content: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                decoration: InputDecoration(
                    hintText: 'Title',
                    fillColor: const Color(0xFF2C365E),
                    suffixIcon: new Icon(
                      Icons.assistant_photo,
                      color: const Color(0xFF2C365E),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: const Color(0xFF2C365E)))),
                controller: titleInputController,
                autocorrect: false,
              ),
              TextField(
                controller: usernameInputController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                    hintText: 'Username',
                    fillColor: const Color(0xFF2C365E),
                    suffixIcon: new Icon(
                      Icons.account_box,
                      color: const Color(0xFF2C365E),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: const Color(0xFF2C365E)))),
              ),
              TextField(
                controller: passwordInputController,
                autocorrect: false,
                decoration: InputDecoration(
                    hintText: 'Password',
                    fillColor: const Color(0xFF2C365E),
                    suffixIcon: new Icon(
                      Icons.vpn_key,
                      color: const Color(0xFF2C365E),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: const Color(0xFF2C365E)))),
              )
            ]),
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  titleInputController.clear();
                  usernameInputController.clear();
                  passwordInputController.clear();
                  Navigator.of(context).pop();
                },
                child: new Text(
                  "CANCEL",
                  style: new TextStyle(color: const Color(0xFF2C365E)),
                )),
            new FlatButton(
              child: new Text(
                "SAVE",
                style: new TextStyle(color: const Color(0xFF2C365E)),
              ),
              onPressed: () async {
                if (titleInputController.text == null) {
                  titleInputController.text = "";
                }
                if (usernameInputController.text == null) {
                  usernameInputController.text = "";
                }
                if (passwordInputController.text == null) {
                  passwordInputController.text = "";
                }
                Data newCard = new Data(
                    titleInputController.text,
                    usernameInputController.text,
                    passwordInputController.text);
                setState(() {
                  items.add(newCard);
                  items.sort((a, b) =>
                      a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                print("encrypting data...");
                key = prefs.getString("key");
                String encryptedTitle = "", encryptedUsername = "", encryptedPassword = "";
                try {
                  encryptedTitle = await cryptor.encrypt(titleInputController.text, key);
                  encryptedUsername = await cryptor.encrypt(usernameInputController.text, key);
                  encryptedPassword = await cryptor.encrypt(passwordInputController.text, key);
                } on MacMismatchException {
                  print("unable to decrypt (wrong key or forged data)");
                }
                print("ENCRYPTED TITLE: " + titleInputController.text + " -> " + encryptedTitle + "\nENCRYPTED USERNAME: " +
                usernameInputController.text + " -> " + encryptedUsername + "\nENCRYPTED PASSWORD: " + passwordInputController.text +
                " -> " + encryptedPassword);
                int index = items.indexOf(newCard);
                print("Insert index: " + index.toString());
                try {
                  print("Appending array and storing: " +
                      titleInputController.text);
                  //titles.add(encryptedTitle);
                  titles.insert(index, encryptedTitle);
                  //titles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  //usernames.add(encryptedUsername);
                  usernames.insert(index, encryptedUsername);
                  //usernames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  //passwords.add(encryptedPassword);
                  passwords.insert(index, encryptedPassword);
                  //passwords.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  prefs.setStringList("titles", titles);
                  prefs.setStringList("usernames", usernames);
                  prefs.setStringList("passwords", passwords);
                } catch (e) {
                  print("Storing first value: " + titleInputController.text);
                  prefs.setStringList("titles", [encryptedTitle]);
                  prefs.setStringList("usernames", [encryptedUsername]);
                  prefs.setStringList("passwords", [encryptedPassword]);
                }
                titleInputController.clear();
                usernameInputController.clear();
                passwordInputController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _name = 'No one';

  _decryptTitles(List<String> titles) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    decryptedTitles.clear();
    for (int i = 0; i < titles.length; i++) {
      key = prefs.getString("key");
      try {
        String decrypted = await cryptor.decrypt(titles[i], key);
        decryptedTitles.add(decrypted);
      } on MacMismatchException {
        print("error decrypting " + titles[i] + " with key " + key + "...");
      }
    }
  }

  _buildMaterialSearchPage(BuildContext context) {
    _decryptTitles(titles);
    return new MaterialPageRoute<String>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        builder: (BuildContext context) {
          return new Material(
            child: new MaterialSearch<String>(
              placeholder: 'Search',
              results: decryptedTitles
                  .map((String v) => new MaterialSearchResult<String>(
                        icon: Icons.chevron_right,
                        value: v,
                        text: v,
                      ))
                  .toList(),
              filter: (dynamic value, String criteria) {
                return value.toLowerCase().trim().contains(
                    new RegExp(r'' + criteria.toLowerCase().trim() + ''));
              },
              onSelect: (dynamic value) =>
                  _returnSearchData(value), //Navigator.of(context).pop(value),
              onSubmit: (String value) => Navigator.of(context).pop(value),
            ),
          );
        });
  }

  _returnSearchData(String title) async {
    print("Clicked: " + title);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> titles = prefs.getStringList("titles");
    List<String> users = prefs.getStringList("usernames");
    List<String> passwords = prefs.getStringList("passwords");
    var username;
    var password;
    for (int i = 0; i < titles.length; i++) {
      String decryptedTitle = await cryptor.decrypt(titles[i], key);
      String decryptedUsername = await cryptor.decrypt(users[i], key);
      String decryptedPassword = await cryptor.decrypt(passwords[i], key);
      if (decryptedTitle == title) {
        username = decryptedUsername;
        password = decryptedPassword;
        break;
      }
    }
    showDialog(
        context: context,
        barrierDismissible: true,
        child: new AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          content: ConstrainedBox(
            constraints: new BoxConstraints.expand(
                height: 182.0, width: MediaQuery.of(context).size.width),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 12.0, left: 12.0, bottom: 20.0),
                          child: Text(
                            '$title',
                            style: TextStyle(
                                fontSize: 20.0, color: const Color(0xFF2C365E)),
                          ),
                        ),
                        Container(
                            child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 10.0, left: 20.0),
                              child: Icon(
                                Icons.account_box,
                                size: 22.0,
                                color: const Color(0xFF2C365E),
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 10.0),
                                child: Text(
                                  '$username',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    //color: Colors.grey
                                  ),
                                ))
                          ],
                          //padding: const EdgeInsets.only(left: 8.0),
                        )),
                        Container(
                            child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 20.0, bottom: 20.0),
                              child: Icon(
                                Icons.vpn_key,
                                size: 22.0,
                                color: const Color(0xFF2C365E),
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.only(
                                    left: 10.0, top: 15.0, bottom: 20.0),
                                child: Text(
                                  '$password',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    //color: Colors.grey
                                  ),
                                ))
                          ],
                        ))
                      ]),
                ),
                //Container(padding: EdgeInsets.only(top: 20.0), child: Text("Swipe to delete"))
              ],
            ),
          ),
        ));
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
        .push(_buildMaterialSearchPage(context))
        .then((dynamic value) {
      setState(() => _name = value as String);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new PreferredSize(
          child: new Container(
            padding:
                new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: new Padding(
                padding:
                    const EdgeInsets.only(left: 00.0, top: 10.0, bottom: 10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: IconButton(
                          tooltip: "Logout",
                          icon: new Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            //Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()), (Route<dynamic> route) => false);
                            Navigator.push(
                              context,
                              SlideRightRoute(widget: LoginPage()),
                            );
                          }),
                    ),
                    Container(
                      child: Text(
                        "My Passwords",
                        style: new TextStyle(
                            color: Colors.white,
                            fontFamily: "WorkSans",
                            fontSize: 20.0, ),
                      ),
                    ),
                    Container(
                      child: new IconButton(
                        onPressed: () {
                          _showMaterialSearch(context);
                        },
                        tooltip: 'Search',
                        icon: new Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
            decoration: new BoxDecoration(
                gradient: new LinearGradient(colors: [const Color(0xFF3A506B), const Color(0xFF2C365E)]),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    blurRadius: 20.0,
                    spreadRadius: 1.0,
                  )
                ]),
          ),
          preferredSize: new Size(MediaQuery.of(context).size.width, 150.0),
        ),
        body: Container(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >= 775.0
                ? MediaQuery.of(context).size.height
                : 775.0,
            decoration: new BoxDecoration(
              /*
              gradient: new LinearGradient(
                  colors: [
                    Theme.Colors.loginGradientStart,
                    Theme.Colors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),*/
              color: Colors.white
            ),
            child: new Center(
              child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.all(15.0),
                itemExtent: 150.0,
                itemBuilder: (context, position) {
                  final Data item = items[position];
                  return Column(
                    children: <Widget>[
                      //Divider(height: 5.0),
                      Dismissible(
                          key: Key('$items[position]'),
                          //movementDuration: new Duration(milliseconds: 30),
                          onDismissed: (direction) async {
                            int index = items.indexOf(item);
                            print("Index: " + index.toString());
                            String titleToDelete = await cryptor.decrypt(titles[index], key);
                            String usernameToDelete = await cryptor.decrypt(usernames[index], key);
                            String passwordsToDelete = await cryptor.decrypt(passwords[index], key);
                            setState(() {
                              items.removeAt(index);
                            });
                            print("Delete at: " + index.toString());
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            //print("Remove: " + item.title + ", " + item.username + ", " + item.password + "\nMatches in Lists: " + titleToDelete + ", " + usernameToDelete + ", " + passwordsToDelete);
                            titles.removeAt(index);
                            usernames.removeAt(index);
                            passwords.removeAt(index);
                            prefs.setStringList("titles", titles);
                            prefs.setStringList("usernames", usernames);
                            prefs.setStringList("passwords", passwords);
                            print("Deleted");
                            Scaffold.of(context).showSnackBar(SnackBar(
                              backgroundColor: const Color(0xFF2C365E),
                              content: Text(titleToDelete + " deleted"),
                              action: SnackBarAction(
                                  label: "UNDO",
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    setState(() {
                                      items.add(new Data(titleToDelete,
                                          usernameToDelete, passwordsToDelete));
                                      items.sort((a, b) => a.title
                                          .toLowerCase()
                                          .compareTo(b.title.toLowerCase()));
                                    });
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String encryptedTitle = await cryptor.encrypt(titleToDelete, key);
                                    String encryptedUsername = await cryptor.encrypt(usernameToDelete, key);
                                    String encryptedPassword = await cryptor.encrypt(passwordsToDelete, key);
                                    try {
                                      print("Appending array and storing: " +
                                          titleToDelete);
                                      //titles.add(encryptedTitle);
                                      titles.insert(position, encryptedTitle);
                                      //titles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                                      //usernames.add(encryptedUsername);
                                      usernames.insert(position, encryptedUsername);
                                      //usernames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                                      //passwords.add(encryptedPassword);
                                      passwords.insert(position, encryptedPassword);
                                      //passwords.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                                      prefs.setStringList("titles", titles);
                                      prefs.setStringList(
                                          "usernames", usernames);
                                      prefs.setStringList(
                                          "passwords", passwords);
                                    } catch (e) {
                                      print("Storing first value: " +
                                          titleToDelete);
                                      prefs.setStringList(
                                          "titles", [encryptedTitle]);
                                      prefs.setStringList(
                                          "usernames", [encryptedUsername]);
                                      prefs.setStringList(
                                          "passwords", [encryptedPassword]);
                                    }
                                  }),
                            ));
                          },
                          child: GestureDetector(
                            onLongPress: () {
                              print("Tapped card no. " + position.toString());
                              //preload data
                              titleInputController.text = '${items[position].title}';
                              usernameInputController.text = '${items[position].username}';
                              passwordInputController.text = '${items[position].password}';
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text(
                                      "Edit Card",
                                      style: new TextStyle(color: const Color(0xFF2C365E)),
                                    ),
                                    content: Container(
                                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                                        TextField(
                                          decoration: InputDecoration(
                                              hintText: 'Title',
                                              fillColor: const Color(0xFF2C365E),
                                              suffixIcon: new Icon(
                                                Icons.assistant_photo,
                                                color: const Color(0xFF2C365E),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide:
                                                  BorderSide(color: const Color(0xFF2C365E)))),
                                          controller: titleInputController,
                                          autocorrect: false,
                                        ),
                                        TextField(
                                          controller: usernameInputController,
                                          keyboardType: TextInputType.emailAddress,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                              hintText: 'Username',
                                              fillColor: const Color(0xFF2C365E),
                                              suffixIcon: new Icon(
                                                Icons.account_box,
                                                color: const Color(0xFF2C365E),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide:
                                                  BorderSide(color: const Color(0xFF2C365E)))),
                                        ),
                                        TextField(
                                          controller: passwordInputController,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                              hintText: 'Password',
                                              fillColor: const Color(0xFF2C365E),
                                              suffixIcon: new Icon(
                                                Icons.vpn_key,
                                                color: const Color(0xFF2C365E),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide:
                                                  BorderSide(color: const Color(0xFF2C365E)))),
                                        )
                                      ]),
                                    ),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text(
                                          "CANCEL",
                                          style: new TextStyle(color: const Color(0xFF2C365E)),
                                        ),
                                        onPressed: () {
                                          titleInputController.clear();
                                          usernameInputController.clear();
                                          passwordInputController.clear();
                                          Navigator.of(context).pop();
                                          },
                                      ),
                                      new FlatButton(
                                        child: new Text(
                                          "SAVE",
                                          style: new TextStyle(color: const Color(0xFF2C365E)),
                                        ),
                                        onPressed: () async {
                                          String newUsername = usernameInputController.text;
                                          String newPassword = passwordInputController.text;
                                          String newTitle = titleInputController.text;
                                          //delete old
                                          setState(() {
                                            items.removeAt(position);
                                          });
                                          print("Delete at: " + position.toString());
                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          //print("Remove: " + item.title + ", " + item.username + ", " + item.password + "\nMatches in Lists: " + titleToDelete + ", " + usernameToDelete + ", " + passwordsToDelete);
                                          titles.removeAt(position);
                                          usernames.removeAt(position);
                                          passwords.removeAt(position);
                                          prefs.setStringList("titles", titles);
                                          prefs.setStringList("usernames", usernames);
                                          prefs.setStringList("passwords", passwords);
                                          print("Deleted");

                                          //Insert new
                                          setState(() {
                                            items.add(new Data(newTitle,
                                                newUsername, newPassword));
                                            items.sort((a, b) => a.title
                                                .toLowerCase()
                                                .compareTo(b.title.toLowerCase()));
                                          });
                                          String encryptedTitle = await cryptor.encrypt(newTitle, key);
                                          String encryptedUsername = await cryptor.encrypt(newUsername, key);
                                          String encryptedPassword = await cryptor.encrypt(newPassword, key);
                                          try {
                                            print("Appending array and storing: " +
                                                newTitle);
                                            //titles.add(encryptedTitle);
                                            titles.insert(position, encryptedTitle);
                                            //titles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                                            //usernames.add(encryptedUsername);
                                            usernames.insert(position, encryptedUsername);
                                            //usernames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                                            //passwords.add(encryptedPassword);
                                            passwords.insert(position, encryptedPassword);
                                            //passwords.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                                            prefs.setStringList("titles", titles);
                                            prefs.setStringList(
                                                "usernames", usernames);
                                            prefs.setStringList(
                                                "passwords", passwords);
                                          } catch (e) {
                                            print("Storing first value: " +
                                                newTitle);
                                            prefs.setStringList(
                                                "titles", [encryptedTitle]);
                                            prefs.setStringList(
                                                "usernames", [encryptedUsername]);
                                            prefs.setStringList(
                                                "passwords", [encryptedPassword]);
                                          }
                                          titleInputController.clear();
                                          usernameInputController.clear();
                                          passwordInputController.clear();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 3.0,
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 12.0,
                                              left: 12.0,
                                              bottom: 10.0),
                                          child: Text(
                                            '${items[position].title}',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: const Color(0xFF2C365E),
                                              fontFamily: "WorkSans",
                                            ),
                                          ),
                                        ),
                                        Container(
                                            child: Row(
                                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(
                                                      top: 10.0, left: 30.0),
                                                  child: Icon(
                                                    Icons.account_box,
                                                    size: 22.0,
                                                    color: const Color(0xFF2C365E),
                                                  ),
                                                ),
                                                Container(
                                                    padding: const EdgeInsets.only(
                                                        top: 10.0, left: 10.0),
                                                    child: Text(
                                                      '${items[position].username}',
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        color:
                                                        const Color(0xFF2C365E),
                                                        fontFamily: "WorkSans",
                                                      ),
                                                    ))
                                              ],
                                              //padding: const EdgeInsets.only(left: 8.0),
                                            )),
                                        Container(
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  padding: const EdgeInsets.only(
                                                      top: 15.0,
                                                      left: 30.0,
                                                      bottom: 20.0),
                                                  child: Icon(
                                                    Icons.vpn_key,
                                                    size: 22.0,
                                                    color: const Color(0xFF2C365E),
                                                  ),
                                                ),
                                                Container(
                                                    padding: const EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 15.0,
                                                        bottom: 20.0),
                                                    child: Text(
                                                      '${items[position].password}',
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        color:
                                                        const Color(0xFF2C365E),
                                                        fontFamily: "WorkSans",
                                                      ),
                                                    ))
                                              ],
                                            ))
                                      ]),
                                ),
                              ]),
                            ),
                          )
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                //_translateButton.value * 3.0,
                _translateButton.value * 2.0,
                0.0,
              ),
              child: password(),
            ),
            /*Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * 2.0,
                0.0,
              ),
              child: thing(),
            ),*/
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value,
                0.0,
              ),
              child: add(),
            ),
            toggle(),
          ],
        ));
  }
}

class Data {
  final String title;
  final String username;
  final String password;

  Data(this.title, this.username, this.password);
}

/*floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _showDialog();
        },
        tooltip: 'Add',
        child: new Icon(Icons.add),
      ),*/

/*appBar: new AppBar(
        leading: IconButton(
            tooltip: "Logout",
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              //Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()), (Route<dynamic> route) => false);
              Navigator.push(
                context,
                SlideRightRoute(widget: LoginPage()),
              );
            }),
        title: new Text(widget.title),
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              _showMaterialSearch(context);
            },
            tooltip: 'Search',
            icon: new Icon(Icons.search),
          )
        ],
      ),*/
