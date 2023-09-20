import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:todoapi/screenadd.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  bool isloading = true;
  List items = [];

  @override
  void initState() {
    fetch();
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () {
          NavigateAdd();
        },
        label: Text(
          "Add TODO",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 184, 216, 216),
        title: Text(
          'Todo List',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: Visibility(
        visible: isloading,
        child: Center(
          child: Container(
            height: 250,
            width: 250,
            child: Lottie.asset("lib/Lottie/Animation - 1693891960728.json"),
          ),
        ),
        replacement: items.isEmpty // Check if the items list is empty
            ? Center(
                child: Text(
                  'No data available. Add data.',
                  style: TextStyle(fontSize: 15),
                ),
              )
            : RefreshIndicator(
                onRefresh: fetch,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item["_id"] as String;
                    return Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 184, 216, 216),
                          borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color.fromARGB(
                            255,
                            122,
                            158,
                            159,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          item["title"],
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 134, 138),
                          ),
                        ),
                        subtitle: Text(
                          item['description'],
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 44, 45),
                          ),
                        ),
                        trailing: PopupMenuButton(
                          color: Color.fromARGB(
                            255,
                            122,
                            158,
                            159,
                          ),
                          onSelected: (value) {
                            if (value == "delete") {
                              deleteItem(id);
                            } else {
                              NavigateEdit(item);
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 32, 13, 13)),
                                  ),
                                  value: "delete"),
                              PopupMenuItem(
                                child: Text("Edit"),
                                value: "edit",
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> fetch() async {
    setState(() {
      isloading = true;
    });
    final url = "http://api.nstack.in/v1/todos?page=1&limit=10";

    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {
      print("error");
    }
    setState(() {
      isloading = false;
    });
  }

  Future deleteItem(String id) async {
    final url = "http://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element["_id"] != id).toList();
      setState(() {
        items = filtered;
      });
      showSucess(context, "Item Deleted", Colors.red);
    } else {
      showSucess(context, "Deletion failed", Colors.black);
    }
  }

  NavigateAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenAdd(),
      ),
    );
  }

  NavigateEdit(Map item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenAdd(todo: item),
      ),
    );
  }

  void showSucess(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      ),
    );
  }
}
