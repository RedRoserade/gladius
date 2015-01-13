part of gladius;

String _addTrailingSlash(String path) =>
    path.endsWith('/') ? path : path + '/';

String _removeTrailingSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;

String _joinPaths(List<String> paths, {bool addTrailingSlash: true}) =>
    paths
      .where((p) => p.isNotEmpty)
      .map(_removeTrailingSlash)
      .join() + (addTrailingSlash ? '/' : '');