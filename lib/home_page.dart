import 'package:flutter/material.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttonData = [
      {
        "icon": Icons.chat,
        "label": "Messages",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatPage()),
          );
        },
      },
      {
        "icon": Icons.mic,
        "label": "Live",
        "onTap": () {
          showSnack(context, "Fonction à venir, Maître.");
        },
      },
      {
        "icon": Icons.public,
        "label": "Espace Virtuel",
        "onTap": () {
          showSnack(context, "Fonction à venir, Maître.");
        },
      },
      {
        "icon": Icons.view_in_ar,
        "label": "AR",
        "onTap": () {
          showSnack(context, "Fonction à venir, Maître.");
        },
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bonjour Maître",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFBB86FC),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 300,
                width: 300,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: buttonData.map((data) {
                    return MenuCircleButton(
                      icon: data['icon'],
                      label: data['label'],
                      onTap: data['onTap'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class MenuCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuCircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Color(0xFFBB86FC), width: 2),
            ),
            child: Icon(icon, size: 36, color: Color(0xFFBB86FC)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBB86FC),
            ),
          ),
        ],
      ),
    );
  }
}
