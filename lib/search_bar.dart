import 'data/bloc_provider.dart';
import 'data/search_bloc.dart';
import 'models/SearchResponse.dart';
import 'word_list.dart';
import 'package:flutter/material.dart';

class SearchAppBarRecipe extends StatefulWidget {
  SearchAppBarRecipe({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchAppBarRecipeState createState() => _SearchAppBarRecipeState();
}

class _SearchAppBarRecipeState extends State<SearchAppBarRecipe> {
  ResultBloc _resultBloc = new ResultBloc();

  WordList kWords = new WordList();

  _SearchAppBarDelegate _searchDelegate;

  @override
  void initState() {
    super.initState();

    _searchDelegate = _SearchAppBarDelegate(kWords.suggestions);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        color: Colors.white,
        shadowColor: Colors.amber[500],
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 52.0,
                width: 450.0,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  hoverElevation: 10,
                  hoverColor: Colors.white,
                  elevation: 10,
                  tooltip: 'Search',
                  label: Text(
                    'འཚོལ/Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(
                    Icons.search,
                    size: 38,
                    color: Colors.white,
                  ),
                  //Don't block the main thread
                  onPressed: () {
                    showSearchPage(context, _searchDelegate);
                  },
                ),
              )),
        ]));
  }

  //Shows Search result
  void showSearchPage(
      BuildContext context, _SearchAppBarDelegate searchDelegate) async {
    final String selected = await showSearch<String>(
      context: context,
      delegate: searchDelegate,
    );

    if (selected != null) {
      _resultBloc.getNotes(context);
    }
  }
}

//Search delegate
class _SearchAppBarDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      fontFamily: 'jomolhari',
      primaryColor: Colors.orangeAccent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        bodyText2: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  final List<String> _words;
  final List<String> _history;

  ResultBloc _resultBloc = new ResultBloc();
  TextEditingController controller;

  _SearchAppBarDelegate(List<String> words)
      : _words = words,
        //pre-populated history of words
        _history = <String>[],
        super();

  // Setting leading icon for the search bar.
  //Clicking on back arrow will take control to main page
  @override
  TextInputAction textInputAction = TextInputAction.search;

  String get searchFieldLabel => 'འཚོལ/Search';

  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        //Take control back to previous page
        this.close(context, null);
      },
    );
  }

  Widget resultTemplate(searchmatch) {
    return Card(
        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    searchmatch.toJson()['entry'] +
                        searchmatch.toJson()['keyword'],
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    "   " + searchmatch.toJson()['pos'],
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.0),
              Text(
                searchmatch.toJson()['definition'],
                style: TextStyle(
                    fontSize: 18.0,
                    height: 1.8,
                    letterSpacing: 0.4,
                    wordSpacing: 4),
              ),
            ],
          ),
        ));
  }

  // Builds page to populate search results.
  @override
  Widget buildResults(BuildContext context) {
    return BlocProvider<ResultBloc>(
      bloc: ResultBloc(),
      child: Card(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        shadowColor: Colors.amber[500],
        child: Column(
          children: [
            Flexible(
              child: BlocProvider<ResultBloc>(
                bloc: ResultBloc(),
                child: Scaffold(
                  body: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: StreamBuilder<List<DzoSearchResponse>>(
                              stream: _resultBloc.resultStream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<DzoSearchResponse>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No search result',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            letterSpacing: 1.5,
                                            color: Colors.grey),
                                      ),
                                    );
                                  }
                                  List<DzoSearchResponse> searchmatches =
                                      snapshot.data;

                                  return ListView.builder(
                                    itemCount: 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListBody(
                                        children: searchmatches
                                            .map((searchmatch) =>
                                                resultTemplate(searchmatch))
                                            .toList(),
                                      );
                                    },
                                  );
                                }
                                return Center(
                                  child: Text(
                                    'Enter a search word',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        letterSpacing: 1.5,
                                        color: Colors.grey),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Suggestions list while typing search query - this.query.
  @override
  Widget buildSuggestions(BuildContext context) {
    final Iterable<String> suggestions = this.query.isEmpty
        ? _history
        : _words.where((word) => word.startsWith(query));

    return _WordSuggestionList(
      query: this.query,
      suggestions: suggestions.toList(),
      onSelected: (String suggestion) {
        this.query = suggestion;
        this._history.insert(0, suggestion);
        showResults(context);
        _resultBloc.getNotes(suggestion);
      },
    );
  }

  // Action buttons at the right of search bar.
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }
}

// Suggestions list widget displayed in the search page.
class _WordSuggestionList extends StatelessWidget {
  const _WordSuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final textTheme = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? Icon(Icons.history) : Icon(null),
          // Highlight the substring that matched the query.
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: textTheme.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: textTheme,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
