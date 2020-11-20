class AppInfoModel {
  String id;
  String name;
  String version;
  String size;
  String path;
  String description;
  int latest;
  List<int> createTime;

  AppInfoModel(
      {this.id,
        this.name,
        this.version,
        this.size,
        this.path,
        this.description,
        this.latest,
        this.createTime});

  AppInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    version = json['version'];
    size = json['size'];
    path = json['path'];
    description = json['description'];
    latest = json['latest'];
    createTime = json['createTime'].cast<int>();
  }


  @override
  String toString() {
    return 'AppInfoModel{id: $id, name: $name, version: $version, size: $size, path: $path, description: $description, latest: $latest, createTime: $createTime}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['version'] = this.version;
    data['size'] = this.size;
    data['path'] = this.path;
    data['description'] = this.description;
    data['latest'] = this.latest;
    data['createTime'] = this.createTime;
    return data;
  }
}