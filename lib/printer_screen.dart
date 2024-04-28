import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rubber_collection/collection_details.dart';
import 'package:rubber_collection/data_storage_helper.dart';
import 'package:rubber_collection/printer_text_formatter.dart';
import 'package:rubber_collection/supplier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintScreen extends StatefulWidget {
  final CollectionDetails collectionDetails;

  const PrintScreen({
    super.key,
    required this.collectionDetails,
  });

  @override
  _PrintScreenWidgetState createState() => _PrintScreenWidgetState();
}

class _PrintScreenWidgetState extends State<PrintScreen> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';
  late CollectionDetails details;
  late String supplierName;

  void getSupplierName() async {
    DataStorageHelper dataStorageHelper = DataStorageHelper();
    List<Supplier> supplierList = await dataStorageHelper.getSupplierList();
    for (Supplier supplier in supplierList) {
      if (supplier.id == details.id) {
        supplierName = supplier.name;
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    details = widget.collectionDetails;
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
    WidgetsBinding.instance.addPostFrameCallback((_) => getSupplierName());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 10));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Print Receipt'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.name ?? ''),
                              subtitle: Text(d.address ?? ''),
                              onTap: () async {
                                setState(() {
                                  _device = d;
                                });
                              },
                              trailing: _device != null &&
                                      _device!.address == d.address
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('connect'),
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device!.address != null) {
                                      setState(() {
                                        tips = 'connecting...';
                                      });
                                      await bluetoothPrint.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                      print('please select device');
                                    }
                                  },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('disconnect'),
                            onPressed: _connected
                                ? () async {
                                    setState(() {
                                      tips = 'disconnecting...';
                                    });
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      Divider(),
                      OutlinedButton(
                        child: Text('print receipt(esc)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();

                                PrinterTextFormatter formatter =
                                    PrinterTextFormatter();

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? userId = prefs.getString('userId');

                                formatter.addSubHeading(
                                    '********************************');
                                formatter.addHeading('Hexagon');
                                formatter.addLineBreak();

                                formatter.addCenteredText(
                                    'Temporary Latex Collection');
                                formatter.addCenteredText('Receipt');
                                formatter.addLineBreak();
                                formatter.addDateValue(
                                    'Date :',
                                    DateFormat("dd/MM/yyyy HH:mm:ss").format(
                                        DateTime.parse(details.initializedDate
                                            .toString())));
                                formatter.addLineBreak();
                                formatter.addNameValue(
                                    "TLRN No :", details.trlnNumber.toString());

                                formatter.addLineBreak();
                                formatter.addNameValue(
                                    "Supplier Name : ", supplierName);
                                formatter.addLineBreak();
                                formatter.addNameValue(
                                    "Supplier ID : ", details.id.toString());
                                formatter.addLineBreak();
                                formatter.addNameValue(
                                    "User ID : ", userId.toString());
                                formatter.addLineBreak();
                                formatter.addLineBreak();
                                formatter.addLineBreak();
                                formatter.addValue(
                                    'Liters', ":", "${details.liters} L");
                                formatter.addValue('Wet Kilograms', ":",
                                    "${details.kilogram} Kg");
                                formatter.addValue('Metrolac', ":",
                                    details.metrolac.toString());
                                formatter.addValue(
                                    'Temp', ":", "${details.temperature} °C");
                                formatter.addValue(
                                    'NH3', ":", details.nh3.toString());
                                formatter.addValue(
                                    'TZ', ":", details.tz.toString());
                                formatter.addValue(
                                    'Tank', ":", details.container.toString());

                                formatter.addLineBreak();
                                formatter.addSubHeading(
                                    '--------------------------------');
                                formatter.addLineBreak();
                                formatter.addCenteredText(
                                    'Thank you for your service !!');
                                formatter
                                    .addCenteredText('HEXAGON ASIA (PVT) Ltd');

                                formatter.addLineBreak();
                                formatter.addSubHeading(
                                    '********************************');
                                formatter.addLineBreak();

                                List<LineText> formattedText =
                                    formatter.generate();
                                await bluetoothPrint.printReceipt(
                                    config, formattedText);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 300.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 50),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data == true) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () =>
                      bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
    );
  }
}
