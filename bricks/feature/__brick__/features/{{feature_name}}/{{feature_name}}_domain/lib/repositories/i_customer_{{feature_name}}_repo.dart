import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:{{feature_name}}_domain/{{feature_name}}_domain.dart';

abstract class ICustomer{{class_name}}Repo {
  Result<IList<{{class_name}}>> list{{plural_label.pascalCase()}}();
}
