/// Parses the `&&`-delimited state token string used by inWebo.
/// Direct port of Python `tokenizer.py`.
class OtpTokenizer {
  OtpTokenizer(String tokens, {String delimiter = '&&'})
      : _s = tokens,
        _delimiter = delimiter,
        _index = 0;

  final String _s;
  final String _delimiter;
  int _index;

  bool get hasMoreTokens => _index < _s.length;

  String nextToken() {
    if (_index >= _s.length) return '';
    final relativeIndex = _s.indexOf(_delimiter, _index);
    if (relativeIndex == -1) {
      final sub = _s.substring(_index);
      _index = _s.length;
      return sub;
    }
    final sub = _s.substring(_index, relativeIndex);
    _index = relativeIndex + _delimiter.length;
    return sub;
  }

  /// Returns the next token parsed as a hexadecimal integer, or 0 if empty.
  int nextTokenInt() {
    final token = nextToken();
    if (token.isEmpty) return 0;
    return int.parse(token, radix: 16);
  }
}
