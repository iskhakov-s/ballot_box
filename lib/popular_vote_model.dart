// the reason the voting collection is separate from the poll collection is that
// i might implement different types of voting in the future so there is no one
// arrangement of document that would allow me to easily access the voting data
class PopularVoteModel {
  String? type = "popular";
  List<int>? votesPerCandidate;

  PopularVoteModel({
    this.votesPerCandidate,
  });

  // data from server
  factory PopularVoteModel.fromMap(map) {
    return PopularVoteModel(
      votesPerCandidate: List.from(map['votesPerCandidate']),
    );
  }

  // data to server
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'votesPerCandidate': votesPerCandidate,
    };
  }
}
