class PostCommentModel {
  List<PostCommentItem> content;

  PostCommentModel(
      {this.content});

  PostCommentModel.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      content = new List<PostCommentItem>();
      json['content'].forEach((v) {
        content.add(new PostCommentItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.content != null) {
      data['content'] = this.content.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PostCommentItem {
  String id;
  User user;
  String content;
  int ctime;

  PostCommentItem({this.id, this.user, this.content, this.ctime});

  PostCommentItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    content = json['content'];
    ctime = json['ctime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
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