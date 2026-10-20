<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LCC Timeline Editor</title>
  <link href="/assets/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <script src="/assets/js/jquery.min.js"></script>
  <script src="/assets/bootstrap/js/bootstrap.bundle.min.js"></script>
  <style>
    :root {
      --track-height: 48px;
      --header-height: 40px;
      --label-width: 180px;
    }
    body { margin: 0; padding: 0; background: #121212; overflow: hidden; font-size: 0.9rem; }
    #app { display: flex; flex-direction: column; height: 100vh; }
    #toolbar { flex: 0 0 auto; background: #1e1e1e; border-bottom: 1px solid #333; padding: 8px 12px; }
    #main { flex: 1; display: flex; overflow: hidden; }
    #device-list { flex: 0 0 var(--label-width); background: #1a1a1a; border-right: 1px solid #333; overflow-y: auto; }
    #timeline-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; position: relative; }
    #time-header { flex: 0 0 var(--header-height); background: #222; border-bottom: 1px solid #333; position: relative; overflow: hidden; }
    #tracks { flex: 1; overflow: auto; position: relative; }
    .device-label {
      height: var(--track-height); line-height: var(--track-height); padding: 0 10px;
      border-bottom: 1px solid #2a2a2a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
      font-weight: 600; cursor: default; user-select: none;
    }
    .device-label small { color: #888; font-weight: normal; }
    .track {
      height: var(--track-height); border-bottom: 1px solid #2a2a2a; position: relative;
      background: repeating-linear-gradient(90deg, transparent, transparent 9px, #1f1f1f 9px, #1f1f1f 10px);
    }
    .frame {
      position: absolute; top: 6px; height: 36px; min-width: 8px; border-radius: 4px;
      background: #0d6efd; border: 1px solid #3d8bfd; color: #fff; font-size: 0.75rem;
      padding: 2px 6px; cursor: pointer; overflow: hidden; white-space: nowrap; z-index: 10;
      box-shadow: 0 1px 3px rgba(0,0,0,0.4);
    }
    .frame:hover { background: #0b5ed7; z-index: 20; }
    .frame.selected { outline: 2px solid #ffc107; z-index: 30; }
    .playhead {
      position: absolute; top: 0; bottom: 0; width: 2px; background: #ff4d4d;
      z-index: 50; pointer-events: none; box-shadow: 0 0 6px #ff4d4d;
    }
    .time-marker { position: absolute; top: 0; bottom: 0; width: 1px; background: #444; }
    .time-label { position: absolute; top: 4px; font-size: 0.7rem; color: #aaa; transform: translateX(-50%); }
    #status-bar { flex: 0 0 auto; background: #1e1e1e; border-top: 1px solid #333; padding: 4px 12px; font-size: 0.8rem; }
    .modal-body .form-label { margin-bottom: 0.2rem; }
    .cmd-section { display: none; }
  </style>
</head>
<body>
<div id="app">
  <!-- Toolbar -->
  <div id="toolbar" class="d-flex align-items-center gap-2 flex-wrap">
    <button id="btn-play" class="btn btn-success btn-sm fw-bolder">▶ Play</button>
    <button id="btn-stop" class="btn btn-danger btn-sm fw-bolder">■ Stop</button>
    <button id="btn-rewind" class="btn btn-secondary btn-sm">⏪ 0</button>
    <span class="ms-2">Position: <strong id="pos-display">0.0</strong> s</span>
    <div class="vr mx-2"></div>
    <label class="mb-0">Zoom:</label>
    <input type="range" id="zoom" min="4" max="40" value="12" style="width:100px">
    <span id="zoom-label">12 px/0.1s</span>
    <div class="vr mx-2"></div>
    <button id="btn-add" class="btn btn-primary btn-sm fw-bolder">+ Add Frame</button>
    <button id="btn-refresh" class="btn btn-outline-light btn-sm">↻ Refresh</button>
    <span class="ms-auto text-muted small" id="script-name">Unsaved Script</span>
  </div>

  <!-- Main workspace -->
  <div id="main">
    <div id="device-list"></div>
    <div id="timeline-area">
      <div id="time-header"></div>
      <div id="tracks"></div>
      <div class="playhead" id="playhead" style="left:0"></div>
    </div>
  </div>

  <!-- Status bar -->
  <div id="status-bar" class="d-flex justify-content-between">
    <span id="status-text">Ready</span>
    <span id="frame-count">0 frames</span>
  </div>
</div>

<!-- Edit / Add Frame Modal -->
<div class="modal fade" id="frameModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalTitle">Edit Frame</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <form id="frameForm">
          <input type="hidden" id="f-id" value="0">
          <div class="mb-2">
            <label class="form-label fw-bolder">Command Name</label>
            <input type="text" class="form-control fw-bolder" id="f-cmd_name" maxlength="255" required>
          </div>
          <div class="mb-2">
            <label class="form-label fw-bolder">Device</label>
            <select class="form-select fw-bolder" id="f-address" required></select>
          </div>
          <div class="mb-2">
            <label class="form-label fw-bolder">Position (seconds)</label>
            <input type="number" class="form-control fw-bolder" id="f-position" min="0" step="0.1" value="0" required>
          </div>
          <div class="mb-2">
            <label class="form-label fw-bolder">Command Type</label>
            <select class="form-select fw-bolder" id="f-cmd_type" required></select>
          </div>

          <!-- cmd_type 1 – Motor -->
          <div class="cmd-section" data-type="1">
            <div class="mb-2"><label class="form-label fw-bolder">Direction</label>
              <select class="form-select" id="f-direction"><option value="1">Forward</option><option value="0">Reverse</option></select></div>
            <div class="mb-2"><label class="form-label fw-bolder">Speed [0..100]</label>
              <input type="number" class="form-control" id="f-speed" min="0" max="100" value="50"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Progression (s)</label>
              <input type="number" class="form-control" id="f-progression" min="0" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Duration (s, 0=indefinite)</label>
              <input type="number" class="form-control" id="f-duration" min="0" value="0"></div>
          </div>

          <!-- cmd_type 2 – Stepper -->
          <div class="cmd-section" data-type="2">
            <div class="mb-2"><label class="form-label fw-bolder">Direction</label>
              <select class="form-select" id="f-direction2"><option value="1">Forward</option><option value="0">Reverse</option></select></div>
            <div class="mb-2"><label class="form-label fw-bolder">Resolution</label>
              <select class="form-select" id="f-resolution">
                <option value="1">Full</option><option value="2">1/2</option><option value="4">1/4</option>
                <option value="8">1/8</option><option value="16">1/16</option><option value="32">1/32</option>
              </select></div>
            <div class="mb-2"><label class="form-label fw-bolder">Steps</label>
              <input type="number" class="form-control" id="f-steps" min="1" value="200"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Speed [1..100]</label>
              <input type="number" class="form-control" id="f-speed2" min="1" max="100" value="50"></div>
          </div>

          <!-- cmd_type 3 – Location -->
          <div class="cmd-section" data-type="3">
            <div class="mb-2"><label class="form-label fw-bolder">Location ID</label>
              <input type="number" class="form-control" id="f-location_id" min="0" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Action</label>
              <input type="number" class="form-control" id="f-location_action" min="0" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Data</label>
              <input type="number" class="form-control" id="f-location_data" min="0" value="0"></div>
          </div>

          <!-- cmd_type 4 – Sound -->
          <div class="cmd-section" data-type="4">
            <div class="mb-2"><label class="form-label fw-bolder">Sound File ID</label>
              <input type="number" class="form-control" id="f-sound" min="0" max="1000" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Volume [0..30]</label>
              <input type="number" class="form-control" id="f-volume" min="0" max="30" value="25"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Loop</label>
              <select class="form-select" id="f-replay"><option value="0">No</option><option value="1">Yes</option></select></div>
          </div>

          <!-- cmd_type 5 – Switch -->
          <div class="cmd-section" data-type="5">
            <div class="mb-2"><label class="form-label fw-bolder">GPIO Pin [0..15]</label>
              <input type="number" class="form-control" id="f-gpio_pin" min="0" max="15" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">State</label>
              <select class="form-select" id="f-direction5"><option value="1">On</option><option value="0">Off</option></select></div>
          </div>

          <!-- cmd_type 6 – Light -->
          <div class="cmd-section" data-type="6">
            <div class="mb-2"><label class="form-label fw-bolder">LED / Fixture (65535 = all)</label>
              <input type="number" class="form-control" id="f-light" min="0" max="65535" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Red [0..255]</label>
              <input type="number" class="form-control" id="f-red" min="0" max="255" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Green [0..255]</label>
              <input type="number" class="form-control" id="f-green" min="0" max="255" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Blue [0..255]</label>
              <input type="number" class="form-control" id="f-blue" min="0" max="255" value="0"></div>
            <div class="mb-2"><label class="form-label fw-bolder">Fade (s)</label>
              <input type="number" class="form-control" id="f-fade" min="0" max="30" step="0.1" value="1.0"></div>
          </div>

          <!-- cmd_type 7 – Scene -->
          <div class="cmd-section" data-type="7">
            <div class="mb-2"><label class="form-label fw-bolder">Scene ID</label>
              <input type="number" class="form-control" id="f-scene" min="0" value="0"></div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-danger" id="btn-delete" style="display:none">Delete</button>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary fw-bolder" id="btn-save">Save</button>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  const API_URL = './timeline-api.php';

  // State
  let devices = [];
  let framesByAddress = {};   // address → array of frames
  let selectedFrameId = null;
  let pxPerTenth = 12;        // pixels per 0.1 second
  let currentPos = 0;         // seconds
  let isRunning = false;
  let pollTimer = null;
  let maxTime = 60;           // seconds (auto-expands)

  // ---------- Helpers ----------
  function apiGet(params) {
    return $.getJSON(API_URL + '?' + $.param(params));
  }
  function apiPost(data) {
    return $.ajax({
      url: API_URL,
      method: 'POST',
      contentType: 'application/json',
      data: JSON.stringify(data),
      dataType: 'json'
    });
  }
  function deviceTypeName(t) {
    return {1:'Brushed Motor',2:'Stepper',3:'Switching',4:'Train Loco'}[t] || 'Unknown';
  }
  function allowedCmdTypes(devType) {
    if (devType === 2) return [2,3,5];                 // stepper
    if (devType === 3) return [3,4,5,6,7];             // switching
    return [1,3,4,5,6,7];                              // 1 & 4
  }
  function cmdTypeName(t) {
    return {1:'Motor',2:'Stepper',3:'Location',4:'Sound',5:'Switch',6:'Light',7:'Scene'}[t] || '?';
  }
  function posToPx(pos) { return Math.round(pos * 10 * pxPerTenth); }
  function pxToPos(px)  { return Math.round(px / pxPerTenth) / 10; }

  // ---------- Load data ----------
  function loadDevices() {
    return apiGet({action:'list', type:'devices'}).then(list => {
      devices = Array.isArray(list) ? list : [];
      renderDeviceList();
      return loadAllFrames();
    }).catch(() => {
      devices = [];
      renderDeviceList();
      $('#status-text').text('Failed to load devices');
    });
  }

  function loadAllFrames() {
    const promises = devices.map(d =>
      apiGet({action:'list', type:'frames', address:d.address})
        .then(fr => { framesByAddress[d.address] = Array.isArray(fr) ? fr : []; })
        .catch(() => { framesByAddress[d.address] = []; })
    );
    return Promise.all(promises).then(() => {
      // expand maxTime
      let max = 10;
      Object.values(framesByAddress).forEach(arr => {
        arr.forEach(f => { if (+f.position > max) max = +f.position; });
      });
      maxTime = Math.max(60, Math.ceil(max + 10));
      renderTimeline();
      updateFrameCount();
    });
  }

  // ---------- Rendering ----------
  function renderDeviceList() {
    const $list = $('#device-list').empty();
    devices.forEach(d => {
      $list.append(`<div class="device-label" title="${d.address}">
        ${d.dev_name}<br><small>${deviceTypeName(d.dev_type)}</small>
      </div>`);
    });
    if (!devices.length) $list.append('<div class="p-3 text-muted">No devices</div>');
  }

  function renderTimeline() {
    const $header = $('#time-header').empty();
    const $tracks = $('#tracks').empty();

    // time header
    const totalPx = posToPx(maxTime);
    $header.css('width', totalPx + 40);
    for (let s = 0; s <= maxTime; s += 1) {
      const x = posToPx(s);
      $header.append(`<div class="time-marker" style="left:${x}px"></div>`);
      $header.append(`<div class="time-label" style="left:${x}px">${s}s</div>`);
    }

    // tracks + frames
    devices.forEach(d => {
      const $track = $(`<div class="track" data-address="${d.address}" style="width:${totalPx + 40}px"></div>`);
      const frames = framesByAddress[d.address] || [];
      frames.forEach(f => {
        const left = posToPx(+f.position);
        const $f = $(`<div class="frame" data-id="${f.ID}" style="left:${left}px"
                         title="${f.cmd_name} @ ${f.position}s">${f.cmd_name}</div>`);
        if (f.ID == selectedFrameId) $f.addClass('selected');
        $track.append($f);
      });
      $tracks.append($track);
    });

    // click empty track → add
    $tracks.off('click').on('click', '.track', function(e) {
      if ($(e.target).hasClass('frame')) return;
      const addr = $(this).data('address');
      const rect = this.getBoundingClientRect();
      const x = e.clientX - rect.left + this.parentElement.scrollLeft;
      openModal(0, addr, pxToPos(x));
    });

    // click frame → edit
    $tracks.on('click', '.frame', function(e) {
      e.stopPropagation();
      openModal(+$(this).data('id'));
    });

    updatePlayhead();
  }

  function updatePlayhead() {
    $('#playhead').css('left', posToPx(currentPos) + 'px');
    $('#pos-display').text(currentPos.toFixed(1));
  }

  function updateFrameCount() {
    let n = 0;
    Object.values(framesByAddress).forEach(a => n += a.length);
    $('#frame-count').text(n + ' frames');
  }

  // ---------- Modal ----------
  function openModal(id, address, position) {
    selectedFrameId = id;
    const $m = $('#frameModal');
    const form = document.getElementById('frameForm');
    form.reset();

    // populate device select
    const $addr = $('#f-address').empty();
    devices.forEach(d => {
      $addr.append(`<option value="${d.address}" data-type="${d.dev_type}">${d.dev_name}</option>`);
    });

    if (id > 0) {
      // load existing
      apiGet({action:'list', type:'getframe', id:id}).then(f => {
        if (!f || f.ID === undefined) { alert('Frame not found'); return; }
        $('#modalTitle').text('Edit Frame');
        $('#btn-delete').show();
        fillForm(f);
        $m.modal('show');
      });
    } else {
      $('#modalTitle').text('Add Frame');
      $('#btn-delete').hide();
      $('#f-id').val(0);
      if (address) $('#f-address').val(address);
      if (position !== undefined) $('#f-position').val(position);
      updateCmdTypeOptions();
      showCmdSection(1);
      $m.modal('show');
    }
  }

  function fillForm(f) {
    $('#f-id').val(f.ID);
    $('#f-cmd_name').val(f.cmd_name);
    $('#f-address').val(f.address);
    $('#f-position').val(f.position);
    updateCmdTypeOptions();
    $('#f-cmd_type').val(f.cmd_type);
    showCmdSection(+f.cmd_type);

    // fill type-specific
    $('#f-direction, #f-direction2, #f-direction5').val(f.direction);
    $('#f-speed, #f-speed2').val(f.speed);
    $('#f-progression').val(f.progression);
    $('#f-duration').val(f.duration);
    $('#f-resolution').val(f.resolution);
    $('#f-steps').val(f.steps);
    $('#f-location_id').val(f.location_id);
    $('#f-location_action').val(f.location_action);
    $('#f-location_data').val(f.location_data);
    $('#f-sound').val(f.sound);
    $('#f-volume').val(f.volume);
    $('#f-replay').val(f.replay);
    $('#f-gpio_pin').val(f.gpio_pin);
    $('#f-light').val(f.light);
    $('#f-red').val(f.red);
    $('#f-green').val(f.green);
    $('#f-blue').val(f.blue);
    $('#f-fade').val(f.fade);
    $('#f-scene').val(f.scene);
  }

  function updateCmdTypeOptions() {
    const devType = +$('#f-address option:selected').data('type') || 1;
    const allowed = allowedCmdTypes(devType);
    const $sel = $('#f-cmd_type').empty();
    allowed.forEach(t => $sel.append(`<option value="${t}">${cmdTypeName(t)}</option>`));
  }

  function showCmdSection(type) {
    $('.cmd-section').hide();
    $(`.cmd-section[data-type="${type}"]`).show();
  }

  $('#f-address').on('change', function() {
    updateCmdTypeOptions();
    showCmdSection(+$('#f-cmd_type').val());
  });
  $('#f-cmd_type').on('change', function() {
    showCmdSection(+$(this).val());
  });

  // ---------- Save / Delete ----------
  $('#btn-save').on('click', function() {
    const type = +$('#f-cmd_type').val();
    const payload = {
      action: $('#f-id').val() > 0 ? 'update' : 'add',
      id: +$('#f-id').val(),
      cmd_name: $('#f-cmd_name').val().trim(),
      address: $('#f-address').val(),
      position: +$('#f-position').val(),
      cmd_type: type,
      // defaults for all fields (required by validateFrame)
      gpio_pin: 0, direction: 1, speed: 0, duration: 0, progression: 0,
      steps: 0, resolution: 1, sound: 0, volume: 25, replay: 0,
      location_id: 0, location_action: 0, location_data: 0,
      light: 0, red: 0, green: 0, blue: 0, fade: 1.0, scene: 0
    };

    // override with visible fields
    if (type === 1) {
      payload.direction = +$('#f-direction').val();
      payload.speed = +$('#f-speed').val();
      payload.progression = +$('#f-progression').val();
      payload.duration = +$('#f-duration').val();
    } else if (type === 2) {
      payload.direction = +$('#f-direction2').val();
      payload.resolution = +$('#f-resolution').val();
      payload.steps = +$('#f-steps').val();
      payload.speed = +$('#f-speed2').val();
    } else if (type === 3) {
      payload.location_id = +$('#f-location_id').val();
      payload.location_action = +$('#f-location_action').val();
      payload.location_data = +$('#f-location_data').val();
    } else if (type === 4) {
      payload.sound = +$('#f-sound').val();
      payload.volume = +$('#f-volume').val();
      payload.replay = +$('#f-replay').val();
    } else if (type === 5) {
      payload.gpio_pin = +$('#f-gpio_pin').val();
      payload.direction = +$('#f-direction5').val();
    } else if (type === 6) {
      payload.light = +$('#f-light').val();
      payload.red = +$('#f-red').val();
      payload.green = +$('#f-green').val();
      payload.blue = +$('#f-blue').val();
      payload.fade = +$('#f-fade').val();
    } else if (type === 7) {
      payload.scene = +$('#f-scene').val();
    }

    if (!payload.cmd_name) { alert('Command name required'); return; }

    apiPost(payload).then(res => {
      if (res && res.status === 'success') {
        $('#frameModal').modal('hide');
        loadAllFrames();
        $('#status-text').text('Frame saved');
      } else {
        alert('Save failed – check server logs / validation');
      }
    }).catch(() => alert('Network / API error'));
  });

  $('#btn-delete').on('click', function() {
    if (!confirm('Delete this frame?')) return;
    apiPost({action:'delete', id:+$('#f-id').val()}).then(res => {
      if (res && res.status === 'success') {
        $('#frameModal').modal('hide');
        loadAllFrames();
        $('#status-text').text('Frame deleted');
      }
    });
  });

  // ---------- Transport ----------
  function setRunning(v) {
    apiPost({action:'setrunning', running: v ? 1 : 0}).then(() => {
      isRunning = v;
      $('#btn-play').prop('disabled', v);
      $('#btn-stop').prop('disabled', !v);
      if (v) startPolling(); else stopPolling();
    });
  }
  function setPosition(p) {
    apiPost({action:'setposition', position: p}).then(() => {
      currentPos = p;
      updatePlayhead();
    });
  }

  function startPolling() {
    stopPolling();
    pollTimer = setInterval(() => {
      apiGet({action:'status'}).then(st => {
        if (!st) return;
        currentPos = +st.position || 0;
        isRunning = +st.running === 1;
        $('#script-name').text(st.current_script || 'Unsaved Script');
        updatePlayhead();
        if (!isRunning) {
          $('#btn-play').prop('disabled', false);
          $('#btn-stop').prop('disabled', true);
          stopPolling();
        }
        // auto-scroll playhead into view
        const $tr = $('#tracks');
        const px = posToPx(currentPos);
        if (px < $tr.scrollLeft() + 50 || px > $tr.scrollLeft() + $tr.width() - 50) {
          $tr.scrollLeft(Math.max(0, px - 100));
        }
      });
    }, 400);
  }
  function stopPolling() {
    if (pollTimer) clearInterval(pollTimer);
    pollTimer = null;
  }

  $('#btn-play').on('click', () => setRunning(true));
  $('#btn-stop').on('click', () => setRunning(false));
  $('#btn-rewind').on('click', () => setPosition(0));
  $('#btn-add').on('click', () => openModal(0));
  $('#btn-refresh').on('click', () => loadDevices());

  // Zoom
  $('#zoom').on('input', function() {
    pxPerTenth = +this.value;
    $('#zoom-label').text(pxPerTenth + ' px/0.1s');
    renderTimeline();
  });

  // ---------- Init ----------
  $(function() {
    loadDevices().then(() => {
      // initial status
      apiGet({action:'status'}).then(st => {
        if (st) {
          currentPos = +st.position || 0;
          isRunning = +st.running === 1;
          $('#script-name').text(st.current_script || 'Unsaved Script');
          updatePlayhead();
          if (isRunning) startPolling();
        }
      });
    });
  });
})();
</script>
</body>
</html>
