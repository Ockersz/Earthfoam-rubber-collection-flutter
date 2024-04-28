import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:rubber_collection/collection_details.dart';
import 'package:rubber_collection/data_storage_helper.dart';
import 'package:rubber_collection/printer_screen.dart';
import 'package:rubber_collection/supplier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController txtLitresController;
  late TextEditingController txtKgController;
  late TextEditingController txtMetrolacController;
  late TextEditingController txtDryWeightController;
  late TextEditingController txtTemperatureController;
  late TextEditingController txtNh3Controller;
  late TextEditingController txtTzController;
  late TextEditingController txtRemarksController;
  late TextEditingController txtTrlnNumberController;

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

  String? csCode = '';
  double? litres = 0.0;
  double? kg = 0.0;
  double? metrolac = 0.0;
  double? dryWeight = 0.0;
  double? temperature = 0.0;
  double? nh3 = 0.0;
  double? tz = 0.0;
  String? remarks = '';
  double? trlnNumber = 0.0;

  String containerValue = "Front";
  String typeAmmoniaValue = "High Ammonia";

  int supplierId = 0;
  String supplierName = ' ';
  String estate = ' ';
  String category = ' ';
  int itemmasterid = 0;
  bool isOttapaluChecked = false;

  List<CollectionDetails> existingCollectionList = [];
  CollectionDetails? selectedCollection;

  final List<String> containerList = [
    "Front",
    "Middle",
    "Back",
    "Barrel",
    "Other"
  ];
  final List<String> ammoniaList = ["High Ammonia", "Low Ammonia"];

  @override
  void initState() {
    super.initState();
    txtLitresController = TextEditingController();
    txtKgController = TextEditingController();
    txtMetrolacController = TextEditingController();
    txtDryWeightController = TextEditingController();
    txtTemperatureController = TextEditingController();
    txtNh3Controller = TextEditingController();
    txtTzController = TextEditingController();
    txtRemarksController = TextEditingController();
    txtTrlnNumberController = TextEditingController();

    supplierId = 0;
    supplierName = ' ';
    estate = ' ';

    txtLitresController.addListener(updateKilograms);
  }

  void _clearFields() {
    txtLitresController.clear();
    txtKgController.clear();
    txtMetrolacController.clear();
    txtDryWeightController.clear();
    txtTemperatureController.clear();
    txtNh3Controller.clear();
    txtTzController.clear();
    txtRemarksController.clear();
    txtTrlnNumberController.clear();
    setState(() {
      supplierId = 0;
      supplierName = ' ';
      estate = ' ';
      csCode = '';
      category = ' ';
      itemmasterid = 0;
      containerValue = "Front";
      typeAmmoniaValue = "High Ammonia";
    });
  }

  void _saveCollection() async {
    if (supplierId == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please Scan Supplier QR Code'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Saving Collection'),
            content: CircularProgressIndicator(),
          );
        },
      );

      Position position = await _determinePosition();

      double latitude = position.latitude;
      double longitude = position.longitude;
      String formattedDateTime = selectedCollection?.initializedDate ?? '';
      if (selectedCollection == null) {
        DateTime currentDateTime = DateTime.now();
        formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime);
      }

      CollectionDetails collectedObject = CollectionDetails(
        id: supplierId,
        cscode: csCode,
        item: isOttapaluChecked ? 6775 : itemmasterid,
        liters: double.tryParse(txtLitresController.text),
        kilogram: double.tryParse(txtKgController.text),
        metrolac: double.tryParse(txtMetrolacController.text),
        dryWeight: double.tryParse(txtDryWeightController.text),
        temperature: double.tryParse(txtTemperatureController.text),
        nh3: double.tryParse(txtNh3Controller.text),
        tz: double.tryParse(txtTzController.text),
        remarks: txtRemarksController.text,
        trlnNumber: int.tryParse(txtTrlnNumberController.text),
        typeAmmonia: typeAmmoniaValue,
        container: containerValue,
        longitude: latitude,
        latitude: longitude,
        initializedDate: formattedDateTime,
      );

      DataStorageHelper dataStorageHelper = DataStorageHelper();
      if (selectedCollection != null) {
        dataStorageHelper.updateCollection(collectedObject);
      } else {
        dataStorageHelper.saveCollection(collectedObject);
      }

      _clearFields();
      existingCollectionList.clear();
      isOttapaluChecked = false;

      setState(() {
        selectedCollection = null;
      });

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Collection Saved', textAlign: TextAlign.center),
            content: const SingleChildScrollView(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The collection has been successfully saved.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PrintScreen(collectionDetails: collectedObject)));
                },
                child: const Text('Print Receipt'),
              ),
            ],
          );
        },
      );
    }
  }

  void updateKilograms() {
    // Conversion rate: 1 liter = 0.975 kgs
    double liters = double.tryParse(txtLitresController.text) ?? 0;
    double kilograms = liters * 0.975;
    txtKgController.text = kilograms.toString();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled.'),
        ),
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
  }

  @override
  void dispose() {
    txtLitresController.dispose();
    txtKgController.dispose();
    txtMetrolacController.dispose();
    txtDryWeightController.dispose();
    txtTemperatureController.dispose();
    txtNh3Controller.dispose();
    txtTzController.dispose();
    txtRemarksController.dispose();
    txtTrlnNumberController.dispose();
    super.dispose();
  }

  Future<void> _getSupplierQR(String code) async {
    if (code.isEmpty || double.tryParse(code) == null) return;
    DataStorageHelper dataStorageHelper = DataStorageHelper();
    List<Supplier> supplierList = await dataStorageHelper.getSupplierList();
    for (Supplier supplier in supplierList) {
      if (supplier.id == int.parse(code)) {
        setState(() {
          supplierId = supplier.id;
          csCode = supplier.cscode;
          supplierName = supplier.name;
          estate = supplier.estate;
          category = supplier.cat01 == 1
              ? "Organic"
              : supplier.cat01 == 2
                  ? "Non-Organic"
                  : " ";
          itemmasterid = supplier.cat01 == 1
              ? 133
              : supplier.cat01 == 2
                  ? 127
                  : 6755;
        });
        break;
      }
    }

    List<CollectionDetails> collectionList =
        await dataStorageHelper.getCollectionList();
    existingCollectionList.clear();
    for (CollectionDetails collection in collectionList) {
      if (collection.id == int.parse(code)) {
        existingCollectionList.add(collection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(supplierId == 0
                              ? ""
                              : "Supplier Id : $supplierId"),
                          Text(supplierName == ' '
                              ? ""
                              : "Supplier Name : $supplierName"),
                          Text(estate == ' ' ? "" : "Estate : $estate"),
                          Text(csCode == '' ? "" : "CS Code : $csCode"),
                          Text(category == ' ' ? "" : "Category : $category"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: existingCollectionList.isNotEmpty
                          ? Column(
                              children: [
                                const Text(
                                  'Select Existing Collection',
                                ),
                                DropdownButton<CollectionDetails>(
                                  value: selectedCollection,
                                  onChanged: (CollectionDetails? newValue) {
                                    setState(() {
                                      selectedCollection = newValue;
                                      if (selectedCollection != null) {
                                        isOttapaluChecked =
                                            selectedCollection?.item == 6775
                                                ? true
                                                : false;
                                        txtLitresController.text =
                                            selectedCollection?.liters
                                                    ?.toString() ??
                                                '';
                                        txtKgController.text =
                                            selectedCollection?.kilogram
                                                    ?.toString() ??
                                                '';
                                        txtMetrolacController.text =
                                            selectedCollection?.metrolac
                                                    ?.toString() ??
                                                '';
                                        txtDryWeightController.text =
                                            selectedCollection?.dryWeight
                                                    ?.toString() ??
                                                '';
                                        txtTemperatureController.text =
                                            selectedCollection?.temperature
                                                    ?.toString() ??
                                                '';
                                        txtNh3Controller.text =
                                            selectedCollection?.nh3
                                                    ?.toString() ??
                                                '';
                                        txtTzController.text =
                                            selectedCollection?.tz
                                                    ?.toString() ??
                                                '';
                                        txtRemarksController.text =
                                            selectedCollection?.remarks ?? '';
                                        txtTrlnNumberController.text =
                                            selectedCollection?.trlnNumber
                                                    ?.toString() ??
                                                '';
                                        typeAmmoniaValue =
                                            selectedCollection?.typeAmmonia ??
                                                'High Ammonia';
                                        containerValue =
                                            selectedCollection?.container ??
                                                'Front';
                                      } else {
                                        txtLitresController.text = '';
                                        txtKgController.text = '';
                                        txtMetrolacController.text = '';
                                        txtDryWeightController.text = '';
                                        txtTemperatureController.text = '';
                                        txtNh3Controller.text = '';
                                        txtTzController.text = '';
                                        txtRemarksController.text = '';
                                        txtTrlnNumberController.text = '';
                                        typeAmmoniaValue = 'High Ammonia';
                                        containerValue = 'Front';
                                      }
                                    });
                                  },
                                  items: [
                                    const DropdownMenuItem<CollectionDetails>(
                                      value: null,
                                      child: Text('New Collection'),
                                    ),
                                    ...existingCollectionList.map<
                                        DropdownMenuItem<CollectionDetails>>(
                                      (CollectionDetails collection) {
                                        return DropdownMenuItem<
                                            CollectionDetails>(
                                          value: collection,
                                          child: Text(
                                              collection.initializedDate ?? ''),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : null,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                            context: context,
                            onCode: (codes) async {
                              await _getSupplierQR(codes!);
                            },
                          );
                        },
                        child: const IntrinsicWidth(
                          child: Row(
                            children: [
                              Icon(Icons.qr_code),
                              SizedBox(width: 10),
                              Text('Scan'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(height: 1.0, child: Container(color: Colors.grey)),
                    const SizedBox(height: 20.0),
                    CheckboxListTile(
                      title: const Text('Ottapalu'),
                      value: isOttapaluChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isOttapaluChecked = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtLitresController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'Enter Value in Liters',
                          labelText: 'Liters (L)'),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtKgController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Value in Kilograms',
                        labelText: 'Kilograms (Kg)',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtMetrolacController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Value in Metrolac',
                        labelText: 'Metrolac',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtDryWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Value in Kilograms',
                        labelText: 'Dry Weight (Kg)',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtTemperatureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Value in Celsius',
                        labelText: 'Temperature',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Ammonia Level'),
                          Center(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: typeAmmoniaValue,
                              onChanged: (value) {
                                setState(() {
                                  typeAmmoniaValue = value!;
                                });
                              },
                              items: ammoniaList.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: SizedBox(
                                    child: Text(item),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtNh3Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Value in NH3',
                        labelText: 'Ammonia (NH3)',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtTzController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Value in TZ',
                        labelText: 'TZ',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtRemarksController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Enter Remarks',
                        labelText: 'Remarks [Optional]',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: txtTrlnNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter TRLN Number',
                        labelText: 'TRLN Number',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Container Type'),
                          Center(
                            child: DropdownButton<String>(
                              value: containerValue,
                              isExpanded: true,
                              onChanged: (value) {
                                setState(() {
                                  containerValue = value!;
                                });
                              },
                              items: containerList.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: SizedBox(
                                    child: Text(item),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _saveCollection();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
