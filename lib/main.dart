import 'tab1_card.dart';
import 'search_bar.dart';
import 'tab3_card.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (_) {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus != null) {
            currentFocus.focusedChild.unfocus();
          }
        },
        child: MaterialApp(
          title: 'Dzongkha Dictionary App',
          theme: ThemeData(
            fontFamily: 'jomolhari',
            primarySwatch: Colors.orange,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.orange,
          title: Text(
            'རྫོང་ཁའི་ཚིག་མཛོད།',
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.orange,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Colors.white,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              color: Colors.white,
            ),
            tabs: <Widget>[
              Tab(
                child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.cloud_circle,
                      size: 30,
                    )),
              ),
              Tab(
                child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.collections_bookmark,
                      size: 30,
                    )),
              ),
              Tab(
                child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.info,
                      size: 30,
                    )),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            (Tab1Card()),
            (SearchAppBarRecipe()),
            (Tab3Card()),
          ],
        ),
      ),
    );
  }
}
