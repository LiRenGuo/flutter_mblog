
import 'dart:convert' show json;

class User {

  String id;
  String username;
  Object firstname;
  Object lastname;
  Object email;
  Object code;
  String mobile;
  Object lastPasswordResetDate;
  Object type;
  String status;
  Object certcode;
  Object rank;
  Object following;
  Object followers;
  Object posts;
  String name;
  String banner;
  String avatar;
  Object nickname;
  String homepage;
  String intro;
  Object sex;
  int birthday;
  Object bloodtype;
  Object hometown;
  Object edulevel;
  Object religion;
  Object hobby;
  Object signature;
  Object districtid;
  Object address;
  Object postcode;
  Object language;
  Object timezone;
  Object description;
  int ctime;
  List<Object> configs;

    User({
this.id,
this.username,
this.firstname,
this.lastname,
this.email,
this.code,
this.mobile,
this.lastPasswordResetDate,
this.type,
this.status,
this.certcode,
this.rank,
this.following,
this.followers,
this.posts,
this.name,
this.banner,
this.avatar,
this.nickname,
this.homepage,
this.intro,
this.sex,
this.birthday,
this.bloodtype,
this.hometown,
this.edulevel,
this.religion,
this.hobby,
this.signature,
this.districtid,
this.address,
this.postcode,
this.language,
this.timezone,
this.description,
this.ctime,
this.configs,
    });

  factory User.fromJson(jsonRes){ if(jsonRes == null) return null;


    List<Object> configs = jsonRes['configs'] is List ? []: null; 
    if(configs!=null) {
 for (var item in jsonRes['configs']) { if (item != null) { configs.add(item);  }
    }
    }
return User(
    id : jsonRes['id'],
    username : jsonRes['username'],
    firstname : jsonRes['firstname'],
    lastname : jsonRes['lastname'],
    email : jsonRes['email'],
    code : jsonRes['code'],
    mobile : jsonRes['mobile'],
    lastPasswordResetDate : jsonRes['lastPasswordResetDate'],
    type : jsonRes['type'],
    status : jsonRes['status'],
    certcode : jsonRes['certcode'],
    rank : jsonRes['rank'],
    following : jsonRes['following'],
    followers : jsonRes['followers'],
    posts : jsonRes['posts'],
    name : jsonRes['name'],
    banner : jsonRes['banner'],
    avatar : jsonRes['avatar'],
    nickname : jsonRes['nickname'],
    homepage : jsonRes['homepage'],
    intro : jsonRes['intro'],
    sex : jsonRes['sex'],
    birthday : jsonRes['birthday'],
    bloodtype : jsonRes['bloodtype'],
    hometown : jsonRes['hometown'],
    edulevel : jsonRes['edulevel'],
    religion : jsonRes['religion'],
    hobby : jsonRes['hobby'],
    signature : jsonRes['signature'],
    districtid : jsonRes['districtid'],
    address : jsonRes['address'],
    postcode : jsonRes['postcode'],
    language : jsonRes['language'],
    timezone : jsonRes['timezone'],
    description : jsonRes['description'],
    ctime : jsonRes['ctime'],
 configs:configs,);}

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'code': code,
        'mobile': mobile,
        'lastPasswordResetDate': lastPasswordResetDate,
        'type': type,
        'status': status,
        'certcode': certcode,
        'rank': rank,
        'following': following,
        'followers': followers,
        'posts': posts,
        'name': name,
        'banner': banner,
        'avatar': avatar,
        'nickname': nickname,
        'homepage': homepage,
        'intro': intro,
        'sex': sex,
        'birthday': birthday,
        'bloodtype': bloodtype,
        'hometown': hometown,
        'edulevel': edulevel,
        'religion': religion,
        'hobby': hobby,
        'signature': signature,
        'districtid': districtid,
        'address': address,
        'postcode': postcode,
        'language': language,
        'timezone': timezone,
        'description': description,
        'ctime': ctime,
        'configs': configs,
};
  @override
String  toString() {
    return json.encode(this);
  }
}