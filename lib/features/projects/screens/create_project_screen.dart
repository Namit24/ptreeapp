import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateProjectScreen extends ConsumerWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: const Center(
        child: Text('Create Project Screen - Coming Soon'),
      ),
    );
  }
}
