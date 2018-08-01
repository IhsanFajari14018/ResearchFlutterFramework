// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//import 'package:english_words/english_words.dart';

import 'dart:async';
import 'dart:convert' show json;

import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

void main() {
  runApp(
    new MaterialApp(
        title: 'Google Sign In',
        home: new SignInDemo(),
        routes: <String, WidgetBuilder>{
          "/HomePage": (BuildContext context) => new HomePage()
        }
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => new SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;
  String _contactText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<Null> _handleGetContact() async {
    setState(() {
      _contactText = "";
    });
    final http.Response response = await http.get(
      'https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names',
      headers: await _currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }

    final Map<String, dynamic> data = json.decode(response.body);
    RandomWordsState.setData(data);

  }

  Future<Null> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleSignOut() async {
    _googleSignIn.disconnect();
  }

  // PAGE DISPLAY :
  Widget _buildBody() {
    if (_currentUser != null) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new ListTile(
            leading: new GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: new Text(_currentUser.displayName),
            subtitle: new Text(_currentUser.email),
          ),
          const Text("Signed in successfully."),
          new Text(_contactText),
          new RaisedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          new RaisedButton(
            child: const Text('CONTACT'),
            //onPressed: _handleGetContact,
            onPressed: () {Navigator.of(context).pushNamed("/HomePage");},
          ),
          new RaisedButton(
            child: const Text('REFRESH'),
            onPressed: _handleGetContact,
          ),
        ],
      );
    } else {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          new RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('Google Sign In'),
        ),
        body: new ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}




//
// ============================ ListView Widget ================================
// The project guide :
// https://flutter.io/get-started/codelab/
// 25/07/2018
//

///**

class HomePage extends StatelessWidget {

  //Latest Code
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Startup Name Generator v1.3',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

//Class to generate random words
class RandomWords extends StatefulWidget{
  @override
  createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords>{
  //final _suggestions = <WordPair>[]; //DEFAULT
  var _suggestions = <String>[];
  final _contactSuggestions = <String>[];

  final _saved = Set<String>();
  final _biggerFont = const TextStyle(fontSize:18.0);

  static List<dynamic> connections;

  int _contactLength;
  int _currentIndex = 0;

  static void setData(Map<String, dynamic> data){
    connections = data['connections'];
  }

  void configureData(){
    _contactLength = connections.length;

    //Call corresponding method.
    dataToArrayOfString();
    setSuggestionToContact();

  }

  // This method is used to fill all the contact name to _suggestions variable.
  // Later on, the _suggestions will  be used to generate listView builder item.
  void dataToArrayOfString(){
    //string to keep value of contact name before returned.
    String nameValue = "INFO: Still empty.";


    Map<String, dynamic> contact;
    int _idx = 0;
    // ignore: prefer_is_not_empty
    while(_idx<connections.length-1) {
      contact = connections.elementAt(_idx);

      if (contact != null) {
        final Map<String, dynamic> name = contact['names'].firstWhere(
              (dynamic name) => name['displayName'] != null,
          orElse: () => null,
        );
        if (name != null) {
          nameValue = name['displayName'];
        }
      }

      // push value
      _contactSuggestions.add(nameValue);
      // update index
        _idx++;
    }
  }

  //Fill the variable for generator with contact data.
  void setSuggestionToContact(){
    _suggestions = _contactSuggestions;
  }

  // Ferify the _suggestion[], does it already has a corresponding value
  // if yes return true to push the contact name to be build in itemBuilder,
  // else return false which means that the contact name already pushed.
  bool isInSuggestions(String name){

    if(_suggestions.contains(name)){
      return true;
    }else{
      return false;
    }
  }

  // It used reset the index to 0.
  // This method will keep the contact in ListView are arranged as it's
  // supposed to.
  void resetIndex(){
    _currentIndex = 0;
  }

  // Index updater for pointing the contact name in _suggestions[]
  void updateIndex(){
    _currentIndex++;
    print("$_currentIndex   $_contactLength");

    // Reset
    if(_currentIndex>_contactLength-1){
      // debugger
      print("ASUP $_currentIndex > $_contactLength");
      resetIndex();
    }
  }

  // TODO : Change the logic to return contact name! DONE
  // TODO : CHANGE THIS ALGORITHM TO MAKE THIS FIT! ALMOST DONE
  Widget _buildSuggestions() {
      return ListView.builder(
          padding: const EdgeInsets.all(16.0),

          itemBuilder: (context, i) {
              int _idx = _currentIndex;
              updateIndex();

              // debugger
              // String temp = _suggestions.toString();
              print("ISI SUGGEST $_idx");

              // check is contact exist,
              // if not dont push.
              if(isInSuggestions(_suggestions[_idx])){
                return _buildRow(_suggestions[_idx]);
              }else{
                print("IRAHA ABUS KADIEU?");
                return _buildRow("0");
              }

          }

      );

  }

  // The widget builder!
  @override
  Widget build(BuildContext context){

    // Configuring data before building widget and
    // all of its content.
    configureData();
    resetIndex();
    
    return Scaffold(
      appBar: AppBar(
        title: Text("List of concated word"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  //This method support the build method.
  void _pushSaved(){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context){
          resetIndex();
          final tiles = _saved.map(
                (pair) {
              return ListTile(
                title: Text(
                  pair,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          )
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  //
  // Now the tiles is tappable
  // TODO: Wordpair should String! DONE
  Widget _buildRow(String pair){
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: (){
        setState(() {
          if(alreadySaved){
            print("eusina pair REMOVE : $pair");
            resetIndex();
            _saved.remove(pair);
          }else{
            print("eusina pair ADD: $pair");
            resetIndex();
            _saved.add(pair);
          }
        });
      },
    );
  }
}