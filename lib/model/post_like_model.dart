class PostLikeModel {
  List<PostLikeItem> postLikeItemList;

  PostLikeModel(
      {this.postLikeItemList});

  PostLikeModel.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      postLikeItemList = new List<PostLikeItem>();
      json['content'].forEach((v) {
        postLikeItemList.add(new PostLikeItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.postLikeItemList != null) {
      data['postLikeList'] = this.postLikeItemList.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'PostLikeModel{postLikeItemList: $postLikeItemList}';
  }
}

class PostLikeItem {
  String id;
  Null pid;
  String content;
  String devicemodel;
  List<String> photos;
  Null emoji;
  int commentCount;
  int likeCount;
  bool islike;
  UserDto userDto;
  int ctime;
  String postId;
  String website;
  PostLikeItem rPostLikeItem;

  PostLikeItem(
      {this.id,
        this.pid,
        this.content,
        this.devicemodel,
        this.photos,
        this.emoji,
        this.commentCount,
        this.likeCount,
        this.islike,
        this.userDto,
        this.website,
        this.ctime,this.postId,this.rPostLikeItem});

  PostLikeItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pid = json['pid'];
    content = json['content'];
    devicemodel = json['devicemodel'];
    photos = json['photos'].cast<String>();
    emoji = json['emoji'];
    commentCount = json['commentCount'];
    likeCount = json['likeCount'];
    islike = json['islike'];
    userDto = json['userDto'] != null ? new UserDto.fromJson(json['userDto']) : json["user"] != null ?UserDto.fromJson(json["user"]):null;
    ctime = json['ctime'];
    website = json['website'];
    postId = json['postId'];
    rPostLikeItem = json['forwardPost'] != null
        ? new PostLikeItem.fromJson(json['forwardPost'])
        : null;
  }


  @override
  String toString() {
    return 'PostLikeItem{id: $id, pid: $pid, content: $content, devicemodel: $devicemodel, photos: $photos, emoji: $emoji, commentCount: $commentCount, likeCount: $likeCount, islike: $islike, userDto: $userDto, ctime: $ctime}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pid'] = this.pid;
    data['content'] = this.content;
    data['devicemodel'] = this.devicemodel;
    data['photos'] = this.photos;
    data['emoji'] = this.emoji;
    data['commentCount'] = this.commentCount;
    data['likeCount'] = this.likeCount;
    data['islike'] = this.islike;
    if (this.userDto != null) {
      data['userDto'] = this.userDto.toJson();
    }
    data['ctime'] = this.ctime;
    return data;
  }
}

class UserDto {
  String id;
  String name;
  String mobile;
  String avatar;
  String username;

  UserDto({this.id, this.name, this.mobile, this.avatar, this.username});

  UserDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    avatar = json['avatar'];
    username = json['username'];
  }


  @override
  String toString() {
    return 'UserDto{id: $id, name: $name, mobile: $mobile, avatar: $avatar, username: $username}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['avatar'] = this.avatar;
    data['username'] = this.username;
    return data;
  }
}