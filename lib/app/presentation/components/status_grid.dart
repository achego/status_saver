import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/status_tile.dart';

class StatusGrid extends StatelessWidget {
  final List<Status> statuses;
  final bool isLoading;
  final VoidCallback onRefresh;

  const StatusGrid({
    super.key,
    required this.statuses,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statuses.isEmpty) {
      return Center(
        child: Text(
          'No statuses found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: const EdgeInsets.all(4),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return StatusTile(status: status);
        },
      ),
    );
  }
}
