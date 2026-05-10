import 'package:dio/dio.dart';
import 'package:smarthome/core/auth_storage.dart';
import 'package:smarthome/core/constants.dart';
import 'package:smarthome/models/device.dart';
import 'package:smarthome/models/room.dart';
import 'package:smarthome/models/action_log.dart';
import 'package:smarthome/models/user.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // Auth
  Future<String> login(String username, String password) async {
    final resp = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    }, options: Options(contentType: 'application/x-www-form-urlencoded'));
    return resp.data['access_token'] as String;
  }

  Future<User> getMe() async {
    final resp = await _dio.get('/auth/me');
    return User.fromJson(resp.data as Map<String, dynamic>);
  }

  // Rooms
  Future<List<Room>> getRooms() async {
    final resp = await _dio.get('/rooms/');
    return (resp.data as List).map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Device>> getRoomDevices(int roomId) async {
    final resp = await _dio.get('/rooms/$roomId/devices');
    return (resp.data as List).map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Devices
  Future<List<Device>> getDevices() async {
    final resp = await _dio.get('/devices/');
    return (resp.data as List).map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Device> toggleDevice(int deviceId) async {
    final resp = await _dio.post('/devices/$deviceId/toggle');
    return Device.fromJson(resp.data as Map<String, dynamic>);
  }

  // Logs
  Future<List<ActionLog>> getLogs({int limit = 50}) async {
    final resp = await _dio.get('/logs/', queryParameters: {'limit': limit});
    return (resp.data as List).map((e) => ActionLog.fromJson(e as Map<String, dynamic>)).toList();
  }
}
