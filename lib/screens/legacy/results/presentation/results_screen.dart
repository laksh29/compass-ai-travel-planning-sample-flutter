import 'package:go_router/go_router.dart';

import '../../common/themes/colors.dart';
import '../../results/presentation/result_card.dart';
import '../../results/presentation/results_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../activities/activity.dart';
import '../../../../utilties.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print(context.read<TravelPlan>().query);

    return Scaffold(
      body: Consumer<ResultsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.loading) {
            return const CircularProgressIndicator();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomScrollView(
              slivers: [
                _Search(viewModel: viewModel),
                _Grid(viewModel: viewModel),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.viewModel,
  });

  final ResultsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    var isSmall = MediaQuery.sizeOf(context).width < 800;
    var childAspectRatio = isSmall ? 182/222 : 1.0;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ResultCard(isSmall: isSmall,
            key: ValueKey(viewModel.destinations[index].ref),
            destination: viewModel.destinations[index],
          );
        },
        childCount: viewModel.destinations.length,
      ),
    );
  }
}

class _Search extends StatelessWidget {
  const _Search({
    required this.viewModel,
  });

  final ResultsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    var startDate =
        prettyDate(context.read<TravelPlan>().query!.dates.start.toString());
    var endDate =
        prettyDate(context.read<TravelPlan>().query!.dates.end.toString());
    var numPeople = context.read<TravelPlan>().query!.numPeople;
    print(MediaQuery.of(context).size.width);
    var isLarge = MediaQuery.of(context).size.width > 1024;
    var textStyle = isLarge ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.titleSmall;

    return SliverToBoxAdapter(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 60, 0, 24),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primaryFixedDim,
            ),
            onPressed: () {
              context.read<TravelPlan>().clearQuery();
              context.pop();
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 24),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      '${viewModel.filters} • $startDate – $endDate • $numPeople ${numPeople == 1 ? 'person' : 'people'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:textStyle?.fontSize,
                        fontWeight: FontWeight.w400,
                        height: 0,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60, bottom: 24),
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
          ),
        )
      ],
    ));
  }
}
