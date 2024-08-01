import 'package:flutter/material.dart';

class CustomButtonRow extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CustomButtonRow({super.key, required this.title, required this.options, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              return HoverButton(
                label: option,
                isSelected: selectedIndex == index,
                onSelected: () {
                  onSelected(index);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class HoverButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const HoverButton({super.key, required this.label, required this.isSelected, required this.onSelected});

  @override
  HoverButtonState createState() => HoverButtonState();
}

class HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (hovering) {
        setState(() {
          _isHovered = hovering;
        });
      },
      onTap: widget.onSelected,
      onTapDown: (_) {}, // No need to manage press state here
      onTapCancel: () {}, // No need to manage cancel state here
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.white.withOpacity(1.0) : (_isHovered ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.isSelected ? Colors.black : (_isHovered ? Colors.black : Colors.black.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}