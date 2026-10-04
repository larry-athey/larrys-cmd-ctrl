<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
  <title>LedBasic Language Reference</title>
  <meta charset="UTF-8">
  <meta http-equiv="cache-control" content="max-age=0">
  <meta http-equiv="cache-control" content="no-cache">
  <meta http-equiv="expires" content="0">
  <meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT">
  <meta http-equiv="pragma" content="no-cache">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <script src="/bootstrap/js/bootstrap.bundle.min.js"></script>
  <style>
    body { padding: 1.5rem; }
    .cmd { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
    h2, h3 { margin-top: 2rem; }
    .table td, .table th { vertical-align: middle; }
    pre { background: #1a1d21; border: 1px solid #343a40; border-radius: .375rem; padding: 1rem; }
  </style>
</head>
<body>

<div class="container-fluid">

  <h1 class="mb-4">LedBasic Language Reference</h1>
  <p class="lead text-secondary">
    Non-blocking BASIC-like scripting engine for WS2812 / NeoPixel animations on ESP8266 &amp; ESP32.
  </p>

  <!-- ===================== 1. SYNTAX ===================== -->
  <h2 id="syntax">1. Syntax</h2>

  <h3>Program Structure</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Element</th><th>Format</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr>
          <td>Line</td>
          <td class="cmd">10 command</td>
          <td>Starts with a line number 1–65534. Executed in ascending order.</td>
        </tr>
        <tr>
          <td>Comment</td>
          <td class="cmd">' text</td>
          <td>Everything after an apostrophe is ignored until the end of the line.</td>
        </tr>
        <tr>
          <td>Parentheses</td>
          <td class="cmd">( expression )</td>
          <td>Group calculations, e.g. <span class="cmd">(X + T) % 256</span></td>
        </tr>
        <tr>
          <td>Multiple statements</td>
          <td class="cmd">10 A=0&nbsp;&nbsp;11 B=1</td>
          <td>Two statements on one text line (separated by two spaces).</td>
        </tr>
      </tbody>
    </table>
  </div>

  <h3>Variables</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Name</th><th>Type</th><th>Range</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr>
          <td class="cmd">A … Z</td>
          <td>int16</td>
          <td>−32768 … 32767</td>
          <td>26 global variables. Reset to 0 when <span class="cmd">play()</span> is called.</td>
        </tr>
      </tbody>
    </table>
  </div>
  <p class="text-secondary small">
    Only single-letter variables are allowed. No arrays, strings or floating-point numbers.
  </p>

  <h3>Execution Order</h3>
  <ul>
    <li>Lines are executed in ascending line-number order.</li>
    <li><span class="cmd">GOTO</span> / <span class="cmd">IF … THEN GOTO</span> jump to the specified line.</li>
    <li>End of program → VM stops (<span class="cmd">isRunning() = false</span>).</li>
    <li><span class="cmd">WAIT</span> / <span class="cmd">DELAY</span> suspend the current tick; the next <span class="cmd">tick()</span> continues.</li>
  </ul>

  <!-- ===================== 2. COMMANDS ===================== -->
  <h2 id="commands">2. Commands</h2>

  <h3>LED Commands</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Command</th><th>Arguments</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr>
          <td class="cmd">SET</td>
          <td class="cmd">pos , r , g , b</td>
          <td>Set pixel <em>pos</em> to RGB (0–255).</td>
        </tr>
        <tr>
          <td class="cmd">SET_HSV</td>
          <td class="cmd">pos , h , s , v</td>
          <td>Set pixel <em>pos</em> to HSV (0–255). Uses FastLED-style conversion.</td>
        </tr>
        <tr>
          <td class="cmd">FILL</td>
          <td class="cmd">r , g , b</td>
          <td>Fill the entire strip with one RGB colour.</td>
        </tr>
        <tr>
          <td class="cmd">CLEAR</td>
          <td>—</td>
          <td>Turn the whole strip off and reset the internal buffer.</td>
        </tr>
        <tr>
          <td class="cmd">SHOW</td>
          <td>—</td>
          <td>Push the buffer to the LEDs without a delay.</td>
        </tr>
        <tr>
          <td class="cmd">WAIT</td>
          <td class="cmd">ms</td>
          <td>SHOW + pause for <em>ms</em> milliseconds (main way to display a frame).</td>
        </tr>
        <tr>
          <td class="cmd">DELAY</td>
          <td class="cmd">ms</td>
          <td>Pause without SHOW (useful between steps).</td>
        </tr>
        <tr>
          <td class="cmd">FADE</td>
          <td class="cmd">pos , amt</td>
          <td>Subtract <em>amt</em> from R, G and B of pixel <em>pos</em> (great for trails).</td>
        </tr>
        <tr>
          <td class="cmd">MIRROR</td>
          <td>—</td>
          <td>Mirror the first half of the strip onto the second half.</td>
        </tr>
      </tbody>
    </table>
  </div>

  <pre class="cmd text-light"><code>10 SET_HSV 0 , 0 , 255 , 255    ' pixel 0 = saturated red
20 SET 5 , 0 , 0 , 255          ' pixel 5 = blue
30 FILL 0 , 80 , 0              ' whole strip dark green
40 FADE 3 , 40                  ' darken pixel 3 a little
50 MIRROR                       ' mirror left → right
60 WAIT 100                     ' show and wait 100 ms</code></pre>

  <div class="alert alert-warning">
    <strong>Note:</strong> <span class="cmd">FADE</span> and <span class="cmd">MIRROR</span> read the internal pixel buffer.
    Always use <span class="cmd">SET</span> / <span class="cmd">SET_HSV</span> / <span class="cmd">FILL</span> so the buffer stays in sync.
  </div>

  <h3>Control Flow</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Command</th><th>Syntax</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr>
          <td class="cmd">GOTO</td>
          <td class="cmd">GOTO n</td>
          <td>Jump to line <em>n</em> (n may be a variable).</td>
        </tr>
        <tr>
          <td class="cmd">GOSUB</td>
          <td class="cmd">GOSUB n</td>
          <td>Call a subroutine (stack depth 10).</td>
        </tr>
        <tr>
          <td class="cmd">RETURN</td>
          <td class="cmd">RETURN</td>
          <td>Return from a subroutine.</td>
        </tr>
        <tr>
          <td class="cmd">FOR</td>
          <td class="cmd">FOR v = a TO b [STEP s]</td>
          <td>Loop. STEP is optional (default 1). Nested up to 8 levels.</td>
        </tr>
        <tr>
          <td class="cmd">NEXT</td>
          <td class="cmd">NEXT v</td>
          <td>End of FOR body.</td>
        </tr>
        <tr>
          <td class="cmd">IF</td>
          <td class="cmd">IF expr op expr THEN cmd</td>
          <td>Conditional execution of a <strong>single</strong> command.<br>
              Operators: <span class="cmd">== != &gt; &lt; &gt;= &lt;=</span></td>
        </tr>
      </tbody>
    </table>
  </div>

  <pre class="cmd text-light"><code>10 FOR I = 0 TO PIXEL STEP 2
20   SET_HSV I , H , 255 , 200
30 NEXT I
40 IF H > 200 THEN GOSUB 500
50 GOTO 10
500 FILL 0 , 0 , 0
510 WAIT 500
520 RETURN</code></pre>

  <div class="alert alert-info">
    <strong>Tip:</strong> <span class="cmd">IF</span> only executes one command after <span class="cmd">THEN</span>.
    For a block of statements use <span class="cmd">GOSUB</span>.
  </div>

  <!-- ===================== 3. OPERATORS ===================== -->
  <h2 id="operators">3. Operators</h2>

  <h3>Arithmetic</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Operator</th><th>Example</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr><td class="cmd">+</td><td class="cmd">A + B</td><td>Addition</td></tr>
        <tr><td class="cmd">-</td><td class="cmd">A - B</td><td>Subtraction / unary minus</td></tr>
        <tr><td class="cmd">*</td><td class="cmd">A * B</td><td>Multiplication (watch int16 overflow!)</td></tr>
        <tr><td class="cmd">/</td><td class="cmd">A / B</td><td>Integer division (B=0 → 0)</td></tr>
        <tr><td class="cmd">%</td><td class="cmd">A % B</td><td>Modulo (very useful for wrapping)</td></tr>
      </tbody>
    </table>
  </div>

  <h3>Comparison (only inside IF)</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Operator</th><th>Meaning</th></tr>
      </thead>
      <tbody>
        <tr><td class="cmd">==</td><td>equal</td></tr>
        <tr><td class="cmd">!=</td><td>not equal</td></tr>
        <tr><td class="cmd">&gt;</td><td>greater than</td></tr>
        <tr><td class="cmd">&lt;</td><td>less than</td></tr>
        <tr><td class="cmd">&gt;=</td><td>greater or equal</td></tr>
        <tr><td class="cmd">&lt;=</td><td>less or equal</td></tr>
      </tbody>
    </table>
  </div>

  <h3>Bitwise</h3>
  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Operator</th><th>Example</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr><td class="cmd">AND</td><td class="cmd">X AND 255</td><td>Bitwise AND</td></tr>
        <tr><td class="cmd">OR</td><td class="cmd">A OR B</td><td>Bitwise OR</td></tr>
      </tbody>
    </table>
  </div>

  <!-- ===================== 4. FUNCTIONS ===================== -->
  <h2 id="functions">4. Built-in Functions</h2>

  <div class="table-responsive">
    <table class="table table-dark table-striped table-bordered">
      <thead>
        <tr><th>Function</th><th>Arguments</th><th>Returns</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr>
          <td class="cmd">PIXEL</td>
          <td>—</td>
          <td>total_leds − 1</td>
          <td>Highest valid pixel index.</td>
        </tr>
        <tr>
          <td class="cmd">RND</td>
          <td class="cmd">lo , hi</td>
          <td>int</td>
          <td>Random number in range [lo … hi] inclusive.</td>
        </tr>
        <tr>
          <td class="cmd">ABS</td>
          <td class="cmd">x</td>
          <td>int</td>
          <td>Absolute value.</td>
        </tr>
        <tr>
          <td class="cmd">MIN</td>
          <td class="cmd">a , b</td>
          <td>int</td>
          <td>Smaller of two values.</td>
        </tr>
        <tr>
          <td class="cmd">MAX</td>
          <td class="cmd">a , b</td>
          <td>int</td>
          <td>Larger of two values.</td>
        </tr>
        <tr>
          <td class="cmd">SIN8</td>
          <td class="cmd">angle</td>
          <td>0–255</td>
          <td>8-bit sine (angle 0–255 = 0–360°).</td>
        </tr>
        <tr>
          <td class="cmd">COS8</td>
          <td class="cmd">angle</td>
          <td>0–255</td>
          <td>8-bit cosine.</td>
        </tr>
        <tr>
          <td class="cmd">EXP8</td>
          <td class="cmd">x</td>
          <td>0–255</td>
          <td>Approximate gamma / exponential curve.</td>
        </tr>
        <tr>
          <td class="cmd">NOISE</td>
          <td class="cmd">x , y</td>
          <td>0–255</td>
          <td>2-D value noise (great for fire, plasma, etc.).</td>
        </tr>
        <tr>
          <td class="cmd">MAP</td>
          <td class="cmd">val , in_min , in_max , out_min , out_max</td>
          <td>int</td>
          <td>Re-map a value from one range to another.</td>
        </tr>
        <tr>
          <td class="cmd">CONSTRAIN</td>
          <td class="cmd">val , lo , hi</td>
          <td>int</td>
          <td>Clamp value between lo and hi.</td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- ===================== 5. C++ API ===================== -->
  <h2 id="api">5. C++ API (quick reminder)</h2>
  <pre class="cmd text-light"><code>bool compileFromText(const char* script);   // compile & load script
void play();                                // start from beginning, reset vars
void stop();                                // stop + clear strip
void tick();                                // call every loop()
bool isRunning() const;
void setSpeed(uint16_t percent);            // 1–1000, 100 = normal
uint16_t getSpeed() const;</code></pre>

  <hr class="my-5">
  <p class="text-secondary small text-center">
    Generated English reference for LedBasic (v1.2.x) · Compatible with Larry’s CMD &amp; CTRL
  </p>

</div>

</body>
</html>
