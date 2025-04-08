import 'package:flutter/material.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/status_grid.dart';
import 'package:status_saver/core/utils/file_utils.dart';

class SavedStatusesScreen extends StatefulWidget {
  const SavedStatusesScreen({super.key});

  @override
  State<SavedStatusesScreen> createState() => _SavedStatusesScreenState();
}

class _SavedStatusesScreenState extends State<SavedStatusesScreen> {
  List<StatusModel> _savedStatuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStatuses();
  }

  Future<void> _loadSavedStatuses() async {
    setState(() => _isLoading = true);

    try {
      final savedFiles = await FileUtils.getSavedStatuses();
      _savedStatuses = savedFiles.map((file) {
        final isVideo = file.path.endsWith('.mp4');
        return StatusModel(
          path: file.path,
          type: isVideo ? StatusType.video : StatusType.image,
          modifiedTime: file.lastModifiedSync(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading saved statuses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Statuses'),
      ),
      body: StatusGrid(
        statuses: _savedStatuses,
        isLoading: _isLoading,
        onRefresh: _loadSavedStatuses,
      ),
    );
  }
}
