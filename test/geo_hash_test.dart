import 'package:geo_utils/src/geo_hash.dart';
import 'package:geo_utils/src/utils.dart';
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

  group('coverBoundingBox', () {
    test('coverBoundingBox', () {
      var hashes = GeoHash.coverBoundingBox(
              SCHENECTADY_LAT, SCHENECTADY_LON, HARTFORD_LAT, HARTFORD_LON, 4)
          .hashes;

      // check corners are in
      expect(hashes, contains('dre7'));
      expect(hashes, contains('drkq'));
      expect(hashes, contains('drs7'));
      expect(hashes, contains('dr7q'));
      var expected = <String>{
        'dre7',
        'dree',
        'dreg',
        'drs5',
        'drs7',
        'dre6',
        'dred',
        'dref',
        'drs4',
        'drs6',
        'dre3',
        'dre9',
        'drec',
        'drs1',
        'drs3',
        'dre2',
        'dre8',
        'dreb',
        'drs0',
        'drs2',
        'dr7r',
        'dr7x',
        'dr7z',
        'drkp',
        'drkr',
        'dr7q',
        'dr7w',
        'dr7y',
        'drkn',
        'drkq',
      };

      expect(hashes, containsAll(expected));
      expect(hashes.length, equals(expected.length));
    });
  });
}
