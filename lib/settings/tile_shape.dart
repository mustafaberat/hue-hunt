enum TileShape { square, hexagon, circle }

TileShape tileShapeFromStorage(String? value) {
  return TileShape.values.firstWhere(
    (shape) => shape.name == value,
    orElse: () => TileShape.square,
  );
}
