import 'dart:convert' show json;

class MyPostModel {
  List<MyPostItem> itemList;
  int totalElements;

  MyPostModel({this.itemList, this.totalElements});

  factory MyPostModel.fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<MyPostItem> content = jsonRes['content'] is List ? [] : null;
    if (content != null) {
      for (var item in jsonRes['content']) {
        if (item != null) {
          content.add(MyPostItem.fromJson(item));
        }
      }
    }
    return MyPostModel(
        itemList: content, totalElements: jsonRes["totalElements"]);
  }

  Map<String, dynamic> toJson() => {
        'content': itemList,
        'totalElements': totalElements,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class MyPostItem {
  String id;
  Object pid;
  Object touser;
  Object refurl;
  String content;
  List<String> photos;
  Object emoji;
  Object longitude;
  Object latitude;
  Object altitude;
  Object speed;
  Object course;
  Object floor;
  Object level;
  User user;
  int commentCount;
  int forwardCount;
  int likeCount;
  List<Object> likeids;
  List<Object> forwardids;
  List<Object> commentids;
  int pubtime;
  String status;
  int ctime;
  bool islike;
  String postId;
  MyPostItem rPostItem;

  MyPostItem(
      {this.id,
      this.pid,
      this.touser,
      this.refurl,
      this.content,
      this.photos,
      this.emoji,
      this.longitude,
      this.latitude,
      this.altitude,
      this.speed,
      this.course,
      this.floor,
      this.level,
      this.user,
      this.commentCount,
      this.forwardCount,
      this.likeCount,
      this.likeids,
      this.forwardids,
      this.commentids,
      this.pubtime,
      this.status,
      this.ctime,
      this.islike,
      this.postId,
      this.rPostItem});

  factory MyPostItem.fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<String> photos = jsonRes['photos'] is List ? [] : null;
    if (photos != null) {
      for (var item in jsonRes['photos']) {
        if (item != null) {
          photos.add(item);
        }
      }
    }

    List<Object> likeids = jsonRes['likeids'] is List ? [] : null;
    if (likeids != null) {
      for (var item in jsonRes['likeids']) {
        if (item != null) {
          likeids.add(item);
        }
      }
    }

    List<Object> forwardids = jsonRes['forwardids'] is List ? [] : null;
    if (forwardids != null) {
      for (var item in jsonRes['forwardids']) {
        if (item != null) {
          forwardids.add(item);
        }
      }
    }

    List<Object> commentids = jsonRes['commentids'] is List ? [] : null;
    if (commentids != null) {
      for (var item in jsonRes['commentids']) {
        if (item != null) {
          commentids.add(item);
        }
      }
    }
    return MyPostItem(
        id: jsonRes['id'],
        pid: jsonRes['pid'],
        touser: jsonRes['touser'],
        refurl: jsonRes['refurl'],
        content: jsonRes['content'],
        photos: photos,
        emoji: jsonRes['emoji'],
        longitude: jsonRes['longitude'],
        latitude: jsonRes['latitude'],
        altitude: jsonRes['altitude'],
        speed: jsonRes['speed'],
        course: jsonRes['course'],
        floor: jsonRes['floor'],
        level: jsonRes['level'],
        user: User.fromJson(jsonRes['user']),
        commentCount: jsonRes['commentCount'],
        forwardCount: jsonRes['forwardCount'],
        likeCount: jsonRes['likeCount'],
        likeids: likeids,
        forwardids: forwardids,
        commentids: commentids,
        pubtime: jsonRes['pubtime'],
        status: jsonRes['status'],
        ctime: jsonRes['ctime'],
        islike: jsonRes['islike'],
        postId: jsonRes["postId"],
        rPostItem: jsonRes['forwardPost'] != null
            ? MyPostItem.fromJson(jsonRes['forwardPost'])
            : null);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pid': pid,
        'touser': touser,
        'refurl': refurl,
        'content': content,
        'photos': photos,
        'emoji': emoji,
        'longitude': longitude,
        'latitude': latitude,
        'altitude': altitude,
        'speed': speed,
        'course': course,
        'floor': floor,
        'level': level,
        'user': user,
        'commentCount': commentCount,
        'forwardCount': forwardCount,
        'likeCount': likeCount,
        'likeids': likeids,
        'forwardids': forwardids,
        'commentids': commentids,
        'pubtime': pubtime,
        'status': status,
        'ctime': ctime,
        'islike': islike,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class User {
  String id;
  String username;
  String name;
  String avatar;

  User({
    this.id,
    this.username,
    this.name,
    this.avatar,
  });

  factory User.fromJson(jsonRes) => jsonRes == null
      ? null
      : User(
          id: jsonRes['id'],
          username: jsonRes['username'],
          name: jsonRes['name'],
          avatar: jsonRes['avatar'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'avatar': avatar,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
