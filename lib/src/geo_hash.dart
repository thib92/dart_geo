import 'dart:collection';
import 'dart:math';

import 'package:geohash/geohash.dart';

import 'package:dart_geo/src/utils.dart';

class GeoHash {
  static const double _PRECISION = 0.000000000001;

  /// The standard practical maximum length for geohashes.
  static const int _MAX_HASH_LENGTH = 12;

  /// Default maximum number of hashes for covering a bounding box.
  static const int _DEFAULT_MAX_HASHES = 12;

  /// Powers of 2 from 32 down to 1.
  static const List<int> _BITS = [16, 8, 4, 2, 1];

  /// The characters used in base 32 representations.
  static const String _BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Utility lookup for neighbouring hashes.
  static final _NEIGHBOURS = _createNeighbours();

  /// Utility lookup for hash borders.
  static final _BORDERS = _createBorders();

  static final List<double> _hashWidths = _createHashWidths();

  static final List<double> _hashHeights = _createHashHeights();

  /// Returns a map to be used in hash border calculations.
  static Map<Direction, Map<Parity, String>> _createBorders() {
    var m = _createDirectionParityMap();

    m[Direction.right][Parity.even] = 'bcfguvyz';
    m[Direction.left][Parity.even] = '0145hjnp';
    m[Direction.top][Parity.even] = 'prxz';
    m[Direction.bottom][Parity.even] = '028b';

    _addOddParities(m);
    return m;
  }

  /// Returns a map to be used in adjacent hash calculations.
  static Map<Direction, Map<Parity, String>> _createNeighbours() {
    var m = _createDirectionParityMap();

    m[Direction.right][Parity.even] = 'bc01fg45238967deuvhjyznpkmstqrwx';
    m[Direction.left][Parity.even] = '238967debc01fg45kmstqrwxuvhjyznp';
    m[Direction.top][Parity.even] = 'p0r21436x8zb9dcf5h7kjnmqesgutwvy';
    m[Direction.bottom][Parity.even] = '14365h7k9dcfesgujnmqp0r2twvyx8zb';

    _addOddParities(m);
    return m;
  }

  /// Create a direction and parity map for use in adjacent hash calculations.
  static Map<Direction, Map<Parity, String>> _createDirectionParityMap() {
    var m = HashMap<Direction, Map<Parity, String>>();

    Direction.values.forEach((direction) {
      m[direction] = HashMap<Parity, String>();
    });

    return m;
  }

  static void _addOddParities(Map<Direction, Map<Parity, String>> m) {
    m[Direction.bottom][Parity.odd] = m[Direction.left][Parity.even];
    m[Direction.top][Parity.odd] = m[Direction.right][Parity.even];
    m[Direction.left][Parity.odd] = m[Direction.bottom][Parity.even];
    m[Direction.right][Parity.odd] = m[Direction.top][Parity.even];
  }

  static List<double> _createHashWidths() {
    var d = List<double>(_MAX_HASH_LENGTH + 1);
    for (var i = 0; i <= _MAX_HASH_LENGTH; i++) {
      d[i] = _calculateWidthDegrees(i);
    }
    return d;
  }

  static List<double> _createHashHeights() {
    var d = List<double>(_MAX_HASH_LENGTH + 1);
    for (var i = 0; i <= _MAX_HASH_LENGTH; i++) {
      d[i] = _calculateHeightDegrees(i);
    }
    return d;
  }

  static double _to180(double d) {
    if (d < 0) {
      return -_to180(d.abs());
    }

    if (d > 180) {
      var n = ((d + 180) / 360.0).floor().round();
      return d - n * 360;
    }

    return d;
  }

  /// Returns the adjacent hash in given [direction].
  static String adjacentHash(String hash, Direction direction) {
    var adjacentHashAtBorder = _adjacentHashAtBorder(hash, direction);

    if (adjacentHashAtBorder != null) {
      return adjacentHashAtBorder;
    }

    var source = hash.toLowerCase();
    var lastChar = source[source.length - 1];
    var parity = (source.length % 2 == 0) ? Parity.even : Parity.odd;
    var base = source.substring(0, source.length - 1);
    if (_BORDERS[direction][parity].contains(lastChar)) {
      base = adjacentHash(base, direction);
    }

    return base + _BASE32[_NEIGHBOURS[direction][parity].indexOf(lastChar)];
  }

