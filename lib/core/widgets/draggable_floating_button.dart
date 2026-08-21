import 'package:flutter/material.dart';

class DraggableFloatingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Offset initialOffset;

  const DraggableFloatingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.initialOffset = const Offset(30, 80),
  });

  @override
  State<DraggableFloatingButton> createState() =>
      _DraggableFloatingButtonState();
}

class _DraggableFloatingButtonState extends State<DraggableFloatingButton> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = widget.initialOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      bottom: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              position.dx + details.delta.dx,
              position.dy - details.delta.dy,
            );
          });
        },
        onTap: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}
