import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart' as xml;

/// Represents a single muscle path shape extracted from SVG artwork.
class MuscleShape {
  final String id;
  final Path path;

  const MuscleShape({
    required this.id,
    required this.path,
  });
}

/// Represents a parsed body figure SVG model (front or back view).
class BodyFigureModel {
  final Rect viewBoxRect;
  final List<MuscleShape> shapes;

  const BodyFigureModel({
    required this.viewBoxRect,
    required this.shapes,
  });

  /// Convenience size getter.
  Size get viewBoxSize => viewBoxRect.size;

  // PERF: In-memory static cache to avoid re-parsing SVG string across rebuilds
  static final Map<String, BodyFigureModel> _modelCache = {};

  /// Parse an SVG string into a BodyFigureModel with caching.
  factory BodyFigureModel.fromSvgString(String svgContent) {
    if (_modelCache.containsKey(svgContent)) {
      return _modelCache[svgContent]!;
    }

    final document = xml.XmlDocument.parse(svgContent);
    final svgElement = document.findAllElements('svg').firstOrNull;

    Rect viewBoxRect = const Rect.fromLTWH(0, 0, 200, 500);

    if (svgElement != null) {
      final viewBoxAttr = svgElement.getAttribute('viewBox');
      if (viewBoxAttr != null && viewBoxAttr.isNotEmpty) {
        final parts = viewBoxAttr
            .trim()
            .split(RegExp(r'[\s,]+'))
            .map((e) => double.tryParse(e) ?? 0.0)
            .toList();
        if (parts.length >= 4) {
          viewBoxRect = Rect.fromLTWH(parts[0], parts[1], parts[2], parts[3]);
        }
      } else {
        final widthStr = svgElement.getAttribute('width');
        final heightStr = svgElement.getAttribute('height');
        final width = double.tryParse(widthStr ?? '') ?? 200.0;
        final height = double.tryParse(heightStr ?? '') ?? 500.0;
        viewBoxRect = Rect.fromLTWH(0, 0, width, height);
      }
    }

    final shapes = <MuscleShape>[];
    final pathElements = document.findAllElements('path');

    for (final elem in pathElements) {
      final id = elem.getAttribute('id');
      final d = elem.getAttribute('d');
      if (id != null && d != null && d.isNotEmpty) {
        final path = parseSvgPathData(d);
        shapes.add(MuscleShape(id: id, path: path));
      }
    }

    final model = BodyFigureModel(viewBoxRect: viewBoxRect, shapes: List.unmodifiable(shapes));
    _modelCache[svgContent] = model;
    return model;
  }

  /// Load and parse an SVG asset file asynchronously.
  static Future<BodyFigureModel> loadFromAsset(String assetPath) async {
    final svgContent = await rootBundle.loadString(assetPath);
    return BodyFigureModel.fromSvgString(svgContent);
  }
}
