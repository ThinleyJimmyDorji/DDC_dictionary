import 'package:flutter/material.dart';

class Tab1Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      color: Colors.white,
      shadowColor: Colors.amber[500],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          AppBar(
            toolbarHeight: 45,
            title: Text(
              'སློབ་སྟོན།',
              style: TextStyle(
                letterSpacing: 1,
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.orange[400],
            centerTitle: true,
          ),
          SizedBox(
            height: 20,
          ),
          RichText(
            text: new TextSpan(
              children: [
                new TextSpan(
                  text:
                      'རྫོང་ཁའི་ཡི་གུ་མཛུབ་གནོན་རྐྱབ་ནིའི་དོན་ལུ་ རྫོང་ཁ་ཡོད་པའི་ལྡེ་སྒྲོམ་བཙུགས་གནང།',
                  style: new TextStyle(
                    fontFamily: 'jomolhari',
                    color: Colors.black,
                    fontSize: 18,
                    letterSpacing: 1.5,
                    wordSpacing: 8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RichText(
            text: new TextSpan(
              children: [
                new TextSpan(
                  text:
                      'To be able to type in Dzongkha, install compatible Dzongkha supported keyboard. ',
                  style: new TextStyle(
                      fontFamily: 'jomolhari',
                      color: Colors.black,
                      fontSize: 14,
                      wordSpacing: 2,
                      letterSpacing: 0.8,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
