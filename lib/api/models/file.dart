class FileModel {
  final String username;
  final String filename;
  final int size;
  final DateTime modified;

  FileModel({
    required this.username,
    required this.filename,
    required this.size,
    required this.modified,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      username: json['username'],
      filename: json['filename'],
      size: json['size'],
      modified: DateTime.parse(json['modified']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'filename': filename,
      'size': size,
      'modified': modified.toIso8601String(),
    };
  }
}
