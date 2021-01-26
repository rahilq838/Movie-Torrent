import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'MovieInfo.dart';
void main() {
  runApp(MaterialApp(
    home:HomePage() ,

  ));
}

class HomePage extends StatefulWidget {
  bool loaded=false;//becomes true if the data is fetch is complete from OMBD
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  String movieName='avengers'; // this will acquire what user searches in TextFormField
  Map rawMovieData; //raw movie data from OMBD
  List moviesInfo; //Local List to sort raw OMBD data
  int pageNo=1; //page numbers that is retured from OMBD increases if the user kept scrolling at the bottom
  ScrollController _scrollController = ScrollController(); // for the listview.builder to check if the user has reached at the bottom of the list to load more
  TextEditingController _editingController = TextEditingController(); // to get text from the textformfield
// get data from OMDB for homepage
  Future getData() async {
    var url = "http://www.omdbapi.com/?apikey=YOUR_OMBD_API_KEY&s="+movieName+"&page="+pageNo.toString();
    var response = await http.get(url);
    rawMovieData = json.decode(response.body);
    setState((){
      if(pageNo!=1){
        moviesInfo.addAll(rawMovieData["Search"]);
      }
      else{
        moviesInfo=rawMovieData["Search"];
      }

    });
    widget.loaded=true;
  }
  // adding more to the listView if the user scrolls at the bottom of the list
  Future getMoreData()async{
    setState((){
      pageNo=pageNo+1;
    });
    print(pageNo);
    getData();
  }

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
        getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var loaded;
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for Movie or Series'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 295.0,
                    child: TextFormField(
                      controller: _editingController,
                      decoration: InputDecoration(
                      ),
                    ),
                  ),
                  RaisedButton.icon(
                    onPressed: (){
                      setState(() {
                        pageNo=1;
                        movieName=_editingController.text;
                        widget.loaded=false;
                      });
                      getData();
                      print(pageNo);
                      print(_editingController.text);

                    },
                    label: Text('Search'),
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 555.0,
              child: widget.loaded==false?Center(child: CircularProgressIndicator(backgroundColor: Colors.blue,),):ListView.builder(
                controller: _scrollController,
                  itemCount: moviesInfo==null?0: moviesInfo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context)=> MovieInfo(
                                  moviesId: moviesInfo[index]['imdbID'] ,
                                )
                            )
                        );
                      },
                      child: Container(
                        height: 100,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              SizedBox(width: 5.0,),
                              CircleAvatar(
                                maxRadius: 40.0,
                                backgroundImage: NetworkImage(moviesInfo[index]['Poster']),
                              ),
                              SizedBox(width: 5.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5.0,),
                                  SizedBox(
                                    width: 300.0,
                                    child: Text(
                                        moviesInfo[index]["Title"],
                                        overflow: TextOverflow.ellipsis,
                                        style:TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: 5.0,),
                                  SizedBox(
                                    width: 300.0,
                                    child: Text(
                                        "*"+moviesInfo[index]["Type"],
                                        overflow: TextOverflow.ellipsis,
                                        style:TextStyle(
                                          fontSize: 9.0,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: 5.0,),
                                  SizedBox(
                                    width: 300.0,
                                    child: Text(
                                        "*"+moviesInfo[index]["Year"],
                                        overflow: TextOverflow.ellipsis,
                                        style:TextStyle(
                                          fontSize: 9.0,
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              )
            ),
          ],
        ),
      ),
    );
  }
}
