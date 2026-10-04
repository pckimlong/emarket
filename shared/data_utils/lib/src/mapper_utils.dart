import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension MapperUtils on AutoMapprInterface {
  IList<T> convertIList<S, T>(List<S> sources) {
    return convertList<S, T>(sources).toIList();
  }
}
