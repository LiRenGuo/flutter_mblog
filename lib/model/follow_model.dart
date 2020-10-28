///
/// 关注实体
class FollowModel {
  List<Follow> followList;

  FollowModel(
      {this.followList});

  FollowModel.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      followList = new List<Follow>();
      json['content'].forEach((v) {
        followList.add(new Follow.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.followList != null) {
      data['content'] = this.followList.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'FollowModel{followList: $followList}';
  }
}

class Follow {
  String id;
  String username;
  String name;
  String banner;
  String avatar;
  String intro;
  bool isfollow;

  Follow(
      {this.id,
        this.username,
        this.name,
        this.banner,
        this.avatar,
        this.intro,
        this.isfollow});

  Follow.fromJson(Map<String, dynamic> json) {
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

  @override
  String toString() {
    return 'Follow{id: $id, username: $username, name: $name, banner: $banner, avatar: $avatar, intro: $intro, isfollow: $isfollow}';
  }
}