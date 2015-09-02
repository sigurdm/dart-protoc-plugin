// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library protoc.benchmark.repeated_int32_json;

import '../benchmark.dart';
import '../generated/benchmark.pb.dart' show BenchmarkID, Request, Params, Sample;
import '../generated/intgrid.pb.dart' as pb;

/// A benchmark that deserializes a grid of repeated ints.
class RepeatedInt32Benchmark extends Benchmark {
  final int width;
  final int height;
  String json;

  RepeatedInt32Benchmark(this.width, this.height) : super($id);

  @override
  get summary => "${id.name}($width x $height ints)";

  @override
  Params makeParams() => new Params()
    ..int32RepeatCount = width
    ..messageCount = height;

  @override
  void setup() {
    var grid = _makeGrid(width, height);
    json = grid.writeToJson();
  }

  // makes a rectangle of the of the form:
  // 0 1 2 3
  // 1 2 3 4
  // 2 3 4 5
  static pb.Grid _makeGrid(int width, int height) {
    var grid = new pb.Grid();

    for (int y = 0; y < height; y++) {
      var line = new pb.Line();
      for (int x = 0; x < width; x++) {
        line.cells.add(x + y);
      }
      grid.lines.add(line);
    }

    return grid;
  }

  @override
  void run() {
    pb.Grid grid = new pb.Grid.fromJson(json);
    var actual = grid.lines[height - 1].cells[width - 1];
    if (actual != width + height - 2) throw "failed; got ${actual}";
  }

  @override
  void setCounts(Sample s) {
    s.counts.int32Reads = width * height * s.loopCount;
  }

  static const $id = BenchmarkID.READ_INT32_REPEATED_JSON;
  static final $type = new BenchmarkType($id, $create);
  static $create(Request r) {
    assert(r.params.hasInt32RepeatCount());
    assert(r.params.hasMessageCount());
    return new RepeatedInt32Benchmark(
        r.params.int32RepeatCount, r.params.messageCount);
  }
}
