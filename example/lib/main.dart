import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
          body: PlutoGridTableViewPage()),
    );
  }
}

/// PlutoGrid Example
//
/// For more examples, go to the demo web link on the github below.
class PlutoGridTableViewPage extends StatefulWidget {
  const PlutoGridTableViewPage({Key? key}) : super(key: key);

  @override
  State<PlutoGridTableViewPage> createState() => _PlutoGridTableViewPageState();
}

class _PlutoGridTableViewPageState extends State<PlutoGridTableViewPage> {
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.text(),
      width: 50,
      enableEditingMode: false,
      enableContextMenu: false,
    ),
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
      enableEditingMode: false,
      enableContextMenu: false,
    ),
    PlutoColumn(
      title: 'Age',
      field: 'age',
      type: PlutoColumnType.number(),
      enableEditingMode: false,
      enableContextMenu: false,
    ),
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.select(<String>[
        'Programmer',
        'Designer',
        'Owner',
      ]),
      enableEditingMode: false,
      enableContextMenu: false,
    ),
    PlutoColumn(
      title: 'Joined',
      field: 'joined',
      type: PlutoColumnType.date(),
      enableEditingMode: false,
      enableContextMenu: false,
    ),
    PlutoColumn(
      title: 'Working time',
      field: 'working_time',
      type: PlutoColumnType.time(),
      enableEditingMode: false,
      enableContextMenu: false,
    ),
    PlutoColumn(
      title: 'salary',
      field: 'salary',
      type: PlutoColumnType.currency(),
      enableEditingMode: false,
      enableContextMenu: false,
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          formatAsCurrency: true,
          type: PlutoAggregateColumnType.sum,
          format: '#,###',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Sum',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' : '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
  ];

  late final List<PlutoRow> rows =
      List.generate(2, (index) => createRow(index)).toList();

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: PlutoGrid(
        columns: columns,
        rows: rows,
        columnGroups: columnGroups,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setSelectingMode(PlutoGridSelectingMode.row);
          scrollToBottomIfLastRowVisible();
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onSelected: (event) {
          print("SELECT");
        },
        onRowSecondaryTap: (event) {
          setState(() {
            stateManager.appendRows([createRow(rows.length)]);
            scrollToBottomIfLastRowVisible();
          });
        },
        configuration: PlutoGridConfiguration(
            columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale),
            style: PlutoGridStyleConfig(
                activatedBorderColor: Colors.red,
                activatedColor: Colors.red,
                rowColor: Colors.yellow,
                columnHeight: 30,
                rowHeight: 30,
                oddRowColor: Colors.red[100],
                gridBorderColor: Colors.transparent,
                borderColor: Colors.transparent)),
      ),
    );
  }

  void scrollToBottomIfLastRowVisible() {
    final vScroll = stateManager.scroll.vertical!;
    final maxExtent = stateManager.scroll.maxScrollVertical;
    final diff = maxExtent - vScroll.offset;
    if (diff < stateManager.rowTotalHeight) {
      vScroll.animateTo(maxExtent + stateManager.rowTotalHeight,
          curve: Curves.easeIn, duration: Duration(milliseconds: 300));
    }
  }

  PlutoRow createRow(int index) {
    final rows = {
      0: PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user$index'),
          'name': PlutoCell(value: 'Mike-$index'),
          'age': PlutoCell(value: 20),
          'role': PlutoCell(value: 'Programmer-$index'),
          'joined': PlutoCell(value: '2021-01-01'),
          'working_time': PlutoCell(value: '09:00'),
          'salary': PlutoCell(value: 300),
        },
      ),
      1: PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user$index'),
          'name': PlutoCell(value: 'Jack-$index'),
          'age': PlutoCell(value: 25),
          'role': PlutoCell(value: 'Designer-$index'),
          'joined': PlutoCell(value: '2021-02-01'),
          'working_time': PlutoCell(value: '10:00'),
          'salary': PlutoCell(value: 400),
        },
      ),
      2: PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user$index'),
          'name': PlutoCell(value: 'Suzi-$index'),
          'age': PlutoCell(value: 40),
          'role': PlutoCell(
              value:
                  'Visual Studio uses an XML-based documentation format that is placed withinOwner-$index'),
          'joined': PlutoCell(value: '2021-03-01'),
          'working_time': PlutoCell(value: '11:00'),
          'salary': PlutoCell(value: 700),
        },
      ),
    };
    return rows[index % 3]!;
  }
}