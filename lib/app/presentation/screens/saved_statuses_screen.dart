import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/presentation/components/status_grid.dart';
import 'package:status_saver/app/presentation/components/theme_icon.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:status_saver/core/utils/app_assets.dart';

class SavedStatusesScreen extends StatelessWidget {
  const SavedStatusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusViewModel>(builder: (context, viewModel, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Statuses'),
          actions: [
            ThemeIcon(),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        svgAsset(AppSvgs.image),
                        SizedBox(width: 10),
                        Text('Images',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        svgAsset(AppSvgs.video),
                        SizedBox(width: 10),
                        Text('Videos',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                ],
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                indicatorColor: Theme.of(context).primaryColor,
              ),
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
