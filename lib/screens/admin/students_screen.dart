import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock öğrenci listesi
    final students = List.generate(
      20,
      (index) => {
        'name': 'Öğrenci ${index + 1}',
        'email': 'ogrenci${index + 1}@etisan.com',
        'studentNo': '2020${12345 + index}',
        'balance': (100 + index * 10).toDouble(),
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenciler'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryOrange.withOpacity(0.2),
                child: Text(
                  student['name'].toString()[0],
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(student['name'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['email'] as String),
                  Text(
                    'No: ${student['studentNo']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Text(
                '₺${(student['balance'] as double).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

