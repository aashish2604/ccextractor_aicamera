import 'dart:math';

double smoothZoomLevel(List<double> zoomLevels) {
  if (zoomLevels.isEmpty) {
    return 1.0;
  }

  List<double> sortedZoomLevels = List.from(zoomLevels)..sort();

  // CFor median zoom level
  int mid = sortedZoomLevels.length ~/ 2;
  double medianZoomLevel = sortedZoomLevels[mid];

  // For standard deviation zoom level
  double sumOfSquares = 0.0;
  for (double level in sortedZoomLevels) {
    sumOfSquares += (level - medianZoomLevel) * (level - medianZoomLevel);
  }
  double variance = sumOfSquares / sortedZoomLevels.length;
  double stdDev = sqrt(variance);

  // Using median zoom if standard deviation is too high
  if (stdDev > 0.1) {
    return medianZoomLevel;
  }

  // For weighted average of the zoom levels
  double sumOfWeights = 0.0;
  double sumOfValues = 0.0;
  for (double level in sortedZoomLevels) {
    double weight =
        1.0 / (1.0 + (level - medianZoomLevel) * (level - medianZoomLevel));
    sumOfWeights += weight;
    sumOfValues += weight * level;
  }
  double weightedAverage = sumOfValues / sumOfWeights;

  return weightedAverage;
}
