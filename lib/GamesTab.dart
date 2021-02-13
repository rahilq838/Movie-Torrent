import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:movie_test/GameInfo.dart';

class GamesTab extends StatefulWidget {
 bool loaded=false;
  @override
  _GamesTabState createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  String gameName = 'Hitman';
  TextEditingController _editingController = TextEditingController();
  String url;
  List posterData;
  List listOfGames;
  List gameLinks;

  Future getDataFromGamePcIso() async {
    url = "https://gamepciso.com/?s=" + gameName;
    var response = await http.get(url);
    dom.Document document = parser.parse(response.body);
    //for getting list of titles and links of the games
    List rawListOfGames =
        document.getElementsByClassName("post-title entry-title");
    //for getting posters of that games
    List rawPosterData =
        document.getElementsByClassName("post-body entry-content");

    //filtering out required data from raw
    this.posterData = rawPosterData
        .map(
            (poster) => poster.getElementsByTagName('img')[0].attributes["src"])
        .toList();

    this.listOfGames = rawListOfGames
        .map((name) => name.getElementsByTagName("a")[0].innerHtml)
        .toList();

    this.gameLinks = rawListOfGames
        .map((name) => name.getElementsByTagName("a")[0].attributes["href"])
        .toList();
    setState(() {
      widget.loaded=true;
    });
  }

  @override
  void initState() {
    super.initState();
    getDataFromGamePcIso();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              cursorHeight: 25,
              controller: _editingController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "PC Games",
              ),
            ),
          ),
          RaisedButton.icon(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              setState(() {
                widget.loaded=false;
                gameName=_editingController.text;
              });
              getDataFromGamePcIso();
            },
            label: Text(
              'Search',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            icon: Icon(
              Icons.search,
              color: Colors.blue,
            ),
          ),
          SizedBox(
              height: 555.0,
              child: widget.loaded == false
                  ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              )
                  : ListView.builder(
                  itemCount:
                  listOfGames == null ? 0 : listOfGames.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameInfo(
                                  game_link: gameLinks[index],
                                  game_name: listOfGames[index],
                                  game_poster: posterData[index]
                                )));
                      },
                      child: Container(
                        height: 100,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10.0),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 5.0,
                              ),
                              CircleAvatar(
                                maxRadius: 40.0,
                                backgroundImage: NetworkImage(
                                    posterData[index]),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  SizedBox(
                                    width: 300.0,
                                    child: Text(
                                        listOfGames[index],
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 15.0,
                                        )),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
        ],
      ),
    );
  }
}
