# Third-party notices

The Forest Shuffle (Mischwald) scoring engine in this directory is a Dart
translation of the following projects.

## ForestDetector

https://github.com/NINI1988/ForestDetector

Translated to Dart: the detector card catalogue (`detector_cards.dart`,
`card_id.dart`, `card_color.dart`, `card_position.dart` from `src/model/cards.ts`,
`card-id.ts`, `card-color.ts`, `card-position.ts`), the forest assembler
(`forest_assembler.dart`), the param handler (`param_handler.dart`), the forest
(`forest.dart`), the prediction model (`prediction.dart`) and the multi-player
scoring flow of `src/app/home/home.component.ts` (`scoring.dart`). The tests in
`test/forest_shuffle/` are ports of its specs and use its `test_data/responses`
fixtures.

```
MIT License

Copyright (c) 2025 NINI1988

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## glaures/forestshuffle

https://github.com/glaures/forestshuffle (as vendored in ForestDetector under
`src/third_party/glaures_forestshuffle`)

The files `src/model/Forest.js`, `src/model/cards.js` and
`src/model/card-*.js` were translated from JavaScript to Dart as
`gl_forest.dart` and `gl_cards.dart`. Changes: the code was rewritten in Dart;
UI-only fields (`type`, `hide`, distributed-scoring switches) were dropped and
"has most" comparisons identify other forests by object instead of by player
name.

```
Copyright 2024 Guido Laures

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## V8

https://chromium.googlesource.com/v8/v8 (`third_party/v8/builtins/array-sort.tq`)

`js_sort.dart` is a Dart translation of V8's `Array.prototype.sort` (TimSort),
so that the forest assembler orders cards exactly like ForestDetector does in a
browser.

```
Copyright 2014, the V8 project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
