import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MovieInfo extends StatefulWidget {
  final moviesId; //Imbd id from the home page
  int loaded; // becomes true if the data is fetch complete either from OMBD or YTS

  MovieInfo({Key key, this.moviesId}) : super(key: key);

  @override
  _MovieInfoState createState() => _MovieInfoState();
}

class _MovieInfoState extends State<MovieInfo> {
  Map rawMovieDataFromOmdb; //data from OMDB api will be stored
  Map rawMovieDataFromYts; //data from YTS api will be stored
  Map movieTitle = Map(); //raw data will be sorted and arranged into this Map
  List
      torrents; // data about torrents like links to download it would be stored in it
  bool
      torrentMode; // becomes true if the user has VPN enables and can fetch data from YTS

  Future getData() async {
    print(widget.moviesId);

    //data from Yts API
    var urlYts = "https://yts.mx/api/v2/list_movies.json?query_term=" +
        widget.moviesId.toString();
    try {
      var responseYts = await http.get(urlYts);
      if (responseYts != null) {
        rawMovieDataFromYts = json.decode(responseYts.body);
        setState(() {
          movieTitle["Title"] =
              rawMovieDataFromYts["data"]["movies"][0]["title"];
          movieTitle["Poster"] =
              rawMovieDataFromYts["data"]["movies"][0]["large_cover_image"];
          movieTitle["Released"] =
              rawMovieDataFromYts["data"]["movies"][0]["year"];
          movieTitle["Genre"] =
              rawMovieDataFromYts["data"]["movies"][0]["genres"];
          // movieTitle["Actors"] = rawMovieDataFromYts["data"]["movies"][0];
          movieTitle["imdbRating"] =
              rawMovieDataFromYts["data"]["movies"][0]["rating"];
          movieTitle["Plot"] =
              rawMovieDataFromYts["data"]["movies"][0]["summary"];
          torrentMode = true;
          torrents = rawMovieDataFromYts["data"]["movies"][0]["torrents"];
          print(torrents);
        });
      }
    }

    //data from OMBD API
    catch (error) {
      torrentMode = false;
      print("into catch");
      var urlOmdb = "http://www.omdbapi.com/?apikey=c0ff6979&i=" +
          widget.moviesId.toString();
      var responseOmdb = await http.get(urlOmdb);
      rawMovieDataFromOmdb = json.decode(responseOmdb.body);
      setState(() {
        movieTitle["Title"] = rawMovieDataFromOmdb["Title"];
        movieTitle["Poster"] = rawMovieDataFromOmdb["Poster"];
        movieTitle["Released"] = rawMovieDataFromOmdb["Released"];
        movieTitle["Genre"] = rawMovieDataFromOmdb["Genre"];
        movieTitle["Actors"] = rawMovieDataFromOmdb["Actors"];
        movieTitle["imdbRating"] = rawMovieDataFromOmdb["imdbRating"];
        movieTitle["Plot"] = rawMovieDataFromOmdb["Plot"];
      });
    }

    widget.loaded = 1;
  }

// to launch a url in browser on android
  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return widget.loaded == 1
        ? Scaffold(
            // body: SafeArea(
            //   child: SingleChildScrollView(
            //       child: Text(movieTitle["Released"].toString())),
            // ),
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
                            // loadingBuilder: (context, child, loadingProgress) => CircularProgressIndicator(backgroundColor: Colors.white,),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            width: 600,
                            height: 350,
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              movieTitle["Poster"],
                            ))),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.blue),
                      child: Text(
                        movieTitle["Title"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.blue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Released: " + movieTitle["Released"].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Genre: " + movieTitle["Genre"].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          // Center(child: Text("Actors: " + movieTitle["Actors"])),
                          Text(
                            "IMBD Rating " +
                                movieTitle["imdbRating"].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.blue),
                      child: Text(
                        movieTitle["Plot"],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    torrentMode
                        ? SizedBox(
                            height: 425,
                            child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: torrents.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 10,
                                margin: EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        print(torrents[index]["url"]);
                                        _launchURL(
                                            torrents[index]["url"].toString());
                                      },
                                      child: Image.network(
                                          rawMovieDataFromYts["data"]["movies"]
                                              [0]["medium_cover_image"]),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(5.0),
                                          margin: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.blue),
                                          child: Column(
                                            children: [
                                              Center(
                                                  child: Text(
                                                "Quality: " +
                                                    torrents[index]["quality"],
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                              Center(
                                                  child: Text(
                                                "Type: " +
                                                    torrents[index]["type"],
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                              Center(
                                                  child: Text(
                                                "Size: " +
                                                    torrents[index]["size"],
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 6.0),
                                        Container(
                                          padding: EdgeInsets.all(5.0),
                                          margin: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.blue),
                                          child: Column(
                                            children: [
                                              Center(
                                                  child: Text(
                                                "Seeds: " +
                                                    torrents[index]["seeds"]
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                              Center(
                                                  child: Text(
                                                "Peers: " +
                                                    torrents[index]["peers"]
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        : Column(
                            children: [
                              Text(
                                "Turn On VPN to show up torrents!!!",
                                style: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: Colors.red),
                              ),
                              RaisedButton.icon(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    getData();
                                  });
                                },
                                icon: Icon(
                                  Icons.refresh_sharp,
                                  color: Colors.blue,
                                ),
                                label: Text("Refresh",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    )),
                              )
                            ],
                          )
                  ],
                ),
              ),
            ),
          )

        //if MoviesInfo isn't loaded
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
