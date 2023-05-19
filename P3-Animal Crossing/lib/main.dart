import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Leaflet';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late Future<List<Fish>> futureFish;
  late Future<List<Bugs>> futureBugs;
  late Future<List<Villagers>> futureVillagers;

  @override
  void initState() {
    super.initState();
    futureFish = fetchFish();
    futureBugs = fetchBugs();
    futureVillagers = fetchVillagers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaflet',
      theme: ThemeData(
        primaryColor: const Color(0xffe5ad58),
        fontFamily: 'Cabin',
        scaffoldBackgroundColor: const Color(0xffffd89c),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Leaflet',
              style: TextStyle(
                  color: Color(0xff613b05), fontFamily: 'JosefinSans')),
          leading:
              const Icon(Icons.eco_rounded, size: 35, color: Color(0xff613b05)),
          backgroundColor: const Color(0xffe5ad58),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            FutureBuilder<List<Villagers>>(
              future: futureVillagers,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return VillagersList(villagers: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Stack(children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(top: 170),
                        child: Image(image: AssetImage('images/resetti.png'))),
                    Text('Page Error! \nStatus: ${snapshot.error}',
                        style: const TextStyle(
                            color: Color(0xff8F0101),
                            fontWeight: FontWeight.bold,
                            fontSize: 40))
                  ]));
                } else {
                  // By default, show a loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            FutureBuilder<List<Bugs>>(
              future: futureBugs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return BugsList(bugs: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Stack(children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(top: 170),
                        child: Image(image: AssetImage('images/resetti.png'))),
                    Text('Page Error! \nStatus: ${snapshot.error}',
                        style: const TextStyle(
                            color: Color(0xff8F0101),
                            fontWeight: FontWeight.bold,
                            fontSize: 40))
                  ]));
                } else {
                  // By default, show a loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            FutureBuilder<List<Fish>>(
              future: futureFish,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FishList(fish: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Stack(children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(top: 170),
                        child: Image(image: AssetImage('images/resetti.png'))),
                    Text('Page Error! \nStatus: ${snapshot.error}',
                        style: const TextStyle(
                            color: Color(0xff8F0101),
                            fontWeight: FontWeight.bold,
                            fontSize: 40))
                  ]));
                } else {
                  // By default, show a loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
        /* Bottom Navigtaion */
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.face_rounded),
              label: 'Villagers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_nature_rounded), //pest_control_rounded),
              label: 'Bugs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_rounded),
              label: 'Fish',
            ),
          ],
          unselectedIconTheme: const IconThemeData(
            //if not on current page, use different color
            color: Color(0xff80561c),
          ),
          currentIndex: _selectedIndex, //New
          onTap: _onItemTapped,
          selectedItemColor:
              const Color(0xff543100), //display using a dark color
          backgroundColor: const Color(0xffe5ad58),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

/* Fish Information */
Future<List<Fish>> fetchFish() async {
  final response = await http.get(Uri.parse('https://acnhapi.com/v1a/fish/'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return parseFish(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load fish data');
  }
}

List<Fish> parseFish(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final parsedList = parsed.map<Fish>((json) => Fish.fromJson(json)).toList();
  return parsedList;
}

class Fish {
  final String name;
  final String location;
  final String rarity;
  final String monthNorth;
  final String monthSouth;
  final String time;
  final String shadow;
  final int price;
  final String catchPhrase;
  final String iconImg;

  Fish({
    required this.name,
    required this.location,
    required this.rarity,
    required this.monthNorth,
    required this.monthSouth,
    required this.time,
    required this.shadow,
    required this.price,
    required this.catchPhrase,
    required this.iconImg,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      name: json['name']['name-USen'],
      location: json['availability']['location'],
      rarity: json['availability']['rarity'],
      monthNorth: json['availability']['month-northern'] != ""
          ? json['availability']['month-northern']
          : "Available All Year", //checking if string is empty, Available all year
      monthSouth: json['availability']['month-southern'] != ""
          ? json['availability']['month-southern']
          : "Available All Year", //checking if string is empty, Available all year
      time: json['availability']['time'] != ""
          ? json['availability']['time']
          : "Available All Day", //checking if string is empty, Available all day
      shadow: json['shadow'],
      price: json['price'],
      catchPhrase: json['catch-phrase'],
      iconImg: json['icon_uri'],
    );
  }
}

class FishList extends StatelessWidget {
  const FishList({Key? key, required this.fish}) : super(key: key);

  final List<Fish> fish;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fish.length,
      itemBuilder: (context, index) {
        return ListTile( //display image and name of fish
            leading: Image.network(fish[index].iconImg),
            title: Text(
              convertToTitleCase(fish[index].name)!,
            ),
            tileColor: const Color(0xffd4a256),
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsFishPage(fish[index])));
            });
      },
    );
  }
}

