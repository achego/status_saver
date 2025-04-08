import 'package:flutter/material.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.item,
    this.isActive = false,
  });

  final BottomNavItemModel item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 24,
          child: FittedBox(
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                child: SizedBox(
                    key: Key(isActive ? item.activeIcons : item.icon),
                    child: svgAsset(isActive ? item.activeIcons : item.icon,
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).iconTheme.color))),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          margin: EdgeInsets.only(top: isActive ? 5 : 0),
          height: 5,
          width: isActive ? 10 : 0,
          decoration: BoxDecoration(
            color:
                isActive ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
        )
      ],
    );
  }
}
