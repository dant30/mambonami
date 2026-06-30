import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants.dart';
import '../local/database_helper.dart';
import '../models/address.dart';

class AddressRepository {
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();
  final ValueNotifier<List<Address>> addresses = ValueNotifier<List<Address>>([]);

  Future<void> init() async {
    await _restoreAddresses();
  }

  Future<void> _restoreAddresses() async {
    final records = await _databaseHelper.getRecords(kAddressTable);
    addresses.value = records.map(Address.fromJson).toList();
  }

  Future<void> saveAddress(Address address) async {
    await _databaseHelper.insertOrUpdateRecord(kAddressTable, address.id, address.toJson());
    await _restoreAddresses();
  }

  Future<void> deleteAddress(String id) async {
    await _databaseHelper.deleteRecord(kAddressTable, id);
    await _restoreAddresses();
  }

  Address? get defaultAddress => addresses.value.isNotEmpty ? addresses.value.first : null;
}
