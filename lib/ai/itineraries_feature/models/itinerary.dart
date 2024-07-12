import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:tripedia/config.dart';

class Itinerary {
  List<DayPlan> dayPlans = [];
  String place = '';
  String name = '';
  String startDate = '';
  String endDate = '';
  List<String> tags = [];
  String heroUrl = '';
  String placeRef = '';

  Itinerary(this.dayPlans, this.place, this.name, this.startDate, this.endDate,
      this.tags, this.heroUrl, this.placeRef);

  @override
  String toString() {
    return '''
      place: $place,
      name: $name,
      startDate: $startDate,
      endDate: $endDate,
      tags: ${tags.toString()},
      heroUrl: $heroUrl,
      placeRef: $placeRef
    ''';
  }
}

class DayPlan {
  int dayNum;
  String date;
  List<Activity> planForDay;

  DayPlan({required this.dayNum, required this.date, required this.planForDay});

  static DayPlan fromJson(Map<String, dynamic> jsonMap) {
    int localDayNum;
    String localDate;
    List<dynamic> localPlan;

    {
      'day': localDayNum,
      'date': localDate,
      'planForDay': localPlan,
    } = jsonMap;

    return DayPlan(
      dayNum: localDayNum,
      date: localDate,
      planForDay: List<Activity>.from(
        localPlan.map(
          (activity) => Activity.fromJson(activity),
        ),
      ),
    );
  }
}

class Activity {
  String ref = '';
  String title = '';
  String description = '';
  String imageUrl = '';

  Activity(
      {required this.ref,
      required this.title,
      required this.description,
      required this.imageUrl});

  static Activity fromJson(Map<String, dynamic> jsonMap) {
    String localRef, localTitle, localDescription, localImageUrl;

    {
      'activityRef': localRef,
      'activityTitle': localTitle,
      'activityDesc': localDescription,
      'imgUrl': localImageUrl
    } = jsonMap;

    return Activity(
        ref: localRef,
        title: localTitle,
        description: localDescription,
        imageUrl: localImageUrl);
  }
}

class ItineraryClient {
  Future<List<Itinerary>> loadItinerariesFromServer(String query,
      {List<String>? images}) async {
    var endpoint = Uri.https(
      // TODO(@nohe427): Use env vars to set this. ==> see config.dart
      backendEndpoint,
      '/itineraryGenerator2',
    );

    var jsonBody = jsonEncode(
      {
        'data': {
          'request': query,
          if (images != null) 'images': images,
        },
      },
    );

    try {
      var response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      List<Itinerary> allItineraries = parseItineraries(response.body);

      return allItineraries;
    } catch (e) {
      debugPrint("Couldn't get itineraries.");
      throw ("Couldn't get itineraries.");
    }
  }

  List<Itinerary> parseItineraries(String jsonStr) {
    try {
      final jsonData = jsonDecode(jsonStr);
      final itineraries = <Itinerary>[];

      final itineraryList = jsonData['result']['itineraries'];
      for (final itineraryData in itineraryList) {
        final days = <DayPlan>[];
        for (final dayData in itineraryData['itinerary']) {
          //debugPrint(dayData);
          final event = DayPlan.fromJson(dayData);
          days.add(event);
        }

        debugPrint(itineraryData['itineraryImageUrl']);

        final itinerary = Itinerary(
          days,
          itineraryData['place'] as String,
          itineraryData['itineraryName'] as String,
          itineraryData['startDate'] as String,
          itineraryData['endDate'] as String,
          List<String>.from(itineraryData['tags'] as List),
          itineraryData['itineraryImageUrl'] as String,
          itineraryData['placeRef'] as String,
        );
        itineraries.add(itinerary);
      }

      return itineraries;
    } catch (e) {
      debugPrint('There was an error parsing the response:\n$jsonStr');
      throw ('There was an error parsing the response');
    }
  }
}

void main() async {
  List<Itinerary> itineraries = await ItineraryClient()
      .loadItinerariesFromServer(
          'I want a vacation at the beach with beautiful views and good food');

  debugPrint(itineraries.toString());
}
