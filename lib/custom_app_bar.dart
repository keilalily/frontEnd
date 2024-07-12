import 'package:flutter/material.dart';
import 'package:frontend/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final VoidCallback? onHomePressed; // Nullable callback

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.onHomePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleHomePressed(BuildContext context) {
    if (onHomePressed != null) {
      onHomePressed!(); // Invoke the callback if provided
    } else {
      // Provide default behavior if no callback is provided
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to go home?"),
            actions: <Widget>[
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2B2E4A),
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white, // Set icon color to white
            ),
            onPressed: () => _handleHomePressed(context), // Handle home button press
          ),
          Flexible(
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                titleText,
                style: const TextStyle(
                  color: Colors.white, // Set text color to white
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: kToolbarHeight), // Adjust as needed for spacing
        ],
      ),
      centerTitle: false,
    );
  }
}
