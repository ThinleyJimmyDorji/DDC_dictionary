class DzoSearchResponse {
  int id;
  String keyword;
  String pos;
  String entry;
  String definition;

  DzoSearchResponse(
      {this.id, this.pos, this.keyword, this.entry, this.definition});

  // Create a DzoSearchResponse from JSON data
  factory DzoSearchResponse.fromJson(Map<String, dynamic> json) =>
      new DzoSearchResponse(
          id: json["id"],
          keyword: json["keyword"],
          pos: json["pos"],
          entry: json["entry"],
          definition: json["definition"]);

  // Convert our DzoSearchResponse to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "keyword": keyword,
        "pos": pos,
        "entry": entry,
        "definition": definition
      };
}
