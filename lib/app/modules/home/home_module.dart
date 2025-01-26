import 'package:path/path.dart';
import 'package:todo_list_provider/app/core/mudules/todo_list_module.dart';
import 'package:todo_list_provider/app/modules/home/home_page.dart';

class HomeModule extends TodoListModule {
  HomeModule()
      : super(
          routers: {
            '/home': (context) => HomePage(),
          },
          bindings: [],
        );
}
