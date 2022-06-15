import 'package:ballot_box/constants.dart';
import 'package:ballot_box/home_screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmCreatePollScreen extends StatelessWidget {
  final String id;
  const ConfirmCreatePollScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListViewScaffold(
      title: "Confirm Poll",
      children: <Widget>[
        const Center(
          child: WidgetContainer(
            child: Text(
                "Share this code with those who you want to vote in your poll:"),
          ),
        ),
        Center(child: WidgetContainer(child: Text(id))),
        WidgetContainer(
          child: ElevatedButton(
            child: const Text("Copy"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: id)).then((_) {
                toast("Copied to clipboard");
              });
            },
          ),
        ),
        WidgetContainer(
          child: ElevatedButton(
            child: const Text("Return to Home"),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}