class DetailsFishPage extends StatelessWidget {
  final Fish user;

  // ignore: use_key_in_widget_constructors
  const DetailsFishPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Color(0xff613b05), //change color of back button
          ),
          backgroundColor: const Color(0xffe5ad58), //background color of app
          title: Text(
            convertToTitleCase(user.name)!,
            style: const TextStyle(
                color: Color(0xff613b05), fontFamily: 'JosefinSans'),
          ), // text color
          centerTitle: true,
        ),
        body: Center(
          child: Stack(children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 150),
            child: Image.network(user.iconImg)), // display the image)
            Padding(
                padding: const EdgeInsets.only(left: 10, top: 130),
                child: Text(
                  //display information from API
                  "\nLocation: " +
                      user.location +
                      "\nRarity: " +
                      user.rarity +
                      "\nMonth Northern: " +
                      user.monthNorth +
                      "\nMonth Southern: " +
                      user.monthSouth +
                      "\nTime: " +
                      user.time +
                      "\nShadow: " +
                      user.shadow +
                      "\nPrice: " +
                      (user.price).toString() +
                      "\nCatch Phrase: '" +
                      user.catchPhrase +
                      "'",
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    color: Color(0xff583400),
                  ),
                )),
          ]),
        ));
  }
}

/* Bugs Information */
Future<List<Bugs>> fetchBugs() async {
  final response = await http.get(Uri.parse('https://acnhapi.com/v1a/bugs/'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return parseBugs(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load bugs data');
  }
}

List<Bugs> parseBugs(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final parsedList = parsed.map<Bugs>((json) => Bugs.fromJson(json)).toList();
  return parsedList;
}

class Bugs {
  final String name;
  final String location;
  final String rarity;
  final String monthNorth;
  final String monthSouth;
  final String time;
  final int price;
  final String catchPhrase;
  final String iconImg;

  Bugs({
    required this.name,
    required this.location,
    required this.rarity,
    required this.monthNorth,
    required this.monthSouth,
    required this.time,
    required this.price,
    required this.catchPhrase,
    required this.iconImg,
  });

  factory Bugs.fromJson(Map<String, dynamic> json) {
    return Bugs(
      name: json['name']['name-USen'],
      location: json['availability']['location'],
      rarity: json['availability']['rarity'],
      monthNorth: json['availability']['month-northern'] != ""
          ? json['availability']['month-northern']
          : "Available All Year", //checking if string is empty, Available all year
      monthSouth: json['availability']['month-southern'] != ""
          ? json['availability']['month-southern']
          : "Available All Year", //checking if string is empty, Available all year
      time: json['availability']['time'] != ""
          ? json['availability']['time']
          : "Available All Day", //checking if string is empty, Available all day
      price: json['price'],
      catchPhrase: json['catch-phrase'],
      iconImg: json['icon_uri'],
    );
  }
}

class BugsList extends StatelessWidget {
  const BugsList({Key? key, required this.bugs}) : super(key: key);

  final List<Bugs> bugs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bugs.length,
      itemBuilder: (context, index) {
        return ListTile( //display image and name of bug
            leading: Image.network(bugs[index].iconImg),
            title: Text(
              convertToTitleCase(bugs[index].name)!,
            ),
            tileColor: const Color(0xffd4a256),
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsBugPage(bugs[index])));
            });
      },
    );
  }
}

class DetailsBugPage extends StatelessWidget {
  final Bugs user;

