// A port of V8's Array.prototype.sort (TimSort, third_party/v8/builtins/
// array-sort.tq).
//
// The forest assembler's comparator is not transitive (cards count as being in
// the same row when their y differs by less than half a card), so the result
// depends on the exact sort algorithm. To get the same base order as
// ForestDetector running in a browser we replay V8's comparisons exactly.
// Dart's List.sort uses a different (and unstable) algorithm.

import 'dart:math';

typedef JsCompare<T> = num Function(T a, T b);

const _minGallopWins = 7;

/// Sorts [list] in place exactly like V8's `Array.prototype.sort`.
void jsSort<T>(List<T> list, JsCompare<T> compare) {
  if (list.length < 2) return;
  _TimSort<T>(list, compare).sort();
}

class _TimSort<T> {
  final List<T> a;
  final JsCompare<T> _compareFn;
  final List<int> _runBase = [];
  final List<int> _runLength = [];
  int _minGallop = _minGallopWins;

  _TimSort(this.a, this._compareFn);

  // V8 treats NaN as 0; only the sign matters.
  num _cmp(T x, T y) {
    final r = _compareFn(x, y);
    return r.isNaN ? 0 : r;
  }

  void sort() {
    var remaining = a.length;
    var low = 0;
    final minRun = _minRunLength(remaining);
    while (remaining != 0) {
      var run = _countAndMakeRun(low, low + remaining);
      if (run < minRun) {
        final forced = min(minRun, remaining);
        _binaryInsertionSort(low, low + run, low + forced);
        run = forced;
      }
      _runBase.add(low);
      _runLength.add(run);
      _mergeCollapse();
      low += run;
      remaining -= run;
    }
    _mergeForceCollapse();
  }

  static int _minRunLength(int n) {
    var r = 0;
    while (n >= 64) {
      r |= n & 1;
      n >>= 1;
    }
    return n + r;
  }

  int _countAndMakeRun(int lowArg, int high) {
    final low = lowArg + 1;
    if (low == high) return 1;
    var runLength = 2;
    final isDescending = _cmp(a[low], a[low - 1]) < 0;
    var previous = a[low];
    for (var i = low + 1; i < high; i++) {
      final current = a[i];
      final order = _cmp(current, previous);
      if (isDescending ? order >= 0 : order < 0) break;
      previous = current;
      runLength++;
    }
    if (isDescending) _reverse(lowArg, lowArg + runLength);
    return runLength;
  }

  void _reverse(int from, int to) {
    var low = from;
    var high = to - 1;
    while (low < high) {
      final tmp = a[low];
      a[low++] = a[high];
      a[high--] = tmp;
    }
  }

  void _binaryInsertionSort(int low, int startArg, int high) {
    var start = low == startArg ? startArg + 1 : startArg;
    for (; start < high; start++) {
      var left = low;
      var right = start;
      final pivot = a[start];
      while (left < right) {
        final mid = left + ((right - left) >> 1);
        if (_cmp(pivot, a[mid]) < 0) {
          right = mid;
        } else {
          left = mid + 1;
        }
      }
      for (var p = start; p > left; p--) {
        a[p] = a[p - 1];
      }
      a[left] = pivot;
    }
  }

  bool _invariantEstablished(int n) {
    if (n < 2) return true;
    return _runLength[n - 2] > _runLength[n - 1] + _runLength[n];
  }

  void _mergeCollapse() {
    while (_runBase.length > 1) {
      var n = _runBase.length - 2;
      if (!_invariantEstablished(n + 1) || !_invariantEstablished(n)) {
        if (_runLength[n - 1] < _runLength[n + 1]) n--;
        _mergeAt(n);
      } else if (_runLength[n] <= _runLength[n + 1]) {
        _mergeAt(n);
      } else {
        break;
      }
    }
  }

  void _mergeForceCollapse() {
    while (_runBase.length > 1) {
      var n = _runBase.length - 2;
      if (n > 0 && _runLength[n - 1] < _runLength[n + 1]) n--;
      _mergeAt(n);
    }
  }

