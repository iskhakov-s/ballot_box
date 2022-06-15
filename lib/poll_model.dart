// PollModel stores all of the nonchanging aspects about a poll
class PollModel {
  String? uid;
  String? title;
  List<String>? candidates;
  int? numCandidates;
  int? msSinceEpoch;
  List<String>? uidOfVoters = [];

  PollModel({
    this.uid,
    this.title,
    this.candidates,
    this.numCandidates,
    this.msSinceEpoch,
    this.uidOfVoters,
  });

  // data from server
  factory PollModel.fromMap(map) {
    return PollModel(
      uid: map['uid'],
      title: map['title'],
      candidates: List.from(map['candidates']),
      numCandidates: map['numCandidates'],
      msSinceEpoch: map['msSinceEpoch'],
      // TODO: instead of null checking every time,
      // make list contain some default value, non empty
      uidOfVoters: List.from(map['uidOfVoters'] ?? []),
    );
  }

  // data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'candidates': candidates,
      'numCandidates': numCandidates,
      'msSinceEpoch': msSinceEpoch,
      'uidOfVoters': uidOfVoters,
    };
  }
}
