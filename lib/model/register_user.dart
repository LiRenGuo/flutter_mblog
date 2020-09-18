class RegisterUser{
  String name;
  String phone;
  String vcode;
  String agree;
  String password;
  String cpassword;

  RegisterUser({
    this.name, this.phone, this.vcode, this.agree,
    this.password, this.cpassword
  });

  @override
  String toString() {
    return 'RegisterUser{name: $name, phone: $phone, vcode: $vcode, agree: $agree, password: $password, cpassword: $cpassword}';
  }
}
