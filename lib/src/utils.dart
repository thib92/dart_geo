enum Direction { bottom, top, left, right }

extension DirectionExt on Direction {
  Direction opposite() {
    if (this == Direction.bottom) {
      return Direction.top;
    }

    if (this == Direction.top) {
      return Direction.bottom;
    }

    if (this == Direction.left) {
      return Direction.right;
    }

    return Direction.left;
  }
}

enum Parity { even, odd }

class LatLong {
  double lat;
  double long;

  LatLong(this.lat, this.long);
}

class Coverage {
  final Set<String> hashes;
  final double ratio;

  Coverage(this.hashes, this.ratio);
}