  static String _adjacentHashAtBorder(String hash, Direction direction) {
    var centre = Geohash.decode(hash);
    var lat = centre.x, long = centre.y;

    if (direction == Direction.right) {
      if ((long + widthDegrees(hash.length) / 2 - 180).abs() < _PRECISION) {
        return Geohash.encode(lat, -180, codeLength: hash.length);
      }
    }

    if (direction == Direction.left) {
      if ((long - widthDegrees(hash.length) / 2 + 180).abs() < _PRECISION) {
        return Geohash.encode(lat, 180, codeLength: hash.length);
      }
    }

    if (direction == Direction.top) {
      if ((lat + widthDegrees(hash.length) / 2 - 90).abs() < _PRECISION) {
        return Geohash.encode(lat, long + 180, codeLength: hash.length);
      }
    }

    if (direction == Direction.bottom) {
      if ((lat - widthDegrees(hash.length) / 2 + 90).abs() < _PRECISION) {
        return Geohash.encode(lat, long + 180, codeLength: hash.length);
      }
    }

    return null;
  }

  /// Returns width in degrees of all geohashes of length n.
  /// Results are deterministic and cached to increase performance
  /// (might be unnecessary, have not benchmarked).
  static double widthDegrees(int n) {
    if (n > _MAX_HASH_LENGTH) {
      return _calculateWidthDegrees(n);
    } else {
      return _hashWidths[n];
    }
  }

  /// Returns the width in degrees of the region represented by a geohash of length n.
  static double _calculateWidthDegrees(int n) {
    var a = n % 2 == 0 ? -1 : -.5;
    return 180 / pow(2, 2.5 * n + a);
  }

  static double heightDegrees(int n) {
    if (n > _MAX_HASH_LENGTH) {
      return _calculateHeightDegrees(n);
    } else {
      return _hashHeights[n];
    }
  }

  static double _calculateHeightDegrees(int n) {
    var a = n % 2 == 0 ? 0 : -.5;
    return 180 / pow(2, 2.5 * n + a);
  }

  static List<String> neighbours(String hash) {
    var neighbours = <String>[];
    var left = adjacentHash(hash, Direction.left);
    var right = adjacentHash(hash, Direction.right);
    neighbours.addAll([left, right]);
    neighbours.add(adjacentHash(hash, Direction.top));
    neighbours.add(adjacentHash(hash, Direction.bottom));
    neighbours.add(adjacentHash(left, Direction.top));
    neighbours.add(adjacentHash(left, Direction.bottom));
    neighbours.add(adjacentHash(right, Direction.top));
    neighbours.add(adjacentHash(right, Direction.bottom));
    return neighbours;
  }

  static int hashLengthToCoverBoundingBox(double topLeftLat, double topLeftLon,
      double bottomRightLat, double bottomRightLon) {
    var isEven = true;
    var minLat = -90.0, maxLat = 90.0;
    var minLon = -180.0, maxLon = 180.0;

    for (var bits = 0; bits < _MAX_HASH_LENGTH * 5; bits++) {
      if (isEven) {
        var mid = (minLon + maxLon) / 2;
        if (topLeftLon >= mid) {
          if (bottomRightLon < mid) return (bits / 5).truncate();
          minLon = mid;
        } else {
          if (bottomRightLon >= mid) return (bits / 5).truncate();
          maxLon = mid;
        }
      } else {
        var mid = (minLat + maxLat) / 2;
        if (topLeftLat >= mid) {
          if (bottomRightLat < mid) return (bits / 5).truncate();
          minLat = mid;
        } else {
          if (bottomRightLat >= mid) return (bits / 5).truncate();
          maxLat = mid;
        }
      }

      isEven = !isEven;
    }

    return _MAX_HASH_LENGTH;
  }

  static bool hashContains(String hash, double lat, double lon) {
    var centre = Geohash.decode(hash);
    var centreLat = centre.x, centreLong = centre.y;
    return (centreLat - lat).abs() <= heightDegrees(hash.length) / 2 &&
        (_to180(centreLong - lon)).abs() <= widthDegrees(hash.length) / 2;
  }
}
