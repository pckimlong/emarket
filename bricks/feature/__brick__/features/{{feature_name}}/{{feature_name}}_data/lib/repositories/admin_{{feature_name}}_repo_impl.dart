import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:{{feature_name}}_data/mappers/{{feature_name}}_mapper.dart';
import 'package:{{feature_name}}_domain/{{feature_name}}_domain.dart';

class Admin{{class_name}}RepoImpl({
  required final EndpointAdmin{{class_name}} _endpoint,
}) implements IAdmin{{class_name}}Repo {
  final {{class_name}}Mapper mapper = const {{class_name}}Mapper();

  @override
  Result<IList<{{class_name}}>> list{{plural_label.pascalCase()}}() {
    return failureHandler(() async {
      final results = await _endpoint.list{{plural_label.pascalCase()}}();
      return mapper.convertIList<{{class_name}}Dto, {{class_name}}>(results);
    });
  }
}
