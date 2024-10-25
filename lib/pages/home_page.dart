import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool isLoading = true;

  List<Map<String, dynamic>> _items = [];

  final _noteDB = Hive.box("noteDB");

  @override
  void initState() {
    super.initState();
    showLoaderAndFetchNotes();
  }

  void showLoaderAndFetchNotes() async {
    await Future.delayed(const Duration(seconds: 3));
    _refreshItems();
  }

  //
  void _refreshItems() async {
    final data = _noteDB.keys.map((key) {
      final item = _noteDB.get(key);

      return {
        "key": key,
        "title": item["title"],
        "description": item["description"]
      };
    }).toList();

    setState(() {
      _items = data.toList();
      print("Items is : ${_items.length}");
      isLoading = false;
    });
  }

  //create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _noteDB.add(newItem);
    // print("Data is ${_noteDB.length}");
    _refreshItems();
  }

  //update
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _noteDB.put(itemKey, item);
    _refreshItems();
  }

  //delete
  Future<void> _deleteItem(int itemKey) async {
    await _noteDB.delete(itemKey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Center(
        child: Text(
          "Note Has Been Deleted!",
          style: TextStyle(
            color: Colors.yellowAccent,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);

      titleController.text = existingItem['title'];
      descController.text = existingItem['description'];
    }

    showModalBottomSheet(
      isDismissible: false,
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      enableDrag: false,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(seconds: 2),
        reverseDuration: const Duration(seconds: 1),
      ),
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  itemKey != null ? "Update Note" : "Add Note",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    hintText: "Enter Title",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter A Title!";
                    } else if (value.length <= 3) {
                      return "Title Must Be At Least 4 Characters Long.";
                    } else if (value.length > 15) {
                      return "Title Must Be 15 Characters or Less";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    hintText: "Enter Description",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter A Description!";
                    } else if (value.length <= 7) {
                      return "Description Must Be At Least 8 Characters Long.";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          splashFactory: InkRipple.splashFactory,
                          overlayColor: Colors.blue,
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (itemKey == null) {
                              _createItem({
                                "title": titleController.text,
                                "description": descController.text,
                              });
                            }

                            if (itemKey != null) {
                              _updateItem(itemKey, {
                                'title': titleController.text.trim(),
                                "description": descController.text.trim(),
                              });
                            }

                            Navigator.of(context).pop();

                            await Future.delayed(const Duration(seconds: 1));

                            //clear the text fields
                            titleController.clear();
                            descController.clear();
                          }
                        },
                        child: Text(
                          itemKey == null ? "Add Note" : "Update Note",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          splashFactory: InkRipple.splashFactory,
                          overlayColor: Colors.red,
                          side: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();

                          await Future.delayed(const Duration(seconds: 1));
                          //clear the text fields
                          titleController.clear();
                          descController.clear();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent.withOpacity(0.5),
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: Text("Notes"),
        ),
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset('assets/animation/loading.json',
                  height: 80, width: 80),
            )
          : _items.isNotEmpty
              ? ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, index) {
                    final currentItem = _items[index];
                    print('$_items');
                    return Card(
                      color: Colors.white54,
                      margin: const EdgeInsets.all(10.0),
                      // elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey.withOpacity(0.7),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        title: Text(
                          currentItem['title'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        ),
                        subtitle: Text(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          currentItem['description'],
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16.0,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 90,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Colors.greenAccent.withOpacity(0.5),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    _showForm(context, currentItem["key"]);
                                  },
                                  child: const Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CircleAvatar(
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.5),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () => showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text(
                                        "Warning!",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        "Are you sure you want to delete this note?",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                          onPressed: () {
                                            _deleteItem(currentItem["key"]);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "OK",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No Notes Found!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () => _showForm(context, null),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
