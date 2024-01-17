import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rubber_collection/data_storage_helper.dart';
import 'package:rubber_collection/driver.dart';
import 'package:rubber_collection/supplier.dart';

class AddSuppliers extends StatefulWidget {
  const AddSuppliers({super.key});

  @override
  _AddSuppliersState createState() => _AddSuppliersState();
}

class _AddSuppliersState extends State<AddSuppliers> {
  TextEditingController driverUserId = TextEditingController();
  TextEditingController driverUserName = TextEditingController();
  DataStorageHelper dataStorageHelper = DataStorageHelper();

  @override
  void initState() {
    super.initState();
    _getSupplierInfo();
  }

  void _getSupplierInfo() async {
    String userName = await dataStorageHelper.getUserName();

    setState(() {
      driverUserId.text = userName;
    });

    Driver selectedDriver = Driver(0, '');
    List<Driver> driverList =
        (await dataStorageHelper.getDriverList()) as List<Driver>;

    if (driverList.isNotEmpty) {
      for (Driver driver in driverList) {
        if (driver.id ==
            int.parse(userName == '' ? '0' : userName.toString())) {
          setState(() {
            selectedDriver = driver;
          });
          driverUserName.text = selectedDriver.userName;
          break;
        }
      }
    }
    for (Driver driver in driverList) {
      if (userName.isNotEmpty && driver.id == int.parse(userName)) {
        setState(() {
          selectedDriver = driver;
        });
        driverUserName.text = selectedDriver.userName;
        break;
      }
    }
  }

  void _saveUserId() async {
    String driverId = driverUserId.text;
    if (driverId.isNotEmpty) {
      DataStorageHelper dataStorageHelper = DataStorageHelper();
      await dataStorageHelper.saveUserName(driverId);

      setState(() {
        driverUserId.text = driverId;
      });

      Driver selectedDriver = Driver(0, '');
      List<Driver> driverList =
          (await dataStorageHelper.getDriverList()) as List<Driver>;
      for (Driver driver in driverList) {
        if (driver.id == int.parse(driverId)) {
          setState(() {
            selectedDriver = driver;
          });
          driverUserName.text = selectedDriver.userName;
          break;
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Enter Driver Id')),
      );
    }
  }

  void _downloadSupplierList() {
    dataStorageHelper.saveSupplierAndDriverList().then((value) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Downloaded'),
            icon: const Icon(Icons.check_circle_outline_sharp,
                color: Colors.green),
            content: const Text('Suppliers Downloaded.',
                textAlign: TextAlign.center),
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
    });
  }

  void _syncCollectionData() {
    dataStorageHelper.syncData().then((value) {
      if (value == 'no data') {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data'),
              icon: const Icon(Icons.warning),
              content: const Text('There is no data to sync.',
                  textAlign: TextAlign.center),
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
      } else if (value == 'ok') {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Data Synced'),
              icon: const Icon(Icons.check_circle_outline_sharp,
                  color: Colors.green),
              content: const Text('Data synced successfully.',
                  textAlign: TextAlign.center),
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
      } else if (value == 'error') {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              icon: const Icon(Icons.error_outline_outlined, color: Colors.red),
              content: const Text('There was an error syncing data.',
                  textAlign: TextAlign.center),
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 50.0),
              ElevatedButton.icon(
                onPressed: () {
                  _downloadSupplierList();
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Supplier List'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () {
                  _syncCollectionData();
                },
                icon: const Icon(Icons.sync),
                label: const Text('Sync Data'),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: driverUserId,
                      decoration: const InputDecoration(labelText: 'User ID'),
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton.icon(
                    onPressed: _saveUserId,
                    label: const Text('Save User ID'),
                    icon: const Icon(Icons.save),
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
              Text(
                'User ID: ${driverUserId.text}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'User Name : ${driverUserName.text}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
