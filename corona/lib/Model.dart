import 'dart:convert';
class TotalCount {

}
class Country {
  final int id;
  final String country;
  final String state;
  final int cases;
  final int recovered;
  final int death;

  Country({
    this.id,
    this.country,
    this.state,
    this.cases,
    this.recovered,
    this.death,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: json["ID"],
    country: json["Country"],
    state: json["State"],
    cases: json["Cases"],
    recovered: json["Recovered"],
    death: json["Death"],
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "Country": country,
    "State": state,
    "Cases": cases,
    "Recovered": recovered,
    "Death": death,
  };
}