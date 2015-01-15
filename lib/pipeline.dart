part of gladius;


class Pipeline {
  List<AppFunc> functions = <AppFunc>[];

  void use(AppFunc func) {
    functions.add(func);
  }
}
