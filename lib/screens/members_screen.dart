import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MembersScreen extends StatelessWidget {
  // Ganti data ini dengan anggota tim kalian
  final List<Member> members = const [
    Member(
      name: 'Daniel Ridho Abadi', 
      role: '123220064', 
      imgUrl: null,
      instagram: 'daniel_ridho',
      linkedin: 'daniel-ridho-abadi',
      github: 'danielridho',
    ),
    Member(
      name: 'Hadyan Baktiadi', 
      role: '123220090', 
      imgUrl: null,
      instagram: 'hadyan_baktiadi',
      linkedin: 'hadyan-baktiadi',
      github: 'hadyanbaktiadi',
    ),
    Member(
      name: 'Jovano Dion Manuel', 
      role: '123220103', 
      imgUrl: null,
      instagram: 'jovano_dion',
      linkedin: 'jovano-dion-manuel',
      github: 'jovanodion',
    ),
  ];

  const MembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Anggota Tim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header section
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas Kelompok Mobile Programming',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
              ],
            ),
          ),
          
          // Members list
          ...members.map((member) => _buildMemberCard(context, member)).toList(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Member member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                member.imgUrl != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(member.imgUrl!),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                        child: Text(
                          member.name[0],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIM: ${member.role}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  context,
                  'Instagram',
                  Icons.camera_alt,
                  Colors.pink,
                  'https://instagram.com/${member.instagram}',
                ),
                _buildSocialButton(
                  context,
                  'LinkedIn',
                  Icons.work,
                  Colors.blue[800]!,
                  'https://linkedin.com/in/${member.linkedin}',
                ),
                _buildSocialButton(
                  context,
                  'GitHub',
                  Icons.code,
                  Colors.black87,
                  'https://github.com/${member.github}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String url,
  ) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka $label')),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class Member {
  final String name;
  final String role;
  final String? imgUrl;
  final String instagram;
  final String linkedin;
  final String github;

  const Member({
    required this.name,
    required this.role,
    this.imgUrl,
    required this.instagram,
    required this.linkedin,
    required this.github,
  });
}
