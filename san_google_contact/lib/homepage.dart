import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

//
 // The project guide :
 // https://flutter.io/get-started/codelab/
 // 25/07/2018
//

void main() => runApp(HomePage());

class HomePage extends StatelessWidget {

  //Old Version
//  @override
//  Widget build(BuildContext context) {
//    //final wordPair = WordPair.random();
//    return MaterialApp(
//      title: 'Welcome to Flutter',
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text('Welcome to Flutter'),
//        ),
//        body: Center(
//          //child: Text('Hello World'),
//          //child: Text(wordPair.asPascalCase),
//          child: RandomWords(),
//        ),
//      ),
//    );
//  }

  //Latest Code
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Startup Name Generator v1',
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
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize:18.0);
  //var _counter = 0;

//  Old variable
//  final _suggestions = <WordPair>[];
//  final _biggerFont = const TextStyle(fontSize: 18.0);

  //
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),

        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
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
                  pair.asPascalCase,
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
  Widget _buildRow(WordPair pair){
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: (){
        setState(() {
          if(alreadySaved){
            _saved.remove(pair);
          }else{
            _saved.add(pair);
          }
        });
      },
    );
  }
}