  // ignore: use_key_in_widget_constructors
  const DetailsBugPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Color(0xff613b05), //change color of back button
          ),
          backgroundColor: const Color(0xffe5ad58), //background color of app
          title: Text(
            convertToTitleCase(user.name)!,
            style: const TextStyle(
                color: Color(0xff613b05), fontFamily: 'JosefinSans'),
          ), // text color
          centerTitle: true,
        ),
        body: Center(
          child: Stack(children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 150),
            child: Image.network(user.iconImg)), // display the image)
            Padding(
                padding: const EdgeInsets.only(left: 10, top: 130),
                child: Text(
                  //display information from API
                  "\nLocation: " +
                      user.location +
                      "\nRarity: " +
                      user.rarity +
                      "\nMonth Northern: " +
                      user.monthNorth +
                      "\nMonth Southern: " +
                      user.monthSouth +
                      "\nTime: " +
                      user.time +
                      "\nPrice: " +
                      (user.price).toString() +
                      "\nCatch Phrase: '" +
                      user.catchPhrase +
                      "'",
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    color: Color(0xff583400),
                  ),
                )),
          ]),
        ));
  }
}

/* Villagers information */
Future<List<Villagers>> fetchVillagers() async {
  final response =
      await http.get(Uri.parse('https://acnhapi.com/v1a/villagers/'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return parseVillagers(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load villagers data');
  }
}

List<Villagers> parseVillagers(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final parsedList =
      parsed.map<Villagers>((json) => Villagers.fromJson(json)).toList();
  return parsedList;
}

class Villagers {
  final String name;
  final String species;
  final String personality;
  final String birthday;
  final String hobby;
  final String saying;
  final String img;

  Villagers({
    required this.name,
    required this.species,
    required this.personality,
    required this.birthday,
    required this.hobby,
    required this.saying,
    required this.img,
  });

  factory Villagers.fromJson(Map<String, dynamic> json) {
    return Villagers(
      name: json['name']['name-USen'],
      species: json['species'],
      personality: json['personality'],
      birthday: json['birthday-string'],
      hobby: json['hobby'],
      saying: json['saying'],
      img: json['image_uri'],
    );
  }
}

class VillagersList extends StatelessWidget {
  const VillagersList({Key? key, required this.villagers}) : super(key: key);

  final List<Villagers> villagers;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: villagers.length,
      itemBuilder: (context, index) {
        return ListTile( //display image and name of villager
            leading: Image.network(villagers[index].img),
            title: Text(
              convertToTitleCase(villagers[index].name)!,
            ),
            tileColor: const Color(0xffd4a256),
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DetailsVillagersPage(villagers[index])));
            });
      },
    );
  }
}

class DetailsVillagersPage extends StatelessWidget {
  final Villagers user;

  // ignore: use_key_in_widget_constructors
  const DetailsVillagersPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Color(0xff613b05), //change color of back button
          ),
          backgroundColor: const Color(0xffe5ad58), //background color of app
          title: Text(
            convertToTitleCase(user.name)!,
            style: const TextStyle(
                color: Color(0xff613b05), fontFamily: 'JosefinSans'),
          ), // text color
          centerTitle: true,
        ),
        body: Center(
          child: Stack(children: <Widget>[
            Image.network(user.img, scale: 1.5), // display the image
            Padding(
                padding: const EdgeInsets.only(left: 10, top: 170),
                child: Text(
                  //display information from API
                  "\nSpecies: " +
                      user.species +
                      "\nPersonality: " +
                      user.personality +
                      "\nBirthday: " +
                      user.birthday +
                      "\nHobby: " +
                      user.hobby +
                      "\nSaying: '" +
                      user.saying +
                      "'",
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    color: Color(0xff583400),
                  ),
                )),
          ]),
        ));
  }
}

// Used for names fro API data, to make the name capatlized (since string creates name as lowercase)
// Taken from: https://coflutter.com/dart-flutter-how-to-capitalize-first-letter-of-each-word-in-a-string/
String? convertToTitleCase(String text) {
  if (text.length <= 1) {
    return text.toUpperCase();
  }

  // Split string into multiple words
  final List<String> words = text.split(' ');

  // Capitalize first letter of each words
  final capitalizedWords = words.map((word) {
    if (word.trim().isNotEmpty) {
      final String firstLetter = word.trim().substring(0, 1).toUpperCase();
      final String remainingLetters = word.trim().substring(1);

      return '$firstLetter$remainingLetters';
    }
    return '';
  });

  // Join/Merge all words back to one String
  return capitalizedWords.join(' ');
}
