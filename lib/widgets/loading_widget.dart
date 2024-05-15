import 'package:flutter/widgets.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    required List<Animation<Offset>> offsetAnimations,
    required Color color,
  })  : _offsetAnimations = offsetAnimations,
        _color = color;

  final List<Animation<Offset>> _offsetAnimations;
  final Color _color;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _offsetAnimations.map((animation) {
        return SlideTransition(
          position: animation,
          child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: _color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
