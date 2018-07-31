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

  //Retrieve data from google
  //send to method to return 1 of the contact
  Future<Null> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
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

    // Set data to RandomWordsState
    // It will be used to to retrieve all contact.
    RandomWordsState.setData(data);

    //print out into terminal
    print("I WANT TO SEE THIS data :");
    print(data);

    //final String namedContact = _pickFirstNamedContact(data);

//    setState(() {
//      if (namedContact != null) {
//        _contactText = "I see you know $namedContact!";
//      } else {
//        _contactText = "No contacts to display.";
//      }
//    });
  }

  // Method to return the first contact in list.
  /*
    String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    int _panjang = connections.length;

    //MANUAL DEBUGGER
    print("Panjangna ::: $_panjang");

//    for (int i = 0; i < 5; i++) {
//      //write(connections.get);
//      var nama = connections.removeLast();
//      String namaValue = nama.toString();
//      print("NAMANYA NIH $namaValue");
//    }
//    final Map<int, String> allContact = connections.asMap();
//    String value = allContact.toString();
//    print("ALL_CONTACT $value");

//    while(_panjang > 0) {
//      Map<String, dynamic> contact_2 = connections.removeLast();
//      if (contact_2 != null) {
//        final Map<String, dynamic> name_2 = contact_2['names'].firstWhere(
//              (dynamic name_2) => name_2['displayName'] != null,
//          orElse: () => null,
//        );
//        if (name_2 != null) {
//          return name_2['displayName'];
//        }
//      }
//    }

    final Map<String, dynamic> contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }
  */

  //Sign in handler
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
  // - navigate to homepage
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
            child: const Text('HOMEPAGE'),
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

  // PAGE DISPLAY -CONTAINER- :
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

//Encapsulation class to generate random words
class RandomWords extends StatefulWidget{
  @override
  createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords>{
  //Once, it was used as the dummy data for listView
  final _suggestions = <String>[];
  //Keep saved words
  final _saved = Set<String>();
  final _biggerFont = const TextStyle(fontSize:18.0);

  //All contact data is here
  static List<dynamic> defaultConnections;
  static List<dynamic> connections ;

  static void setData(Map<String, dynamic> data){
    connections = data['connections'];
    defaultConnections =  data['connections'];
  }

  void resetData(){
    connections = defaultConnections;
  }

  // It will keep all the contact in list to ListView.builder
  //TODO: Change the wordPairs into name from contact! : SUCCESS!
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {

          //string to keep value of contact name before returned.
          String nameValue = connections.toString();

          //print("ASUP KENEH KADIEU : $nameValue");
          Map<String, dynamic> contact;
          if(!connections.isEmpty) {
            contact = connections.removeLast();
          }
          if (contact != null) {
            final Map<String, dynamic> name = contact['names'].firstWhere(
                  (dynamic name) => name['displayName'] != null,
              orElse: () => null,
            );
            if (name != null) {
              nameValue = name['displayName'];
            }
          }

          return _buildRow(nameValue);
        }

    );
  }

  // The widget builder!
  @override
  Widget build(BuildContext context){
//    final wordPair = WordPair.random();
//    return Text(wordPair.asPascalCase);
    //var _stringCounter = int.parse(_counter.toString());
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

  // This method support the build method.
  // Create button to savedSuggestion Page
  void _pushSaved(){
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
  // This method is used to save the string into SavedSuggestions page.
  // TODO: in method _buildRow CHANGE THE pair PARAMETER to String !
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
      onTap: (){ //What to do when tapped
        setState(() {
          print("Kasimpen teu yeuh: $pair");
          if(alreadySaved){
            _saved.remove(pair);
          }else{
            _saved.add(pair);
            resetData();
          }
        });
      },
    );
  }
}

//*/