  void _mergeAt(int i) {
    var baseA = _runBase[i];
    var lengthA = _runLength[i];
    final baseB = _runBase[i + 1];
    var lengthB = _runLength[i + 1];

    _runLength[i] = lengthA + lengthB;
    _runBase.removeAt(i + 1);
    _runLength.removeAt(i + 1);

    final k = _gallopRight(a, a[baseB], baseA, lengthA, 0);
    baseA += k;
    lengthA -= k;
    if (lengthA == 0) return;

    lengthB =
        _gallopLeft(a, a[baseA + lengthA - 1], baseB, lengthB, lengthB - 1);
    if (lengthB == 0) return;

    if (lengthA <= lengthB) {
      _mergeLow(baseA, lengthA, baseB, lengthB);
    } else {
      _mergeHigh(baseA, lengthA, baseB, lengthB);
    }
  }

  /// Leftmost index in arr[base, base+length) where [key] can be inserted.
  int _gallopLeft(List<T> arr, T key, int base, int length, int hint) {
    var lastOfs = 0;
    var offset = 1;
    if (_cmp(arr[base + hint], key) < 0) {
      final maxOfs = length - hint;
      while (offset < maxOfs) {
        if (_cmp(arr[base + hint + offset], key) >= 0) break;
        lastOfs = offset;
        offset = (offset << 1) + 1;
      }
      if (offset > maxOfs) offset = maxOfs;
      lastOfs += hint;
      offset += hint;
    } else {
      final maxOfs = hint + 1;
      while (offset < maxOfs) {
        if (_cmp(arr[base + hint - offset], key) < 0) break;
        lastOfs = offset;
        offset = (offset << 1) + 1;
      }
      if (offset > maxOfs) offset = maxOfs;
      final tmp = lastOfs;
      lastOfs = hint - offset;
      offset = hint - tmp;
    }
    lastOfs++;
    while (lastOfs < offset) {
      final m = lastOfs + ((offset - lastOfs) >> 1);
      if (_cmp(arr[base + m], key) < 0) {
        lastOfs = m + 1;
      } else {
        offset = m;
      }
    }
    return offset;
  }

  /// Rightmost index in arr[base, base+length) where [key] can be inserted.
  int _gallopRight(List<T> arr, T key, int base, int length, int hint) {
    var lastOfs = 0;
    var offset = 1;
    if (_cmp(key, arr[base + hint]) < 0) {
      final maxOfs = hint + 1;
      while (offset < maxOfs) {
        if (_cmp(key, arr[base + hint - offset]) >= 0) break;
        lastOfs = offset;
        offset = (offset << 1) + 1;
      }
      if (offset > maxOfs) offset = maxOfs;
      final tmp = lastOfs;
      lastOfs = hint - offset;
      offset = hint - tmp;
    } else {
      final maxOfs = length - hint;
      while (offset < maxOfs) {
        if (_cmp(key, arr[base + hint + offset]) < 0) break;
        lastOfs = offset;
        offset = (offset << 1) + 1;
      }
      if (offset > maxOfs) offset = maxOfs;
      lastOfs += hint;
      offset += hint;
    }
    lastOfs++;
    while (lastOfs < offset) {
      final m = lastOfs + ((offset - lastOfs) >> 1);
      if (_cmp(key, arr[base + m]) < 0) {
        offset = m;
      } else {
        lastOfs = m + 1;
      }
    }
    return offset;
  }

  void _copy(List<T> src, int srcPos, List<T> dst, int dstPos, int length) {
    if (srcPos < dstPos) {
      for (var i = length - 1; i >= 0; i--) {
        dst[dstPos + i] = src[srcPos + i];
      }
    } else {
      for (var i = 0; i < length; i++) {
        dst[dstPos + i] = src[srcPos + i];
      }
    }
  }

