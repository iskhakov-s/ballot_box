import 'package:ballot_box/constants.dart';
import 'package:ballot_box/home_screens/home_screen.dart';
import 'package:ballot_box/poll_model.dart';
import 'package:ballot_box/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PopularVoteScreen extends StatefulWidget {
  final String ballotID;
  final PollModel pollInfo;
  final UserModel userInfo;

  const PopularVoteScreen({
    Key? key,
    required this.ballotID,
    required this.pollInfo,
    required this.userInfo,
  }) : super(key: key);

  @override
  State<PopularVoteScreen> createState() => _PopularVoteScreenState();
}

class _PopularVoteScreenState extends State<PopularVoteScreen> {
  final _formKey = GlobalKey<FormState>();
  int voteValue = -1;

  @override
  Widget build(BuildContext context) {
    var candidatesDropdownField = WidgetContainer(
      child: DropdownButtonFormField<int>(
        items: [
          for (var i = 0; i < widget.pollInfo.numCandidates!; i++)
            DropdownMenuItem<int>(
              value: i,
              child: Text(widget.pollInfo.candidates![i]),
            ),
        ],
        onChanged: (val) {
          setState(() {
            voteValue = val!;
          });
        },
        validator: (_) {
          if (voteValue == -1) {
            return "Please select a candidate";
          } else {
            return null;
          }
        },
        decoration: const InputDecoration(labelText: "Candidate"),
      ),
    );
    return ListViewScaffold(
      title: widget.pollInfo.title!,
      children: <Widget>[
        Form(
          key: _formKey,
          child: candidatesDropdownField,
        ),
        WidgetContainer(
          child: ElevatedButton(
            child: const Text("Place Vote"),
            onPressed: () {
              placeVote();
            },
          ),
        )
      ],
    );
  }

  void placeVote() async {
    if (_formKey.currentState!.validate()) {
      if (widget.pollInfo.msSinceEpoch! <
          DateTime.now().millisecondsSinceEpoch) {
        snackbar(context, "This poll has expired");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        return;
      }

      FirebaseFirestore db = FirebaseFirestore.instance;
      var snapshot = await db.collection("votes").doc(widget.ballotID).get();
      // TODO: this is probably pretty slow, so the vote list should be replaced with a map
      // copies the list from firestore, increments the appropriate val
      // and writes it back to firestore
      List<dynamic> votesPerCandidate = snapshot.data()!["votesPerCandidate"];
      votesPerCandidate[voteValue]++;
      await db
          .collection("votes")
          .doc(widget.ballotID)
          .update({"votesPerCandidate": votesPerCandidate});

      // check for the currently logged in user
      // adds the user to the list of voters
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          db.collection("polls").doc(widget.ballotID).update(
            {
              "uidOfVoters": FieldValue.arrayUnion([user.uid])
            },
          );
        }
      });

      snackbar(context, "Vote placed!");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }
}
