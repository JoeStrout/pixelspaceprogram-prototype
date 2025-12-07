// Module to draw the planet(s) at any scale.

// Handy units:
globals.cm = 0.01
globals.m = 1
globals.km = 1000

// Constants:
worldRadius = 6000*km

// Main scale control:
scales = [25*cm, m, 3*m, 10*m, 30*m, 100*m, 300*m, km,
  3*km, 10*km, 30*km, 100*km, 300*km, 1000*km]
scaleIdx = 0
pixelScale = scales[scaleIdx]  // m per pixel

rocketImage = file.loadImage("rocket512.png")
rocketIcon = file.loadImage("rocketIcon.png")

rocketSprite = new Sprite
rocketSprite.image = rocketImage
// Note: rocket is ~500 pixels tall, and is assumed to
// be 50 meters tall.  So its native scale is:
rocketSprite.imageScale = 0.1 // m/pixel

// examples:
// scale=1 --> 500 pixels tall --> 0.1 m/pixel
// scale=0.1 --> 50 pixels tall --> 1 m/pixel
// scale=0.01 --> 5 pixels tall --> 10 m/pixel


drawCircle = function(screenCenter, screenRadius, color)
	left = screenCenter[0] - screenRadius
	bottom = screenCenter[1] - screenRadius
	diam = screenRadius * 2
	gfx.fillEllipse left, bottom, diam, diam, color	  
end function

// worldToScreen: given an [x,y] position in absolute (meter) coordinates,
// return the corresponding screen (pixel) coordinates.
worldToScreen = function(pos)
	return [
		(pos[0] - rocketPos[0]) / pixelScale + refScreenPos[0],
		(pos[1] - rocketPos[1]) / pixelScale + refScreenPos[1] ]
end function

// drawWorld: draw the world, relative to a reference
// position (usually the player position).  Given:
//   refScreenPos: [x,y] of the reference on screen (pixels)
//   refWorldPos: [x,y] of the reference relative to the
//     center of the world (meters)
drawWorld = function(refScreenPos, refWorldPos)
	worldCtrPix = [
	  refScreenPos[0] + refWorldPos[0] / pixelScale,
	  refScreenPos[1] + refWorldPos[1] / pixelScale ]
	gfx.clear color.clear
	worldRadPix = worldRadius / pixelScale
	
	if pixelScale <= 100*km then
		// atmosphere:
		drawCircle worldCtrPix, 
		  worldRadPix + 100*km / pixelScale, "#000066"		
		drawCircle worldCtrPix, 
		  worldRadPix + 50*km / pixelScale, "#6633FF"
		drawCircle worldCtrPix, 
		  worldRadPix + 25*km / pixelScale, "#AAAAFF"		
	end if
	// ground:
	drawCircle worldCtrPix, worldRadPix, color.green
end function

// drawRocket: draw our rocket, at the given screen position
// and current scale.  If we're zoomed too far out, switch
// to a constant-size icon.
drawRocket = function(refScreenPos)
	rocketSprite.x = refScreenPos[0]
	rocketSprite.y = refScreenPos[1]
	imgScale = rocketSprite.imageScale / pixelScale
	if imgScale * rocketImage.height > rocketIcon.height then
		rocketSprite.scale = imgScale
		rocketSprite.image = rocketImage
	else
		rocketSprite.scale = 1
		rocketSprite.image = rocketIcon
	end if
end function

drawScaleBar = function
	gfx.line 10, 630, 10+50, 630, color.white, 3
	barSize = 50 * pixelScale
	if barSize >= km then
		s = str(round(barSize/km, 2)) + " km"
	else if barSize >= m then
		s = str(round(barSize, 2)) + " m"
	else
		s = str(round(barSize/cm, 2)) + " cm"
	end if
	gfx.print s, 10, 615, color.white, "small"
end function

_fullOrbitAnglePoints = range(0, 2*pi, 2*pi/64)
drawOrbit = function(orbit, color="#88FFFF")
	lastPoint = null
	for theta in _fullOrbitAnglePoints
		// get the point, in absolute (meter) units
		point = orbit.pointAtGlobalAngle(theta)
		// convert to display units
		point = worldToScreen(point)
		// then draw!
		if lastPoint != null then gfx.line lastPoint.x, lastPoint.y, point.x, point.y, color
		lastPoint = point		
	end for

end function

zoomToScaleIdx = function(scaleIdx)
	if scaleIdx < 0 then scaleIdx = 0
	if scaleIdx >= scales.len then scaleIdx = scales.len - 1
	outer.scaleIdx = scaleIdx
	outer.pixelScale = scales[scaleIdx]
end function	

zoomOut = function; zoomToScaleIdx scaleIdx + 1; end function
zoomIn  = function; zoomToScaleIdx scaleIdx - 1; end function

rocketPos = [0, worldRadius+25]  // position of the rocket in the world, in meters
refScreenPos = [480, 200]  // position of the rocket on screen, in pixels

setup = function
	clear
	display(4).sprites.push rocketSprite
end function

update = function
	drawWorld refScreenPos, [-rocketPos[0], -rocketPos[1]]
	drawRocket refScreenPos
	drawScaleBar
end function

if locals == globals then
	setup
	while true
		update
		k = key.get.code
		if k == 17 or k == 20 then
			zoomOut
		else if k == 18 or k == 19 then
			zoomIn
		else if k == 27 or char(k) == "q" then
			break
		end if
		
	end while
	text.row = 4
end if
