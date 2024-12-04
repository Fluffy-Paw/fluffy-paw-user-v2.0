import 'package:dio/dio.dart';
import 'package:fluffypawuser/models/report/report_model.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';

abstract class ReportProvider {
  Future<Response> getAllReportCategories();
  Future<Response> createReport(ReportRequest request);
}

class ReportServiceProvider implements ReportProvider {
  final Ref ref;

  ReportServiceProvider(this.ref);

  @override
  Future<Response> getAllReportCategories() async {
    final response = await ref.read(apiClientProvider).get(
          AppConstants.getAllReportCategoryName,
        );
    return response;
  }

  @override
  Future<Response> createReport(ReportRequest request) async {
    final response = await ref.read(apiClientProvider).post(
          AppConstants.createReport,
          data: request.toMap(),
        );
    return response;
  }
}

final reportServiceProvider = Provider((ref) => ReportServiceProvider(ref));