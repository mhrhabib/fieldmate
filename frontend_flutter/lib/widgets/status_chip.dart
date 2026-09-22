import 'package:flutter/material.dart';
import '../models/models.dart';

class StatusChip extends StatelessWidget {
  final JobStatus status;
  const StatusChip({super.key, required this.status});

  Color _color(BuildContext context) {
    switch (status) {
      case JobStatus.lead:
        return Colors.blueGrey;
      case JobStatus.scheduled:
        return Colors.indigo;
      case JobStatus.inProgress:
        return Colors.orange;
      case JobStatus.waitingOnPart:
        return Colors.deepOrange;
      case JobStatus.completed:
        return Colors.teal;
      case JobStatus.invoiced:
        return Colors.purple;
      case JobStatus.paid:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
