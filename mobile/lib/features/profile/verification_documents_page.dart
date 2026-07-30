import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/custom_image_picker.dart';
import '../../data/repositories/verification_repository.dart';
import '../../data/models/verification_document.dart';
import '../../data/dtos/verification_dto.dart';

class VerificationDocumentsPage extends StatefulWidget {
  final String? initialType;
  const VerificationDocumentsPage({super.key, this.initialType});

  @override
  State<VerificationDocumentsPage> createState() => _VerificationDocumentsPageState();
}

class _VerificationDocumentsPageState extends State<VerificationDocumentsPage> {
  final repo = GetIt.instance<VerificationRepository>();
  List<VerificationDocument> _docs = [];
  bool _loading = true;
  double? _trustScore;

  @override
  void initState() {
    super.initState();
    _load();
    // If the page was opened with an initialType, auto-open upload dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialType != null) {
        _showUploadDialog(preselected: widget.initialType);
      }
    });
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    try {
      final docs = await repo.listDocuments();
      final scoreMap = await repo.getTrustScore();
      setState(() {
        _docs = docs;
        final scoreVal = scoreMap['score'] ?? scoreMap['trust_score'] ?? scoreMap['value'];
        if (scoreVal is num) _trustScore = scoreVal.toDouble();
        else _trustScore = double.tryParse(scoreVal?.toString() ?? '0');
      });
    } catch (e) {
      CustomSnackbar.showError(context, 'Failed to load verification data');
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _uploadDocument(String type) async {
    final file = await CustomImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {});
    try {
      final req = VerificationDocumentCreateRequest(type: type, filePath: file.path);
      final doc = await repo.uploadDocument(req);
      CustomSnackbar.showSuccess(context, 'Document uploaded');
      await _load();
      Navigator.of(context).pop(true);
    } catch (e) {
      CustomSnackbar.showError(context, 'Upload failed: ${e.toString()}');
    }
  }

  void _showUploadDialog({String? preselected}) {
    showDialog(
      context: context,
      builder: (ctx) {
        String selected = preselected ?? 'national_id';
        return AlertDialog(
          title: const Text('Upload verification document'),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selected,
                    items: const [
                      DropdownMenuItem(value: 'national_id', child: Text('National ID')),
                      DropdownMenuItem(value: 'cooperative_endorsement', child: Text('Cooperative Endorsement')),
                      DropdownMenuItem(value: 'driver_license', child: Text('Driver License')),
                      DropdownMenuItem(value: 'vehicle_registration', child: Text('Vehicle Registration')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() { if (v != null) selected = v; }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _uploadDocument(selected);
              },
              child: const Text('Choose file'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Documents')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Trust Score'),
                      subtitle: Text(_trustScore != null ? _trustScore!.toStringAsFixed(2) : 'Not available'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._docs.map((d) => Card(
                        child: ListTile(
                          title: Text(d.type.replaceAll('_', ' ').toUpperCase()),
                          subtitle: Text('Status: ${d.status}'),
                          trailing: d.fileUrl != null ? IconButton(icon: const Icon(Icons.open_in_new), onPressed: () async { final url = d.fileUrl!; /* opening left as app-specific */ }) : null,
                        ),
                      )),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }
}
