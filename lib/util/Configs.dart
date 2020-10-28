import 'dart:ui';

///
/// 授权地址
class Auth{
  static final ipaddress = "http://mblog.yunep.com";  // 前缀地址
  static final AuthServer ='${ipaddress}/api/profile';  // 获取授权信息用户
  static final TokenUrl = '${ipaddress}/auth/oauth/token';//授权地址
}

///
/// 常量通用
class Constants{

}

///
/// 本地存储常量
class Shared{
  static final Shared_Token = 'Shared_Token';
  static final Shared_ResToken = 'Shared_ResToken';
  static final Shared_Username = 'Shared_username';
  static final Shared_Name = 'Shared_name';
  static final Shared_Avatar = 'Shared_avatar';
  static final Shared_Banner = 'Shared_Banner';
  static final Shared_Email= 'Shared_email';
  static final Shared_Mobile= 'Shared_Mobile';
  static final Shared_Id= 'Shared_id';
  static final Shared_Following= 'Shared_following';
  static final Shared_Followers= 'Shared_followers';
  static final Shared_Ctime= 'Shared_Ctime';
  static final Shared_Twitter= 'Shared_Twitter';
}