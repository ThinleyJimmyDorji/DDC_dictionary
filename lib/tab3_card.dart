import 'package:flutter/material.dart';

class Tab3Card extends StatelessWidget {
  final string1 =
      'འགྲུལ་འཕྲིན་རིམ་ལུགས་འདི་ནང་  རྫོང་ཁ་གོང་འཕེལ་ལྷན་ཚོགས་ཀྱི་རྫོང་ཁའི་ཚིག་མཛོད།\n'
      'རྫོང་ཁ་ཨིང་སྐད་དང་ཨིང་སྐད་རྫོང་ཁ་ཚུ་ཡོདཔ་ཨིན།\n'
      '© རྫོང་ཁ་གོང་འཕེལ་ལྷན་ཚོགས། ༢༠༢༠\n'
      '༩༧༥-༠༢༣༢༢༦༦༣\n'
      'www.dzongkha.gov.bt\n'
      'ddc@dzongkha.gov.bt';

  final string2 = 'གཞུང་ལས་མི་སེར་ཞབས་ཏོག་ཡིག་ཚང།\n'
      'ལྷན་རྒྱས་གཞུང་ཚོགས།\n'
      'འབྲུག  ཐིམ་ཕུག  ཆུ་བར་ཆུ།\n'
      '༩༧༥-༠༢༣༣༩༦༥༥\n'
      'www.citizenservices.gov.bt\n'
      'g2c@cabinet.gov.bt';

  final string4 = 'ཚན་རིག་དང་འཕྲུལ་རིག་མཐོ་རིམ་སློབ་གྲྭ།\n'
      'མི་ངོམ།  ༡༽ དོན་གྲུབ་ཆོས་འཕེལ།\n'
      '        ༢༽ ཀུན་བཟང་ཆོས་སྒྲོན།\n'
      '        ༣༽ འཕྲིན་ལས་རྡོ་རྗེ།\n'
      'www.cst.edu.bt\n'
      'itd.cst@rub.edu.bt';
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      color: Colors.white,
      shadowColor: Colors.amber[500],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            AppBar(
              toolbarHeight: 45,
              title: Text(
                'རིམ་ལུགས་ཀྱི་སྐོར།',
                style: TextStyle(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.orange[400],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Image(
                    image: AssetImage('assets/ddc.jpg'),
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Flexible(
                    child: new Text(string1,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          wordSpacing: 4,
                        )),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            AppBar(
              toolbarHeight: 45,
              title: Text(
                'མི་མང་གི་དོན་ལུ་རིམ་ལུགས་བཟོ་མི།',
                style: TextStyle(
                  letterSpacing: 0.5,
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.orange[400],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Image(
                    image: AssetImage('assets/ddc.jpg'),
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Flexible(
                    child: new Text(string2,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          wordSpacing: 4,
                        )),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 20,
            ),
            AppBar(
              toolbarHeight: 45,
              title: Text(
                'ཐོན་རིམ་གཉིས་པ་བཟོ་མི།',
                style: TextStyle(
                  letterSpacing: 0.5,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.orange[400],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Image(
                    image: AssetImage('assets/cst.png'),
                    height: 85,
                    width: 85,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Flexible(
                    child: new Text(string4,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.8,
                        )),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
