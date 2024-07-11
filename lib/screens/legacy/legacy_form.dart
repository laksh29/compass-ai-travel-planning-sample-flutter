// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tripedia/utilties.dart';

import '../components/thumbnail.dart';
import 'activities/activity.dart';
import './results/presentation/results_viewmodel.dart';

class LegacyFormScreen extends StatefulWidget {
  const LegacyFormScreen({super.key});

  @override
  State<LegacyFormScreen> createState() => _LegacyFormScreenState();
}

class _LegacyFormScreenState extends State<LegacyFormScreen> {
  int numPeople = 1;
  String? selectedLocation;
  DateTimeRange? tripDateRange;

  void decreaseNumPeople() {
    setState(() {
      numPeople -= 1;
    });
  }

  void increaseNumPeople() {
    setState(() {
      numPeople += 1;
    });
  }

  void selectLocation(String location) {
    setState(() {
      selectedLocation = location;
    });
  }

  void setQuery() {
    var location = selectedLocation;
    var date = tripDateRange;

    if (location == null || date == null) return;

    context.read<TravelPlan>().setQuery(
          TravelQuery(location: location, dates: date, numPeople: numPeople),
        );

    context.read<ResultsViewModel>().search(continent: location);

    context.push('/legacy/results');
  }

  Widget _buildMoreTallThanWideScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                style: ButtonStyle(
                  side: WidgetStatePropertyAll(
                    BorderSide(color: Colors.grey[300]!),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                onPressed: () => context.go('/'),
                icon: const Icon(
                  Icons.home_outlined,
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
        child: Column(
          children: [
            Expanded(
              child: Column(children: [
                SizedBox(
                    height: 120,
                    child: LocationPicker(
                      height: 120,
                      width: 120,
                      selected: selectedLocation,
                      onSelect: selectLocation,
                    )),
                const SizedBox.square(
                  dimension: 24,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: _buildWhenRow(context),
                ),
                const SizedBox.square(
                  dimension: 16,
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: _buildWhoRow(context),
                ),
              ]),
            ),
            Row(children: [
              Expanded(
                child: TextButton(
                  style: ButtonStyle(
                    shadowColor: WidgetStatePropertyAll(
                        Theme
                            .of(context)
                            .colorScheme
                            .primaryContainer),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.black,
                    ),
                  ),
                  onPressed: setQuery,
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildWhenRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'When',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextButton(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                  vertical: 0, horizontal: 8),
            ),
          ),
          onPressed: () async {
            DateTimeRange? tripDates = await showDialog(
              context: context,
              builder: (context) {
                return Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.black,
                      dynamicSchemeVariant:
                      DynamicSchemeVariant.monochrome,
                    ),
                  ),
                  child: DateRangePickerDialog(
                    initialDateRange: tripDateRange,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.parse('2028-01-01'),
                  ),
                );
              },
            );

            if (tripDates == null) return;

            setState(() {
              tripDateRange = tripDates;
            });
          },
          child: tripDateRange != null
              ? Text(
              '${shortenedDate(tripDateRange!.start
                  .toString())} – ${shortenedDate(
                  tripDateRange!.end.toString().toString())}')
              : const Text('Add Dates'),
        ),
      ],
    );
  }

  Widget _buildWhoRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Who',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        QuantityInput(
          value: numPeople,
          onDecrease: decreaseNumPeople,
          onIncrease: increaseNumPeople,
          min: 1,
        ),
      ],
    );
  }

  Widget _buildMoreWideThanTallScreen(BuildContext context, BoxConstraints constraints) {
    final double halfWidth = constraints.maxWidth * 0.5;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                style: ButtonStyle(
                  side: WidgetStatePropertyAll(
                    BorderSide(color: Colors.grey[300]!),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                onPressed: () => context.go('/'),
                icon: const Icon(
                  Icons.home_outlined,
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            Expanded(
                child: Row(children: [
                  SizedBox(
                      width: halfWidth.toDouble(),
                      child: LocationPickerGrid(
                        width: 400,
                        height: 200,
                        selected: selectedLocation,
                        onSelect: selectLocation,
                      )),
                  const SizedBox.square(
                    dimension: 24,
                  ),
                  Column(children: [
                    Container(
                      width: constraints.maxWidth * 0.45,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: _buildWhenRow(context),
                    ),
                    const SizedBox.square(
                      dimension: 16,
                    ),
                    Container(
                      width: constraints.maxWidth * 0.45,
                      padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: _buildWhoRow(context),
                    ),
                  ]),],)
            ),
            Row(children: [
              Expanded(
                child: TextButton(
                  style: ButtonStyle(
                    shadowColor: WidgetStatePropertyAll(
                        Theme
                            .of(context)
                            .colorScheme
                            .primaryContainer),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.black,
                    ),
                  ),
                  onPressed: setQuery,
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      print(constraints);
      final isMoreTallThanWide = constraints.maxHeight > constraints.maxWidth;
      if (isMoreTallThanWide) {
        return _buildMoreTallThanWideScreen(context);
      } else {
        return _buildMoreWideThanTallScreen(context, constraints);
      }
    });

  }
}

class LocationPicker extends StatefulWidget {
  const LocationPicker(
      {required this.selected, required this.onSelect, super.key, required this.width, required this.height});

  final String? selected;
  final void Function(String) onSelect;
  final width;
  final height;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> with Destinations {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: List.generate(destinations.length, (index) {
        var destination = destinations[index];
        return LocationItem(
          height: widget.height,
          width: widget.width,
          onTap: widget.onSelect,
          fade: (widget.selected == null ||
                  widget.selected == destination['title'])
              ? false
              : true,
          name: destination['title']!,
          image: AssetImage(
            destination['image']!,
          ),
        );
      }),
    );
  }
}

class LocationPickerGrid extends StatefulWidget {
  const LocationPickerGrid(
      {required this.selected, required this.onSelect, super.key, required this.width, required this.height});

  final String? selected;
  final void Function(String) onSelect;
  final int width;
  final int height;

  @override
  State<LocationPickerGrid> createState() => _LocationPickerGridState();
}

mixin Destinations {
  List<Map<String, String>> destinations = [
    {
      'image': 'assets/images/locations/europe.jpeg',
      'title': 'Europe',
    },
    {
      'image': 'assets/images/locations/asia.jpeg',
      'title': 'Asia',
    },
    {
      'image': 'assets/images/locations/south-america.jpeg',
      'title': 'South America',
    },
    {
      'image': 'assets/images/locations/africa.jpeg',
      'title': 'Africa',
    },
    {
      'image': 'assets/images/locations/north-america.jpeg',
      'title': 'North America',
    },
    {
      'image': 'assets/images/locations/oceania.jpeg',
      'title': 'Oceania',
    },
    {
      'image': 'assets/images/locations/australia.jpeg',
      'title': 'Australia',
    },
  ];
}

class _LocationPickerGridState extends State<LocationPickerGrid> with Destinations {

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: 8,
            maxCrossAxisExtent: 300),
        itemBuilder: (context, index) {
          if (index < destinations.length) {
          final destination = destinations[index];
          return LocationItem(
            height: widget.height,
            width: widget.width,
            onTap: widget.onSelect,
            fade: (widget.selected == null ||
                widget.selected == destination['title'])
                ? false
                : true,
            name: destination['title']!,
            image: AssetImage(
              destination['image']!,
            ),
          );
        }});
  }
}

class LocationItem extends StatelessWidget {
  const LocationItem({
    required this.name,
    required this.image,
    required this.onTap,
    this.fade = false,
    required this.width,
    required this.height,
    super.key,
  });

  final String name;
  final ImageProvider image;
  final Function(String) onTap;
  final bool fade;
  final int height;
  final int width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(name),
      child: Thumbnail(
        width: width,
        height: height,
        faded: fade,
        image: image,
        title: name,
      ),
    );
  }
}

class QuantityInput extends StatelessWidget {
  const QuantityInput({
    required this.value,
    required this.onIncrease,
    required this.onDecrease,
    this.min,
    this.max,
    super.key,
  });

  final VoidCallback onDecrease, onIncrease;
  final int value;
  final int? min, max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            int? minValue = min;
            if (minValue != null && value <= minValue) return;

            onDecrease();
          },
          icon: const Icon(
            Icons.remove_circle_outline,
          ),
        ),
        Text(value.toString()),
        IconButton(
          onPressed: onIncrease,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}