import 'package:flutter/material.dart';

class LogDataTableScreen extends StatelessWidget {
  final Map<String, dynamic> responseData;
  LogDataTableScreen({super.key, required this.responseData});
  List<int>? logCounts;
  List<int>? bins;
  int? total;
  @override
  Widget build(BuildContext context) {
    bins = List<int>.from(responseData['bins']);
    logCounts = List<int>.from(responseData['log_counts']);
    total = responseData['total_logs'];
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  "Logs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text("Range",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text("Count",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text("Percentage",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: List.generate(
                        logCounts!.length - 1,
                        (index) {
                          return DataRow(cells: [
                            DataCell(
                                Text("${bins![index]} - ${bins![index + 1]}")),
                            DataCell(Text("${logCounts![index]}")),
                            DataCell(Text(
                                "${(100 * (logCounts![index] / total!)).toStringAsFixed(2)}")),
                          ]);
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
