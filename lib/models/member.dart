class Member {
  final String name;
  final String role;
  final String? imgUrl;

  const Member({
    required this.name,
    required this.role,
    this.imgUrl,
  });
}
