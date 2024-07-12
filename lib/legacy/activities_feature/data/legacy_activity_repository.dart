import 'package:tripedia/legacy/activities_feature/models/activity.dart';

import '../../common/utils/result.dart';

/// Data source with all possible destinations
abstract class LegacyActivityRepository {
  /// Get complete list of destinations
  Future<Result<List<LegacyActivity>>> getActivities();
}
