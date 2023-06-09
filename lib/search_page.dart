import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/search_data_model.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = ScrollController();
  String article = '';
  List<Docs> dataList = [];
  int page = 0;
  int maxPerPage = 10;
  bool hasMore = true;
  bool isLoading = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        getApi();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  getApi() async {
    if (isLoading) return;

    isLoading = true;

    http.Response response = await http.get(
      Uri.parse(
          'https://api.nytimes.com/svc/search/v2/articlesearch.json?q=$article&page=$page&api-key=snT4uLnLAsf7vw5NbILG13pQjLL26wEv'),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> convertedData = jsonDecode(response.body);

      final searchData = SearchDataModel.fromJson(convertedData);

      setState(() {
        page++;
        isLoading = false;
        isSending = false;
        dataList.addAll(searchData.response!.docs!);

        if (dataList.length < maxPerPage) {
          hasMore = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          article = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 0,
                        ),
                        hintText:
                            'Search articles here', // Set the hint text here
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the border radius as needed
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSending = true;
                        dataList = [];
                        getApi();
                      });
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
              Expanded(
                child: dataList.isNotEmpty || isSending == true
                    ? isSending
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: controller,
                            itemBuilder: (context, index) {
                              if (index < dataList.length) {
                                Docs data = dataList[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10.0,
                                        ),
                                        child: Text(data.abstract!),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yy').format(
                                          DateTime.parse(data.pubDate!),
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return hasMore
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : const Text('No More Data To Show!');
                              }
                            },
                            itemCount: dataList.length + 1,
                          )
                    : const Center(
                        child: Text('No Result For Now!'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
