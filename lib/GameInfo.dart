import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class GameInfo extends StatefulWidget {
  String game_link, game_name, game_poster;

  GameInfo({Key key, this.game_link, this.game_name, this.game_poster})
      : super(key: key);

  @override
  _GameInfoState createState() => _GameInfoState();
}

class _GameInfoState extends State<GameInfo> {
  var gameAttributes, links, rawDescription;
  Map gameInformation = {
    "descP1": "",
    "descP2": "",
    "language": "",
    "release": "",
    "genre": "",
    "systemRequirementsMin": "",
    "systemRequirementsMax": ""
  };

  Future getGameInfo() async {
    String url = widget.game_link;
    var response = await http.get(url);
    dom.Document document = parser.parse(response.body);
    this.gameAttributes =
        document.getElementsByTagName("tbody")[0].getElementsByTagName("span");
    this.links = document.getElementsByTagName("tbody")[1];
    // 3 se language 5 se release 7 se genre
    rawDescription = document.getElementsByTagName("p");

    debugPrint("7"+rawDescription[7].innerHtml);
    debugPrint("8"+rawDescription[8].innerHtml);

    if (rawDescription[6].innerHtml.contains("Minimum:")) {
      gameInformation["systemRequirementsMin"] =
          rawDescription[6].innerHtml.replaceAll('<br>', '');
      // debugPrint(rawDescription[6].innerHtml.replaceAll('<br>', ''));
      print("in if");
    } else {
      gameInformation["descP2"] = rawDescription[6].innerHtml;
    }
    gameInformation["descP1"] = rawDescription[5].innerHtml;
    gameInformation["genre"] = gameAttributes[7].innerHtml;
    gameInformation["release"] = gameAttributes[5].innerHtml;
    gameInformation["language"] = gameAttributes[3].innerHtml;
    setState(() {});
    // print(gameAttributes);
  }

  @override
  void initState() {
    getGameInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.game_name),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.game_poster))),
              Container(
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.blue),
                child: Text(
                  widget.game_name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.white),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.blue),
                    child: Text(
                      gameInformation["genre"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.blue),
                    child: Text(
                      gameInformation["release"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.blue),
                    child: Text(
                      gameInformation["language"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.blue),
                child: Text(
                  "Description",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.blue),
                child: Text(
                  gameInformation["descP1"] + gameInformation["descP2"],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
