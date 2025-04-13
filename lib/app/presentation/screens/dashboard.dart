import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/presentation/components/bottom_nav_item.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusViewModel>(builder: (context, viewModel, child) {
      return Scaffold(
        bottomNavigationBar: Container(
          height: 70,
          constraints: BoxConstraints(maxHeight: 70),
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).primaryColor),
              ),
              // color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...viewModel.bottomNavItems
                  .asMap()
                  .entries
                  .map((entry) => GestureDetector(
                        onTap: () => viewModel.setActiveIndex(entry.key),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: BottomNavItem(
                            item: entry.value,
                            isActive: viewModel.activeIndex == entry.key,
                          ),
                        ),
                      ))
            ],
          ),
        ),
        body: viewModel.bottomNavItems[viewModel.activeIndex].screen,
      );
    });
  }
}
