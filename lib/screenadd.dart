import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todoapi/screenhome.dart';

class ScreenAdd extends StatefulWidget {
  ScreenAdd({Key? key, this.todo}) : super(key: key);
  final todo;

  @override
  State<ScreenAdd> createState() => _ScreenAddState();
}

class _ScreenAddState extends State<ScreenAdd> {
  TextEditingController titlecontroller = TextEditingController();

  TextEditingController descriptioncontroller = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo["title"];
      final descrip = todo["description"];
      titlecontroller.text = title;
      descriptioncontroller.text = descrip;
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
        255,
        122,
        158,
        159,
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 184, 216, 216),
        title: Text(
          isEdit ? "Edit Data" : "Add Data",
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            TextField(
              controller: titlecontroller,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 20,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 12, 117, 121),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 184, 216, 216),
                  labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                  labelText: "Title",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 12, 117, 121),
                    ),
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: descriptioncontroller,
              maxLines: 8,
              minLines: 5,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 12, 117, 121))),
                filled: true,
                fillColor: const Color.fromARGB(255, 184, 216, 216),
                labelText: "Description....",
                labelStyle: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 12, 117, 121))),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: MaterialButton(
                onPressed: () {
                  isEdit ? update() : SubmitData();
                },
                child: Text(
                  isEdit ? "Update" : "Submit",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  update() async {
    final todo = widget.todo;
    final id = todo["_id"];
    final title = titlecontroller.text;
    final description = descriptioncontroller.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final url = "http://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);

    try {
      final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenHome(),
            ));
        showSucess(context, "Sucessfully Updated", Colors.green);
      } else {
        showSucess(context, "Updation Failed", Color.fromARGB(255, 154, 0, 0));
      }
    } catch (e) {
      showSucess(context, "Updation Failed $e", Color.fromARGB(255, 123, 2, 2));
    }
  }

  void SubmitData() async {
    // taking text from textfiled
    final title = titlecontroller.text;
    final description = descriptioncontroller.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    //submit data
    final url = "http://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201) {
      try {
        titlecontroller.text = "";
        descriptioncontroller.text = "";
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenHome(),
            ));
        showSucess(
            context, "Sucessfully Created", Color.fromARGB(255, 254, 95, 85));
      } catch (e) {
        showSucess(context, "Creation Failed $e", Colors.red);
      }
    } else {
      showSucess(context, "Creation Failed", Colors.red);
    }
  }
}

void showSucess(context, String text, Color col) {
  final snackbar = SnackBar(
      duration: Duration(seconds: 3),
      backgroundColor: col,
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      ));

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
