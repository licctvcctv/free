
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/chat_group/pojo/im_group.dart';
import 'package:freego_flutter/components/chat_group/pojo/im_group_member.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/pager.dart';

class GroupApi{

  GroupApi._internal();
  static final GroupApi _instance = GroupApi._internal();
  factory GroupApi(){
    return _instance;
  }

  Future<int?> createCustom({required String name, required String avatar, required String description, required String type, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/custom';
    int? newId = await HttpTool.post(url, {
      'name': name,
      'avatar': avatar,
      'description': description,
      'type': type
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return newId;
  }

  Future<int?> createSect({required String name, required List<int> friendIds, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/sect';
    int? newId = await HttpTool.post(url, {
      'name': name,
      'friendIds': friendIds
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return newId;
  }

  Future<ImGroup?> get({required int id, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/im_group/$id';
    ImGroup? group = await HttpTool.get(url, {}, (response){
      return ImGroup.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return group;
  }

  Future<Pager<ImGroup>?> search({required String keyword, int page = 1, int pageSize = 20, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/search';
    Pager<ImGroup>? result = await HttpTool.get(url, {
      'keyword': keyword,
      'page': page,
      'pageSize': pageSize
    }, (response){
      int count = response.data['data']['total'];
      List<ImGroup> list = [];
      for(dynamic json in response.data['data']['list']){
        list.add(ImGroup.fromJson(json));
      }
      return Pager(list, count);
    }, fail: fail, success: success);
    return result;
  }

  Future<Pager<ImGroup>?> list({int page = 1, int pageSize = 20, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/list';
    Pager<ImGroup>? result = await HttpTool.get(url, {
      'page': page,
      'pageSize': pageSize
    }, (response){
      int count = response.data['data']['total'];
      List<ImGroup> list = [];
      for(dynamic json in response.data['data']['list']){
        list.add(ImGroup.fromJson(json));
      }
      return Pager(list, count);
    }, fail: fail, success: success);
    return result;
  }

  Future<List<ImGroup>?> range({int? minId, int? maxId, int pageSize = 20, bool isDesc = false, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/range';
    List<ImGroup>? list = await HttpTool.get(url, {
      'minId': minId,
      'maxId': maxId,
      'pageSize': pageSize,
      'isDesc': isDesc
    }, (response){
      List<ImGroup> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImGroup.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<List<ImGroup>?> all({Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/all';
    List<ImGroup>? list = await HttpTool.get(url, {}, (response){
      List<ImGroup> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImGroup.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<List<ImGroupMember>?> members({required int groupId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/members';
    List<ImGroupMember>? list = await HttpTool.get(url, {
      'groupId': groupId
    }, (response){
      List<ImGroupMember> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImGroupMember.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<ImGroupMember?> member({required int groupId, required int memberId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group/member';
    ImGroupMember? member = await HttpTool.get(url, {
      'groupId': groupId,
      'memberId': memberId
    }, (response){
      return ImGroupMember.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return member;
  }

  Future<bool> update({required int id, String? type, String? name, String? description, String? avatar, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group';
    bool? result = await HttpTool.put(url, {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'avatar': avatar
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
  
}
