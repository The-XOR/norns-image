-- MIDI Echo Display
-- Simple program to display and echo MIDI messages

engine.name = 'None'

local midi_in_device
local midi_out_device
local last_message = ""
local message_history = {}
local max_history = 8

function init()
  -- Initialize MIDI
  midi_in_device = midi.connect(1)
  midi_out_device = midi.connect(1)
  
  -- Set up MIDI input callback
  midi_in_device.event = midi_event
  
  -- Initialize screen
  screen.clear()
  screen.update()
  
  print("MIDI Echo Display initialized")
end

function midi_event(data)
  local msg = midi.to_msg(data)
  local msg_text = ""
  
  -- Format message based on type
  if msg.type == "note_on" then
    msg_text = "Note ON: " .. msg.note .. " vel:" .. msg.vel .. " ch:" .. msg.ch
  elseif msg.type == "note_off" then
    msg_text = "Note OFF: " .. msg.note .. " ch:" .. msg.ch
  elseif msg.type == "cc" then
    msg_text = "CC: " .. msg.cc .. " val:" .. msg.val .. " ch:" .. msg.ch
  elseif msg.type == "pitchbend" then
    msg_text = "Pitchbend: " .. msg.val .. " ch:" .. msg.ch
  elseif msg.type == "key_pressure" then
    msg_text = "Key Press: " .. msg.note .. " val:" .. msg.val .. " ch:" .. msg.ch
  elseif msg.type == "channel_pressure" then
    msg_text = "Ch Press: " .. msg.val .. " ch:" .. msg.ch
  elseif msg.type == "program_change" then
    msg_text = "Program: " .. msg.val .. " ch:" .. msg.ch
  else
    msg_text = "MIDI: " .. msg.type .. " ch:" .. (msg.ch or "?")
  end
  
  -- Update message history
  table.insert(message_history, 1, msg_text)
  if #message_history > max_history then
    table.remove(message_history, max_history + 1)
  end
  
  last_message = msg_text
  
  -- Echo the raw MIDI data back out
  midi_out_device:send(data)
  
  -- Update screen
  redraw()
  
  print(msg_text)
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0, 10)
  screen.text("MIDI Echo + Display")
  
  screen.level(10)
  screen.move(0, 25)
  screen.text("Last: " .. (last_message or "none"))
  
  screen.level(8)
  for i, msg in ipairs(message_history) do
    if i <= 5 then  -- mostra gli ultimi 5 messaggi
      screen.move(0, 35 + (i * 8))
      local display_msg = msg
      if string.len(msg) > 20 then
        display_msg = string.sub(msg, 1, 17) .. "..."
      end
      screen.text(display_msg)
    end
  end
  
  screen.update()
end

function enc(n, d)
  -- Encoder 1: Select MIDI input device
  if n == 1 then
    local new_device = util.clamp(midi_in_device.id + d, 1, 4)
    if new_device ~= midi_in_device.id then
      midi_in_device = midi.connect(new_device)
      midi_in_device.event = midi_event
      print("MIDI input device: " .. new_device)
    end
  end
  
  -- Encoder 2: Select MIDI output device  
  if n == 2 then
    local new_device = util.clamp(midi_out_device.id + d, 1, 4)
    if new_device ~= midi_out_device.id then
      midi_out_device = midi.connect(new_device)
      print("MIDI output device: " .. new_device)
    end
  end
  
  redraw()
end

function key(n, z)
  if n == 3 and z == 1 then
    -- Clear message history
    message_history = {}
    last_message = ""
    redraw()
    print("Message history cleared")
  end
end

function cleanup()
  -- Cleanup function called when script ends
  if midi_in_device then
    midi_in_device.event = nil
  end
end
