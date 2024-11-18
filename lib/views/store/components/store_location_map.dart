import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/env_config.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';

// API keys nên được lưu trong config/environment


class StoreLocationWidget extends StatefulWidget {
  final StoreModel store;

  const StoreLocationWidget({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  State<StoreLocationWidget> createState() => _StoreLocationWidgetState();
}

class _StoreLocationWidgetState extends State<StoreLocationWidget> {
  MaplibreMapController? mapController;
  LatLng? storeLocation;
  Symbol? _currentMarker;
  bool isMapReady = false;
  final Dio _dio = Dio();
  
  late final String mapStyle = 
    "https://tiles.goong.io/assets/goong_map_web.json?api_key=${EnvConfig.goongMapKey}";



 @override
  void initState() {
    super.initState();
    _setupDio();
    _getStoreCoordinates();
  }

  void _setupDio() {
    _dio.options.baseUrl = 'https://rsapi.goong.io';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Future<void> _getStoreCoordinates() async {
    try {
      final response = await _dio.get(
        '/geocode',
        queryParameters: {
          'address': widget.store.address,
          'api_key': EnvConfig.goongApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          setState(() {
            storeLocation = LatLng(location['lat'], location['lng']);
            if (isMapReady) {
              _addMarkerAtStoreLocation();
            }
          });
        }
      }
    } catch (e) {
      print('Error getting store coordinates: $e');
      setState(() {
        storeLocation = LatLng(21.03357551700003, 105.81911236900004);
        if (isMapReady) {
          _addMarkerAtStoreLocation();
        }
      });
    }
  }

  void _handleDioError(DioException error) {
    String errorMessage;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Server error: ${error.response?.statusMessage}';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      default:
        errorMessage = 'Something went wrong: ${error.message}';
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
  Future<void> _openInGoogleMaps() async {
    try {
      final String googleMapsUrl;
      
      if (storeLocation != null) {
        // Nếu có tọa độ, dùng tọa độ để mở map
        googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${storeLocation!.latitude},${storeLocation!.longitude}';
      } else {
        // Nếu không có tọa độ, dùng địa chỉ
        final encodedAddress = Uri.encodeComponent(widget.store.address);
        googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
      }

      final Uri uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch Google Maps';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening Google Maps: $e')),
        );
      }
    }
  }

  void _onMapCreated(MaplibreMapController controller) {
    mapController = controller;
    setState(() {
      isMapReady = true;
    });
    if (storeLocation != null) {
      _addMarkerAtStoreLocation();
    }
  }

  void _addMarkerAtStoreLocation() async {
    if (mapController == null || storeLocation == null) return;

    try {
      if (_currentMarker != null) {
        await mapController!.removeSymbol(_currentMarker!);
      }

      _currentMarker = await mapController!.addSymbol(
        SymbolOptions(
          geometry: storeLocation!,
          iconImage: 'store',
          iconSize: 0.5,
        ),
      );

      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          storeLocation!,
          15.0,
        ),
      );
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Wrap MaplibreMap with GestureDetector
            GestureDetector(
              onTap: _openInGoogleMaps,
              child: Stack(
                children: [
                  MaplibreMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: storeLocation ?? LatLng(21.03357551700003, 105.81911236900004),
                      zoom: 15.0,
                    ),
                    styleString: mapStyle,
                    attributionButtonPosition: null,
                  ),
                  // Lớp trong suốt để hiện cursor pointer trên web
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Gradient và địa chỉ
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.store.address,
                        style: AppTextStyle(context).bodyText.copyWith(
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: AppColor.whiteColor,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dio.close();
    mapController?.dispose();
    super.dispose();
  }
}