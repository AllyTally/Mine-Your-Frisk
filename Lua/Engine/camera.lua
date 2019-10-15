_camera = {}

_camera.x = 0
_camera.y = 0
_camera.oldx = 0
_camera.oldy = 0

_camera.attached = {}
_camera.attachedtext = {}

function _camera.Update()
    if (_camera.x ~= _camera.oldx) or (_camera.y ~= _camera.oldy) then
        _camera.MoveCamera(_camera.x,_camera.y)
    end
end

function _camera.Attach(spr)
    spr["realx"] = spr.x
    spr["realy"] = spr.y
    table.insert(_camera.attached,spr)
end

function _camera.AttachText(txt,pos)
    table.insert(_camera.attachedtext,{txt,pos})
end

function _camera.Detach(spr)
    for i=1, #_camera.attached do
        if _camera.attached[i] == spr then
            table.remove(_camera.attached,i)
        end
    end
end

function _camera.DetachText(txt)
    for i=#_camera.attachedtext,1,-1 do
        if _camera.attachedtext[i][1] == txt then
            table.remove(_camera.attachedtext,i)
        end
    end
end

function _camera.GetTextIndex(txt)
    for i=#_camera.attachedtext,1,-1 do
        if _camera.attachedtext[i][1] == txt then
            return i
        end
    end
end


function _camera.MoveCamera(x,y)
    if x < 0 then x = 0 end
    if y < 0 then y = 0 end
    _camera.x = x
    _camera.y = y
    _camera.oldx = x
    _camera.oldy = y
    Misc.cameraX = x 
    Misc.cameraY = y
    for i=1, #_camera.attached do
        _camera.attached[i].x = _camera.attached[i]["realx"] + x
        _camera.attached[i].y = _camera.attached[i]["realy"] + y
    end
    for i=1, #_camera.attachedtext do
        _camera.attachedtext[i][1].x = _camera.attachedtext[i][2][1] + x
        _camera.attachedtext[i][1].y = _camera.attachedtext[i][2][2] + y
    end
end

return _camera