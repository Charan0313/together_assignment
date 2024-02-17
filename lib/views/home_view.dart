import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:together_assignment/controllers/list_item_controller.dart';
import 'package:together_assignment/models/list_item_model.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  final ListItemController listItemController = ListItemController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
    _fetchData(listItemController.pageNum.value);
  }

  Future<void> _fetchData(int pageKey) async {
    listItemController.isLoading.value = true;
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['BASE_URL']}?page=$pageKey&limit=10'));

      var data = json.decode(response.body.toString());

      if (response.statusCode == 200) {
        ListItem list = ListItem.fromJson(data);
        listItemController.list.addAll(list.data!);
        listItemController.isLoading.value = false;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      listItemController.isLoading.value = false;
    }
  }

  void _loadMore() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !listItemController.isLoading.value) {
      listItemController.pageNum.value++;
      _fetchData(listItemController.pageNum.value);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ListView.builder(
            controller: _scrollController,
            itemCount: listItemController.list.length +
                (listItemController.isLoading.value == true ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == listItemController.list.length) {
                return const CircularProgressIndicator();
              }
              Data listItem = listItemController.list[index];
              return ListTile(
                leading: Image.network(listItem.imageUrl.toString()),
                title: Text(listItem.title.toString()),
                subtitle: Text(listItem.description.toString()),
              );
            },
          )),
    );
  }
}
