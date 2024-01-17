import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gson/gson.dart';
import 'package:http/http.dart' as http;
import 'package:rubber_collection/collection_details.dart';
import 'package:rubber_collection/driver.dart';
import 'package:rubber_collection/supplier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorageHelper {
  final String baseURL = "https://api.hexagonasia.com/api/development";
  final gson = Gson();
  List<Supplier> supplierList = [];

  Future<void> saveUserName(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<bool> saveSupplierAndDriverList() async {
    try {
      final response =
          await http.get(Uri.parse('$baseURL/suppliers/mobile/supdetails'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Process suppliers
        final newSuppliers = <Supplier>[];
        for (final supplierJson in json['suppliers']['supDetails']) {
          final id = supplierJson['id'];
          final name = supplierJson['name'];
          final estate = supplierJson['estate'];
          final cscode = supplierJson['cscode'];
          final cat01 = supplierJson['cat01'];
          final itemmasterid = supplierJson['itemmasterId'];

          final newSupplier = Supplier(int.parse(id), name, estate, cscode,
              int.parse(cat01), int.parse(itemmasterid));
          newSuppliers.add(newSupplier);
        }

        // Process drivers
        final newDrivers = <Driver>[];
        for (final driverJson in json['suppliers']['driverDetails']) {
          final id = driverJson['id'];
          final userName = driverJson['userName'];

          final newDriver = Driver(int.parse(id), userName);
          newDrivers.add(newDriver);
        }

        // Fetch existing suppliers
        final existingSuppliers = await getSupplierList();
        // Update existing suppliers with new ones
        for (final newSupplier in newSuppliers) {
          if (!existingSuppliers.contains(newSupplier)) {
            existingSuppliers.add(newSupplier);
          }
        }

        // Fetch existing drivers
        final existingDrivers = await getDriverList();
        // Update existing drivers with new ones
        for (final newDriver in newDrivers) {
          if (!existingDrivers.contains(newDriver)) {
            existingDrivers.add(newDriver);
          }
        }

        // Save the updated lists to SharedPreferences
        final suppliersJson = jsonEncode(existingSuppliers);
        final driversJson = jsonEncode(existingDrivers);

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.setString('supplierList', suppliersJson);
        await sharedPreferences.setString('driverList', driversJson);

        return true;
      } else {
        if (kDebugMode) {
          print('API Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    return false;
  }

  Future<List<Supplier>> getSupplierList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String json = sharedPreferences.getString("supplierList") ?? "";
    if (json.isEmpty) {
      return [];
    }

    List<dynamic> jsonList = jsonDecode(json);
    List<Supplier> supplierList = jsonList.map((json) {
      return Supplier(json['id'], json['name'], json['estate'], json['cscode'],
          json['cat01'], json['itemmasterid']);
    }).toList();
    return supplierList;
  }

  Future<List<Object>> getDriverList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String json = sharedPreferences.getString("driverList") ?? "";
    if (json.isEmpty) {
      return <Driver>[Driver(0, '')];
    }

    List<dynamic> jsonList = jsonDecode(json);
    List<Driver> driverList = jsonList.map((json) {
      return Driver(json['id'], json['userName']);
    }).toList();
    return driverList;
  }

  Future<void> saveCollection(CollectionDetails collectedDetail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<CollectionDetails> existingCollection = await getCollectionList();
    existingCollection.add(collectedDetail);
    String json = jsonEncode(existingCollection);
    sharedPreferences.setString("collectionList", json);
  }

  Future<void> updateCollection(CollectionDetails collectedDetail) async {
    List<CollectionDetails> existingCollection = await getCollectionList();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int index = existingCollection.indexWhere(
      (entry) =>
          entry.cscode == collectedDetail.cscode &&
          entry.initializedDate == collectedDetail.initializedDate,
    );

    if (index != -1) {
      existingCollection.removeAt(index);
    }

    existingCollection.add(collectedDetail);

    String json = jsonEncode(existingCollection);

    await sharedPreferences.setString("collectionList", json);
  }

  Future<List<CollectionDetails>> getCollectionList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String json = sharedPreferences.getString("collectionList") ?? "";
    if (json.isEmpty) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(json);
    List<CollectionDetails> collectionList = jsonList.map((item) {
      return CollectionDetails.fromJson(item);
    }).toList();
    return collectionList;
  }

  Future<List<CollectionDetails>> getCollectionDetailsBySupplierId(
      int supplierId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/collection-details?supplierId=$supplierId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        List<CollectionDetails> collectionDetailsList = jsonList.map((json) {
          return CollectionDetails.fromJson(json);
        }).toList();

        return collectionDetailsList;
      } else {
        if (kDebugMode) {
          print('API Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    return [];
  }

  Future<String> syncData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String json = sharedPreferences.getString("collectionList") ?? "";
    List<CollectionDetails> collectionDetailsList = await getCollectionList();

    if (json.isEmpty || collectionDetailsList.isEmpty) {
      return "no data";
    }

    var client = http.Client();
    bool allDataSynced = true;

    for (CollectionDetails collectionDetails in collectionDetailsList) {
      var url = Uri.parse('$baseURL/rubbercollection');
      String userName = await getUserName();
      String ammonia = collectionDetails.typeAmmonia == "High Ammonia"
          ? "HA"
          : collectionDetails.typeAmmonia == "Low Ammonia"
              ? "LA"
              : " ";
      var response = await client.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "custsupid": collectionDetails.id,
          "cscode": collectionDetails.cscode,
          "item": collectionDetails.item,
          "liters": collectionDetails.liters,
          "kilograms": collectionDetails.kilogram,
          "metrolac": collectionDetails.metrolac,
          "dryWeight": collectionDetails.dryWeight,
          "temperature": collectionDetails.temperature,
          "nh3": collectionDetails.nh3,
          "tz": collectionDetails.tz,
          "remarks": collectionDetails.remarks,
          "trlnNumber": collectionDetails.trlnNumber,
          "typeAmmonia": ammonia,
          "container": collectionDetails.container,
          "long": collectionDetails.longitude,
          "lat": collectionDetails.latitude,
          "initializedDate": collectionDetails.initializedDate,
          "userName": userName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCollectionList();
      } else {
        allDataSynced = false;
      }
    }

    if (allDataSynced) {
      return "ok";
    } else {
      return "error";
    }
  }

  void clearCollectionList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("collectionList", "");
  }
}
