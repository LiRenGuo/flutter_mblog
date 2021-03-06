class PostModel {
  int totalPages;
  List<PostItem> content;
  PostModel({this.content, this.totalPages});
  PostModel.fromJson(Map<String, dynamic> json) {
    if(json['content'] != null) {
      content = new List<PostItem>();
      json['content'].forEach((v) {
        content.add(new PostItem.fromJson(v));
      });
    }
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.content != null) {
      data['content'] = this.content.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = totalPages;
    return data;
  }

  @override
  String toString() {
    return 'PostModel{totalPages: $totalPages, content: $content}';
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
  String postId;
  String website;
  PostItem forwardPost;

  @override
  String toString() {
    return 'PostItem{id: $id, pid: $pid, content: $content, devicemodel: $devicemodel, photos: $photos, user: $user, commentCount: $commentCount, forwardCount: $forwardCount, likeCount: $likeCount, islike: $islike, pubtime: $pubtime, ctime: $ctime, postId: $postId, forwardPost: $forwardPost}';
  }

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
        this.postId,
        this.website,
        this.ctime,this.forwardPost});

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
    postId = json['postId'];
    website = json['website'];
    forwardPost = json['forwardPost'] != null
        ? new PostItem.fromJson(json['forwardPost'])
        : null;
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
    data['postId'] = this.postId;
    if (this.forwardPost != null) {
      data['forwardPost'] = this.forwardPost.toJson();
    }
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