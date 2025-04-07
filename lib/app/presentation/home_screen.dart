import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/presentation/components/status_grid.dart';
import 'package:status_saver/app/presentation/components/theme_icon.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusViewModel>(builder: (context, viewModel, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Status Saver'),
          actions: [
            ThemeIcon(),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Images'),
                  Tab(text: 'Videos'),
                ],
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                indicatorColor: Theme.of(context).primaryColor,
              ),
              ElevatedButton(
                  onPressed: () => viewModel.showDirectory(),
                  child: Text('Preesss')),
              Expanded(
                child: TabBarView(
                  children: [
                    StatusGrid(
                      statuses: viewModel.imageStatuses,
                      isLoading: viewModel.isLoading,
                      onRefresh: viewModel.refreshStatuses,
                    ),
                    StatusGrid(
                      statuses: viewModel.videoStatuses,
                      isLoading: viewModel.isLoading,
                      onRefresh: viewModel.refreshStatuses,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
