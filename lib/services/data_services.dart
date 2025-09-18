import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';


class Profile {
  final String name;
  final String title;
  final int experience;
  final String location;
  final String about;
  final String avatar;
  final Map<String, String> links;
  Profile({required this.name, required this.title, required this.experience, required this.location, required this.about, required this.avatar, required this.links});
  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
    name: m['name'],
    title: m['title'],
    experience: m['experience'],
    location: m['location'],
    about: m['about'],
    avatar: m['avatar'],
    links: Map<String, String>.from(m['links'] ?? {}),
  );
}


class Skill { final String name; final int level; Skill(this.name, this.level); }
class Experience { final String company, role, from, to, summary; final List<String> highlights; Experience(this.company, this.role, this.from, this.to, this.summary, this.highlights); }
class Project { final String name, desc, image, link; final List<String> tags; Project(this.name, this.desc, this.tags, this.image, this.link); }


final profileProvider = FutureProvider<Profile>((ref) async {
  final s = await rootBundle.loadString('assets/profile.json');
  return Profile.fromMap(json.decode(s));
});


final skillsProvider = FutureProvider<List<Skill>>((ref) async {
  final s = await rootBundle.loadString('assets/skills.json');
  final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
  return list.map((e) => Skill(e['name'], e['level'])).toList();
});


final experienceProvider = FutureProvider<List<Experience>>((ref) async {
  final s = await rootBundle.loadString('assets/experience.json');
  final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
  return list
      .map((e) => Experience(
    e['company'], e['role'], e['from'], e['to'], e['summary'], (e['highlights'] as List).cast<String>(),
  ))
      .toList();
});


final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final s = await rootBundle.loadString('assets/project.json');
  final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
  return list
      .map((e) => Project(
    e['name'], e['desc'], (e['tags'] as List).cast<String>(), e['image'], e['link'],
  ))
      .toList();
});