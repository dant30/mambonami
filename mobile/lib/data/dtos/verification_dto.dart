import 'package:dio/dio.dart';

class VerificationDocumentCreateRequest {
  final String type;
  final String? notes;
  final String? filePath;

  VerificationDocumentCreateRequest({required this.type, this.notes, this.filePath});

  /// Build form data for multipart upload (if filePath provided)
  Future<FormData> toFormData() async {
    final form = FormData();
    form.fields.add(MapEntry('type', type));
    if (notes != null) form.fields.add(MapEntry('notes', notes!));
    if (filePath != null) {
      form.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(filePath!, filename: filePath!.split(RegExp(r'[\\/]+')).last),
      ));
    }
    return form;
  }
}
