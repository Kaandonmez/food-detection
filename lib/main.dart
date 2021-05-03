import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Food Recognition",
            style: TextStyle(
              fontSize: 19,
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade800,
      ),
      body: _loading
          ? Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundImage: NetworkImage(
                  //       "https://kaandonmez.com.tr/resimler_food_app/balik.jpg"),
                  // ),
                  _image == null
                      ? MyAlert()
                      : Container(
                          height: 150.0,
                          width: 150.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(75.0),
                            child: (_image != null)
                                ? new Image.file(
                                    _image,
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  _outputs != null
                      ? Column(
                          children: [
                            Text(
                              "${_outputs[0]["label"]}",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              "Confidance = ${_outputs[0]["confidence"]}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            )
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        backgroundColor: Colors.amber.shade700,
        child: Icon(Icons.fastfood_rounded),
      ),
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.40,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
      double dogruluk = _outputs[0]["confidence"];
      print("${_outputs[0]["confidence"]}");
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}

class MyAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            // IconButton(
            //   child: Text('Show alert',style: TextStyle(backgroundColor: Colors.grey.shade500),),
            //   onPressed: () {
            //     showAlertDialog(context);
            //   },
            // ),
            //
            RaisedButton(
          color: Colors.redAccent,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  "Press if you don't know what to do",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            showAlertDialog(context);
          },
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // Create button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Info"),
    content: Column(
      //mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("This app can only detect following things: "),
        Text("fries,pasta,meatballs,fish,salad,coke."),
        SizedBox(height: 10),
        Text("More food types will be add."),
        Divider(
          height: 30,
          color: Colors.redAccent,
          thickness: 3,
        ),
        Text("1- Press the following icon :              "),
        Icon(Icons.fastfood_rounded),
        Text("2- Choose only supported/teached food picture. "),
        Text("3- Make sure your food image extension is supported."),
        Text("3.1- JPG/PNG is supported , file size is max 10 MB."),
        Text("4- Confidance max value is : 1              "),
        Text(
            "4.1- The closer the value is to one, the more accurate the result."),
        Text("5- The picture should be in sufficient      "),
        Text("conditions of light.                                "),
        Text("6- Make sure the food image is clearly visible.")
      ],
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
