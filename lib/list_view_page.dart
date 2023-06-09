import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'data_model/popular_data_model.dart';

class ListViewPage extends StatelessWidget {
  const ListViewPage({super.key, required this.resultData});

  final List<Results> resultData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: resultData.length,
        itemBuilder: (context, index) {
          Results data = resultData[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(data.title!),
                ),
                Text(
                  DateFormat('dd/MM/yy').format(
                    DateTime.parse(data.publishedDate!),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  color: Colors.black,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
