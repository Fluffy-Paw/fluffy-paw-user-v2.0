import 'package:fluffypawuser/models/common_response/common_response.dart';
import 'package:fluffypawuser/models/report/report_model.dart';
import 'package:fluffypawuser/services/report_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportController extends StateNotifier<bool> {
  final Ref ref;
  List<ReportCategory>? _reportCategories;
  List<ReportCategory>? get reportCategories => _reportCategories;

  ReportController(this.ref) : super(false);

  Future<void> getAllReportCategories() async {
    try {
      state = true;
      final response = await ref.read(reportServiceProvider).getAllReportCategories();
      if (response.data != null && response.data['data'] != null) {
        _reportCategories = (response.data['data'] as List)
            .map((item) => ReportCategory.fromMap(item))
            .toList();
      }
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting report categories: ${e.toString()}');
    }
  }

  Future<CommonResponse> createReport(ReportRequest request) async {
    try {
      state = true;
      final response = await ref.read(reportServiceProvider).createReport(request);
      final message = response.data['message'] ?? 'Successfully created report';
      
      if (response.statusCode == 200) {
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      
      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (e) {
      state = false;
      debugPrint('Error creating report: ${e.toString()}');
      return CommonResponse(isSuccess: false, message: e.toString());
    }
  }
}

final reportController = StateNotifierProvider<ReportController, bool>(
  (ref) => ReportController(ref),
);