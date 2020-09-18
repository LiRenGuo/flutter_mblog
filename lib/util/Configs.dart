import 'dart:ui';

class AppColors {
  static const TabIconActive = 0xff66ccff;



}
class Test{
  static final ipaddress = "http://mblog.yunep.com";
  static  const splash_network_photos =  "https://ss2.bdstatick.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=47889319,3939872287&fm=26&gp=0.jpg";
  static const  Getcontent = 'https://mblog.ippse.com/api/post';
  static final IilkeUrl = '${ipaddress}/api/post/like';//点赞接口
  static const Sendcode = 'http://mblog.yunep.com/api/register/code/send';
  static const Register = 'http://mblog.yunep.com/api/register';
  static const AuthServer ='http://mblog.yunep.com/api/profile';
  static final TokenUrl = '${ipaddress}/auth/oauth/token';//授权地址
  static final UpdateAvatar = "${ipaddress}/api/profile/update/avatar";//更换头像地址
  static final UpdateBanner = "${ipaddress}/api/profile/update/banner";//更换背景地址
}

class Url{
  static final ipaddress = "http://mblog.yunep.com";
  static final PostComment = "${ipaddress}/api/comment/post/";//获取文章评论
  static final UserUrl = "${ipaddress}/api/profile";//获取登录用户信息
  static final PostUrl = "${ipaddress}/api/post";//获取主页
  static final MyPostUrl = "${ipaddress}/api/post/my";//获取登录用户的个人主页
  static final RegisteCodeSend = "${ipaddress}/api/register/code/send";//获取注册验证码
  static final ForgetCodeSend = "${ipaddress}/api/forget/password/code/send";//获取重置密码验证码
  static final SetCodeSend = "${ipaddress}/api/reset/emailormobile/code";//获取设置手机号`邮箱地址验证码
  static final RegisteCode = "${ipaddress}/api/register";//设置注册信息
  static final ForgetCode = "${ipaddress}/api/forget/password";//重置密码
  static final SetCode = "${ipaddress}/api/reset/emailormobile/";//提交手机号`邮箱地址
}

class Constants{
  static const CircleAvatarRadius = 26.0;
  static const IconFontFamily =  "appIconFont";
  static final  ScreenHeight = window.physicalSize.height.toInt();
  static final  ScreenWidth = window.physicalSize.width.toInt();
  static final  HeroAvater  = 'avater';
  static final  HeroOtherAvater  = 'Otheravater';
  static final  HeroUsername  = 'uvater';
  static final  HeroUserRealname  = 'uvatera';
  static final Usernamekey  =  'Usernamekey';
  static final UsernameFontSize = 18.0;
  static final UserRealnameFontSize = 15.0;
  static final Shared_Token = 'Shared_Token';
  static final Shared_ResToken = 'Shared_ResToken';
  static final Shared_Username = 'Shared_username';
  static final Shared_Name = 'Shared_name';
  static final Shared_Avatar = 'Shared_avatar';
  static final Shared_ReailName = 'Shared_reailname';
  static final Shared_Image= 'Shared_image';
  static final Shared_Email= 'Shared_email';
  static final Shared_Article= 'Shared_article';
  static final Shared_Mobile= 'Shared_Mobile';
  static final Shared_Id= 'Shared_id';
  static final Shared_Following= 'Shared_following';
  static final Shared_Followers= 'Shared_followers';
  static final IconSize = 40.0;

}