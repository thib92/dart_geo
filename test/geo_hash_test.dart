import 'package:dart_geo/src/geo_hash.dart';
import 'package:dart_geo/src/utils.dart';
import 'package:test/test.dart';

double HARTFORD_LON = -72.727175;
double HARTFORD_LAT = 41.842967;
double SCHENECTADY_LON = -73.950691;
double SCHENECTADY_LAT = 42.819581;
double PRECISION = 0.000000001;
int I_LEFT = 0;
int I_RIGHT = 1;
int I_TOP = 2;
int I_BOTTOM = 3;
int I_LEFT_TOP = 4;
int I_LEFT_BOT = 5;
int I_RIGHT_TOP = 6;
int I_RIGHT_BOT = 7;

void main() {
  group('adjacentHash', () {
    test('adjacentHash bottom', () {
      expect('u0zz', equals(GeoHash.adjacentHash('u1pb', Direction.bottom)));
    });

    test('adjacentHash top', () {
      expect('u1pc', equals(GeoHash.adjacentHash('u1pb', Direction.top)));
    });

    test('adjacentHash left', () {
      expect('u1p8', equals(GeoHash.adjacentHash('u1pb', Direction.left)));
    });

    test('adjacentHash right', () {
      expect('u300', equals(GeoHash.adjacentHash('u1pb', Direction.right)));
    });
  });

  group('neighbourHashes', () {
    test('expectedNeighbours', () {
      var center = "dqcjqc";
      var expectedNeighbours = <String>[
        'dqcjqf',
        'dqcjqb',
        'dqcjr1',
        'dqcjq9',
        'dqcjqd',
        'dqcjr4',
        'dqcjr0',
        'dqcjq8'
      ];
      var neighbours = GeoHash.neighbours(center);
      expect(expectedNeighbours, containsAll(neighbours));
    });
  });
}
