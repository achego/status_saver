import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/status_tile.dart';

class StatusGrid extends StatelessWidget {
  final List<StatusModel> statuses;
  final bool isLoading;
  final VoidCallback onRefresh;

  const StatusGrid({
    super.key,
    required this.statuses,
    required this.isLoading,
    required this.onRefresh,
  });

  bool _isLargeItem(int index) {
    final positionInGroup = index % 4;
    return positionInGroup == 1 || positionInGroup == 2;
  }

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
      backgroundColor: Theme.of(context).primaryColor,
      color: Colors.white,
      onRefresh: () async => onRefresh(),
      child: MasonryGridView.count(
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return StatusTile(
            status: status,
            isLarge: _isLargeItem(index),
          );
        },
      ),
    );
  }
}
