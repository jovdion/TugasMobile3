import 'package:flutter/material.dart';

class MembersScreen extends StatelessWidget {
  // Ganti data ini dengan anggota tim kalian
  final List<Member> members = const [
    Member(name: 'Daniel Ridho Abadi', role: '123220064', imgUrl: null),
    Member(name: 'Hadyan Baktiadi', role: '123220090', imgUrl: null),
    Member(name: 'Jovano Dion Manuel', role: '123220103', imgUrl: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Anggota')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final m = members[index];
          return ListTile(
            leading: m.imgUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(m.imgUrl!))
                : CircleAvatar(child: Text(m.name[0])),
            title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(m.role),
          );
        },
      ),
    );
  }
}

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
