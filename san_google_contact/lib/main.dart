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

    //print out into terminal
    //print(data);

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

//  Old variable
//  final _suggestions = <WordPair>[];
//  final _biggerFont = const TextStyle(fontSize: 18.0);

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

    // debugger :
    // print("ASUP KENEH KADIEU : $nameValue");

    Map<String, dynamic> contact;
    // ignore: prefer_is_not_empty
    while(!connections.isEmpty) {
      contact = connections.removeLast();

      if (contact != null) {
        final Map<String, dynamic> name = contact['names'].firstWhere(
              (dynamic name) => name['displayName'] != null,
          orElse: () => null,
        );
        if (name != null) {
          nameValue = name['displayName'];
        }
      }

      _contactSuggestions.add(nameValue);
    }
  }

  //Fill the variable for generator with contact data.
  void setSuggestionToContact(){
    _suggestions = _contactSuggestions;
  }

  void updateIndex(){
    _currentIndex++;
    print("$_currentIndex   $_contactLength");
    // Reset
    if(_currentIndex>_contactLength-1){
      print("ASUP");
      _currentIndex=0;
    }
  }

  // TODO : Change the logic to return contact name!
  // TODO : CHANGE THIS ALGORITHM TO MAKE THIS FIT!
  Widget _buildSuggestions() {

      return ListView.builder(
          padding: const EdgeInsets.all(16.0),

          // CUSTOM ALGORITHM :
          itemBuilder: (context, i) {
            //if(_currentIndex<_contactLength) {
              int _idx = _currentIndex;
              updateIndex();
              return _buildRow(_suggestions[_idx]);
          }

      );

  }

  // The widget builder!
  @override
  Widget build(BuildContext context){

    // Configuring data before building widget and
    // all of its content.
    configureData();

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
    //_counter++;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context){
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
            _saved.remove(pair);
          }else{
            print("eusina pair ADD: $pair");
            _saved.add(pair);
          }
        });
      },
    );
  }
}