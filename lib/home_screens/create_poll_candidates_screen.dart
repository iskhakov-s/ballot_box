import 'package:ballot_box/home_screens/create_poll_confirm_screen.dart';
import 'package:ballot_box/popular_vote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../poll_model.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key}) : super(key: key);

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final titleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final currentDateTime = DateTime.now();
  DateTime pollDateTime = DateTime.now();

  // List of 10 controllers for the candidates
  int numCandidates = 2;
  final candidateControllers =
      List<TextEditingController>.generate(10, (_) => TextEditingController());

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    for (final c in candidateControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleField = TextFormContainer(
      controller: titleController,
      labelText: "Title",
      validator: (val) {
        if (val!.isEmpty) {
          return 'Please enter a title';
        }
        if (val.length < 3) {
          return 'Title must be at least 3 characters long';
        }
        return null;
      },
    );

    // List of FormFields for the candidates with adjustable length
    final candidateFields = List<Widget>.generate(
      numCandidates,
      (index) => TextFormContainer(
        controller: candidateControllers[index],
        labelText: "Candidate ${index + 1}",
        validator: (val) {
          if (val!.isEmpty) {
            return 'Please enter a candidate';
          }
          String currCandidateName = val.trim();
          for (var i = 0; i < index; i++) {
            String candidateName = candidateControllers[i].text.trim();
            if (currCandidateName == candidateName) {
              return "Name is duplicate of candidate ${i + 1}";
            }
          }
          return null;
        },
      ),
    );

    // button to decrease the number of candidates by 1, down to 2
    final removeButton = WidgetContainer(
      child: ElevatedButton(
        child: const Icon(Icons.remove),
        onPressed: () {
          setState(() {
            if (numCandidates > 2) {
              numCandidates--;
            } else {
              toast("You may not have fewer than 2 candidates");
            }
          });
        },
      ),
    );

    // button to increase the number of candidates by 1, up to 10
    final addButton = WidgetContainer(
      child: ElevatedButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            if (numCandidates < 10) {
              numCandidates++;
            } else {
              toast("You may not have more than 10 candidates");
            }
          });
        },
      ),
    );

    // button displays date/time and allows user to set date/time
    final dateTimeButton = WidgetContainer(
      child: ElevatedButton(
        // substring is used to remove seconds/milliseconds from the timestamp
        child: Text(pollDateTime.toString().substring(0, 16)),
        onPressed: () async {
          final dt = await pickDateTime();
          if (dt != null) {
            setState(
              () {
                pollDateTime = dt;
              },
            );
          }
        },
      ),
    );

    // button to transition to next screen
    final nextButton = WidgetContainer(
      child: ElevatedButton(
        child: const Text('Continue'),
        onPressed: () {
          confirmBallot();
        },
      ),
    );

    return ListViewScaffold(
      title: "Create a Poll",
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              titleField,
              // unpacks the candidates,
              // since the number of candidates is mutable
              ...candidateFields,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  removeButton,
                  addButton,
                ],
              ),
              const SizedBox(height: 30),
              const Text("Select when the poll should close:"),
              dateTimeButton,
              const SizedBox(height: 20),
              nextButton,
            ],
          ),
        )
      ],
    );
  }

  Future<DateTime?> pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: pollDateTime,
      firstDate: currentDateTime,
      lastDate: DateTime(2100),
    );
    if (date == null) {
      return null;
    }

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(pollDateTime),
    );
    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    return null;
  }

  void confirmBallot() async {
    if (_formKey.currentState!.validate()) {
      // Confirms that time set for the poll is in the future
      // TODO: undo presentation mode
      // if (pollDateTime.millisecondsSinceEpoch <
      //     (currentDateTime.millisecondsSinceEpoch + 1000 * 60 * 30)) {
      //   toast("Poll end must be at least half an hour in the future");
      //   return;
      // } 
      if (pollDateTime.millisecondsSinceEpoch <
          currentDateTime.millisecondsSinceEpoch) {
        toast("Poll end must be in the future");
        return;
      }

      // gets the user data from firebase auth
      // makes sure that the data is retrieved before proceeding
      FirebaseAuth.instance.authStateChanges().listen(
        (User? user) async {
          if (user != null) {
            // new poll object
            PollModel poll = PollModel(
              uid: user.uid,
              title: titleController.text.trim(),
              candidates: List<String>.generate(numCandidates,
                  (index) => candidateControllers[index].text.trim()),
              numCandidates: numCandidates,
              msSinceEpoch: pollDateTime.millisecondsSinceEpoch,
            );

            // votemodel object to store votes
            PopularVoteModel pvm = PopularVoteModel(
              votesPerCandidate:
                  List<int>.generate(numCandidates, (index) => 0),
            );

            FirebaseFirestore db = FirebaseFirestore.instance;
            DocumentReference docref =
                await db.collection("polls").add(poll.toMap());

            db.collection("votes").doc(docref.id).set(pvm.toMap());

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmCreatePollScreen(id: docref.id),
              ),
              (route) => false,
            );
          } else {
            throw Exception('User must be signed in');
          }
        },
      );
    }
  }
}
