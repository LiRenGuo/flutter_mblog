class PostModel {
  List<PostItem> resultList;
  PostModel({this.resultList});
  PostModel.fromJson(Map<String, dynamic> json) {
    if(json['content'] != null) {
      resultList = new List<PostItem>();
      json['content'].forEach((v) {
        resultList.add(new PostItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.resultList != null) {
      data['resultList'] = this.resultList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PostItem {
  String id;
  String pid;
  String content;
  String devicemodel;
  List<String> photos;
  User user;
  int commentCount;
  int forwardCount;
  int likeCount;
  bool islike;
  int pubtime;
  int ctime;

  PostItem(
      {this.id,
        this.pid,
        this.content,
        this.devicemodel,
        this.photos,
        this.user,
        this.commentCount,
        this.forwardCount,
        this.likeCount,
        this.islike,
        this.pubtime,
        this.ctime});

PostItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pid = json['pid'];
    content = json['content'];
    devicemodel = json['devicemodel'];
    photos = json['photos'].cast<String>();
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    commentCount = json['commentCount'];
    forwardCount = json['forwardCount'];
    likeCount = json['likeCount'];
    islike = json['islike'];
    pubtime = json['pubtime'];
    ctime = json['ctime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pid'] = this.pid;
    data['content'] = this.content;
    data['devicemodel'] = this.devicemodel;
    data['photos'] = this.photos;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['commentCount'] = this.commentCount;
    data['forwardCount'] = this.forwardCount;
    data['likeCount'] = this.likeCount;
    data['islike'] = this.islike;
    data['pubtime'] = this.pubtime;
    data['ctime'] = this.ctime;
    return data;
  }
}

class User {
  String id;
  String username;
  String name;
  String banner;
  String avatar;
  String intro;
  bool isfollow;

  User(
      {this.id,
        this.username,
        this.name,
        this.banner,
        this.avatar,
        this.intro,
        this.isfollow});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    name = json['name'];
    banner = json['banner'];
    avatar = json['avatar'];
    intro = json['intro'];
    isfollow = json['isfollow'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['name'] = this.name;
    data['banner'] = this.banner;
    data['avatar'] = this.avatar;
    data['intro'] = this.intro;
    data['isfollow'] = this.isfollow;
    return data;
  }
}