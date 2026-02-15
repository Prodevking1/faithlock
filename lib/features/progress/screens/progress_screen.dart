import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('progress_title'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'progress_yourProgress'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressItem(
              context,
              title: 'progress_dailyGoal'.tr,
              progress: 0.7,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              context,
              title: 'progress_weeklyGoal'.tr,
              progress: 0.5,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              context,
              title: 'progress_monthlyGoal'.tr,
              progress: 0.3,
              color: Colors.orange,
            ),
            const SizedBox(height: 30),
            Text(
              'progress_statistics'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('progress_tasksCompleted'.tr, '24'),
                  _buildStatCard('progress_pendingTasks'.tr, '12'),
                  _buildStatCard('progress_successRate'.tr, '75%'),
                  _buildStatCard('progress_avgCompletionTime'.tr, '3.2h'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context, {
    required String title,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
