import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

//shuffle
class Deck {
  final bool success;
  final String deckId;
  final bool shuffled;
  final int remaining;

  Deck({this.success, this.deckId, this.shuffled, this.remaining});

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      success: json['success'],
      deckId: json['deck_id'],
      shuffled: json['shuffled'],
      remaining: json['remaining'],
    );
  }
}

class Cards {
  final bool success;
  final String deckId;
  final int remaining;
  final List<dynamic> cardtype;

  Cards({this.success, this.deckId, this.remaining, this.cardtype});

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
        success: json['success'],
        deckId: json['deck_id'],
        remaining: json['remaining'],
        cardtype: json['cards']);
  }
}

//funcion
Future<Deck> fetchDeck() async {
  final response = await http
      .get('https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1');

  if (response.statusCode == 200) {
    return Deck.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load deck');
  }
}

Future<Cards> fetchCards(Future<String> deckId) async {
  final response = await http.get('https://deckofcardsapi.com/api/deck/' +
      deckId.toString() +
      '/draw/?count=2');

  if (response.statusCode == 200) {
    return Cards.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load Cards');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//fetch the data
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Future<Deck> futureDeck;
  Future<Cards> futureCards;

  @override
  void initState() {
    super.initState();
    futureDeck = fetchDeck();
  }

  void _incrementCounter() {
    setState(() {
      futureCards = fetchCards(futureDeck.then((value) => value.deckId));
      _counter++;
    });
  }

  // Widget DeckToImage(String Deck) {
  //   switch (Deck) {
  //     case "clear":
  //       return Image.asset(
  //         "images/clear.png",
  //         width: 50,
  //         height: 50,
  //       );
  //     case "oshower":
  //       return Image.asset(
  //         "images/rain.png",
  //         width: 50,
  //         height: 50,
  //       );
  //     default:
  //       return Text("Desconocido");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder<Cards>(
        future: futureCards,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data.cardtype[0]['code']);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
