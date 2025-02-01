local xx = 700;
local yy = -2000;
local xx2 = 1634.05;
local yy2 = -54.3;

function onCreate()
    -- nothing!!!!!!!
end

function onUpdate()
    if curStep == 1 then
        setProperty('defaultCamZoom',0.3)
		followchars = true
        xx = 1634.05
        yy = -54.3
        xx2 = 1634.05
        yy2 = -54.3
    end
    if curBeat == 64 then
        setProperty('defaultCamZoom', 0.4)
        followchars = true
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 96 then
        setProperty('defaultCamZoom', 0.6)
        followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 128 then
        setProperty('defaultCamZoom', 0.4)
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 155 then
        setProperty('defaultCamZoom', 0.8)
        followchars = true
        xx = 450
        yy = 150
        xx2 = 450
        yy2 = 150
    end
    if curBeat == 160 then
        setProperty('defaultCamZoom', 0.4)
        followchars = true
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 192 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 256 then
        setProperty('defaultCamZoom', 0.4)
        followchars = true
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 288 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 320 then
        setProperty('defaultCamZoom', 0.3)
        followchars = true
        xx = 1634.05
        yy = -54.3
        xx2 = 1634.05
        yy2 = -54.3
    end
    if curBeat == 384 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
end