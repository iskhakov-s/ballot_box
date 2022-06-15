import 'package:ballot_box/authentication_screens/startup_screen.dart';
import 'package:ballot_box/home_screens/vote_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../poll_model.dart';
import '../user_model.dart';

class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final _formKey = GlobalKey<FormState>();

  final idController = TextEditingController();

  List<Widget> ballotInfo = <Widget>[];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idField = TextFormContainer(
      controller: idController,
      labelText: "Ballot ID",
      textInputAction: TextInputAction.done,
      validator: (val) {
        if (val!.isEmpty) {
          return "Please enter the ballot ID";
        }
        return null;
      },
      suffixIcon: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () async {
          // initiates the text based on the poll info
          // or resets the ballotInfo to empty
          var info = await pollSearch();
          setState(() {
            if (info == null) {
              ballotInfo = <Widget>[];
            } else {
              _setBallotInfo(info[0], info[1], info[2]);
            }
          });
        },
      ),
    );

    final signOutButton = WidgetContainer(
        child: ElevatedButton(
      child: const Text("Sign Out"),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartupScreen()),
          (route) => false,
        );
      },
    ));

    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                signOutButton,
                idField,
                ...ballotInfo,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>?> pollSearch() async {
    List returnList = <dynamic>[];
    if (_formKey.currentState!.validate()) {
      String ballotID = idController.text;
      returnList.add(ballotID);
      toast("Searching for ballot ID: $ballotID");

      // get the poll data from firestore
      FirebaseFirestore db = FirebaseFirestore.instance;
      var pollSnapshot = await db.collection("polls").doc(ballotID).get();

      if (pollSnapshot.exists) {
        toast("Found ballot ID: $ballotID");
        PollModel? pollInfo = PollModel.fromMap(pollSnapshot.data());
        returnList.add(pollInfo);

        // then get the user data from firestore
        var userSnapshot = await db.collection("users").doc(pollInfo.uid).get();
        UserModel userInfo = UserModel.fromMap(userSnapshot.data());
        returnList.add(userInfo);

        // returns the pollinfo and user data for display
        return [ballotID, pollInfo, userInfo];
      } else {
        toast("Ballot ID not found");
      }
    }
    return null;
  }

  void _setBallotInfo(String ballotID, PollModel pollInfo, UserModel userInfo) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(pollInfo.msSinceEpoch!);
    ballotInfo = <Widget>[
      const SizedBox(height: 20),
      Text("Ballot ID: $ballotID"),
      Text("Title: ${pollInfo.title}"),
      Text("Poll Owner: ${userInfo.username}"),
      Text("Poll Owner Email: ${userInfo.email}"),
      Text("Poll closes: ${dt.toString().substring(0, 16)}"),
      const SizedBox(height: 10),
      WidgetContainer(
        child: ElevatedButton(
          child: const Text("View Poll"),
          onPressed: () async {
            // makes sure that voting is within proper time frame
            if (pollInfo.msSinceEpoch! <
                DateTime.now().millisecondsSinceEpoch) {
              toast("Poll is closed");

              // TODO: push results to firestore
              // show results
              FirebaseFirestore db = FirebaseFirestore.instance;
              var snapshot = await db.collection("votes").doc(ballotID).get();
              var votesPerCandidate =
                  List.from(snapshot.data()!["votesPerCandidate"]);
              // TODO: handle ties, or winners from different types of voting
              // TODO: find popular vote winner in a better way
              // TODO: move this to a separate function, probly in PopularVoteModel
              int max = 0;
              int idx = 0;
              for (int i = 0; i < pollInfo.numCandidates!; i++) {
                if (votesPerCandidate[i] > max) {
                  max = votesPerCandidate[i];
                  idx = i;
                }
              }
              var snapshot2 = await db.collection("polls").doc(ballotID).get();
              var candidates = List.from(snapshot2.data()!["candidates"]);
              String winner = candidates[idx];
              snackbar(context, "Winner: $winner");
              return;
            }

            // makes sure that the voter is not voting multiple times
            FirebaseFirestore db = FirebaseFirestore.instance;
            FirebaseAuth.instance.authStateChanges().listen((user) async {
              if (user == null) {
                return;
              }
              var snapshot = await db.collection("polls").doc(ballotID).get();

              // TODO: this is a hacky way to get the voters' UID
              // the entire list of voter ids is copied locally
              // find better way to do this
              
              var uidOfVoters =
                  List.from(snapshot.data()!["uidOfVoters"] ?? []);
              // TODO: undo presentation mode
              // if (user.uid == userInfo.uid) {
              //   toast("You cannot vote in your own poll");
              //   return;
              // }
              if (uidOfVoters.contains(user.uid)) {
                toast("You have already voted on this poll");
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return PopularVoteScreen(
                    ballotID: ballotID,
                    pollInfo: pollInfo,
                    userInfo: userInfo,
                  );
                }),
              );
            });
          },
        ),
      ),
    ];
  }
}