  void _mergeLow(int baseA, int lengthA, int baseB, int lengthB) {
    final temp = a.sublist(baseA, baseA + lengthA);
    var dest = baseA;
    var cursorTemp = 0;
    var cursorB = baseB;

    a[dest++] = a[cursorB++];

    // Labels Succeed / CopyB of the original become these two exits.
    void succeed() {
      if (lengthA > 0) _copy(temp, cursorTemp, a, dest, lengthA);
    }

    void copyB() {
      _copy(a, cursorB, a, dest, lengthB);
      a[dest + lengthB] = temp[cursorTemp];
    }

    if (--lengthB == 0) return succeed();
    if (lengthA == 1) return copyB();

    var minGallop = _minGallop;
    while (true) {
      var winsA = 0;
      var winsB = 0;

      while (true) {
        if (_cmp(a[cursorB], temp[cursorTemp]) < 0) {
          a[dest++] = a[cursorB++];
          winsB++;
          lengthB--;
          winsA = 0;
          if (lengthB == 0) return succeed();
          if (winsB >= minGallop) break;
        } else {
          a[dest++] = temp[cursorTemp++];
          winsA++;
          lengthA--;
          winsB = 0;
          if (lengthA == 1) return copyB();
          if (winsA >= minGallop) break;
        }
      }

      minGallop++;
      var first = true;
      while (winsA >= _minGallopWins || winsB >= _minGallopWins || first) {
        first = false;
        minGallop = max(1, minGallop - 1);
        _minGallop = minGallop;

        winsA = _gallopRight(temp, a[cursorB], cursorTemp, lengthA, 0);
        if (winsA > 0) {
          _copy(temp, cursorTemp, a, dest, winsA);
          dest += winsA;
          cursorTemp += winsA;
          lengthA -= winsA;
          if (lengthA == 1) return copyB();
          if (lengthA == 0) return succeed();
        }
        a[dest++] = a[cursorB++];
        if (--lengthB == 0) return succeed();

        winsB = _gallopLeft(a, temp[cursorTemp], cursorB, lengthB, 0);
        if (winsB > 0) {
          _copy(a, cursorB, a, dest, winsB);
          dest += winsB;
          cursorB += winsB;
          lengthB -= winsB;
          if (lengthB == 0) return succeed();
        }
        a[dest++] = temp[cursorTemp++];
        if (--lengthA == 1) return copyB();
      }
      minGallop++;
      _minGallop = minGallop;
    }
  }

  void _mergeHigh(int baseA, int lengthA, int baseB, int lengthB) {
    final temp = a.sublist(baseB, baseB + lengthB);
    var dest = baseB + lengthB - 1;
    var cursorTemp = lengthB - 1;
    var cursorA = baseA + lengthA - 1;

    a[dest--] = a[cursorA--];

    void succeed() {
      if (lengthB > 0) _copy(temp, 0, a, dest - (lengthB - 1), lengthB);
    }

    void copyA() {
      dest -= lengthA;
      cursorA -= lengthA;
      _copy(a, cursorA + 1, a, dest + 1, lengthA);
      a[dest] = temp[cursorTemp];
    }

    if (--lengthA == 0) return succeed();
    if (lengthB == 1) return copyA();

    var minGallop = _minGallop;
    while (true) {
      var winsA = 0;
      var winsB = 0;

      while (true) {
        if (_cmp(temp[cursorTemp], a[cursorA]) < 0) {
          a[dest--] = a[cursorA--];
          winsA++;
          lengthA--;
          winsB = 0;
          if (lengthA == 0) return succeed();
          if (winsA >= minGallop) break;
        } else {
          a[dest--] = temp[cursorTemp--];
          winsB++;
          lengthB--;
          winsA = 0;
          if (lengthB == 1) return copyA();
          if (winsB >= minGallop) break;
        }
      }

      minGallop++;
      var first = true;
      while (winsA >= _minGallopWins || winsB >= _minGallopWins || first) {
        first = false;
        minGallop = max(1, minGallop - 1);
        _minGallop = minGallop;

        var k = _gallopRight(a, temp[cursorTemp], baseA, lengthA, lengthA - 1);
        winsA = lengthA - k;
        if (winsA > 0) {
          dest -= winsA;
          cursorA -= winsA;
          _copy(a, cursorA + 1, a, dest + 1, winsA);
          lengthA -= winsA;
          if (lengthA == 0) return succeed();
        }
        a[dest--] = temp[cursorTemp--];
        if (--lengthB == 1) return copyA();

        k = _gallopLeft(temp, a[cursorA], 0, lengthB, lengthB - 1);
        winsB = lengthB - k;
        if (winsB > 0) {
          dest -= winsB;
          cursorTemp -= winsB;
          _copy(temp, cursorTemp + 1, a, dest + 1, winsB);
          lengthB -= winsB;
          if (lengthB == 1) return copyA();
          if (lengthB == 0) return succeed();
        }
        a[dest--] = a[cursorA--];
        if (--lengthA == 0) return succeed();
      }
      minGallop++;
      _minGallop = minGallop;
    }
  }
}
