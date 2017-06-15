--- === PushToTalk ===
---
--- While the mic is hot, holding ⌥ will mute, while muted, opposite
--- Double-tapping ⌥ will toggle muted/hot and show a notification

local obj = {}
obj.__index = obj

-- Metadata
obj.name = 'PushToTalk'
obj.version = '0.1'
obj.author = 'Adam Jahnke <adamyonk@me.com>'
obj.homepage = 'https://github.com/adamyonk/PushToTalk.spoon'
obj.license = 'MIT - https://opensource.org/licenses/MIT'

function obj:init()
  local lastMods = {}
  local recentlyClicked = false
  local secondClick = false

  local displayStatus = function()
    -- Check if the active mic is muted
    if hs.audiodevice.defaultInputDevice():muted() then
      hs.notify.show('PushToTalk', '', 'muted 🎤')
    else
      hs.notify.show('PushToTalk', '', 'hot 🎤')
    end
  end
  displayStatus()

  local toggle = function(device)
    if device:muted() then
      device:setMuted(false)
    else
      device:setMuted(true)
    end
  end

  local functionKeyHandler = function()
    recentlyClicked = false
  end

  local functionKeyTimer = hs.timer.delayed.new(0.3, functionKeyHandler)

  local functionHandler = function(event)
    local device = hs.audiodevice.defaultInputDevice()
    local newMods = event:getFlags()

    -- fn keyDown
    if newMods['fn'] == true then
      toggle(device)
      if recentlyClicked == true then
        displayStatus()
        secondClick = true
      end
      recentlyClicked = true
      functionKeyTimer:start()

    -- fn keyUp
    elseif lastMods['fn'] == true and newMods['fn'] == nil then
      if secondClick then
        secondClick = false
      else
        toggle(device)
      end
    end

    lastMods = newMods
  end

  self.functionKey = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, functionHandler)
  -- It seems that obj:start() isn't always called? ¯\_(ツ)_/¯
  self.functionKey:start()
end

function obj:start()
  self.functionKey:start()
end

function obj:stop()
  self.functionKey:stop()
end

return obj
