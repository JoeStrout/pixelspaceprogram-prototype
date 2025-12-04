// Pixel Space Program

clear
import "worldRenderer"

// Rocket stands 25 m above the ground:
rocketPos = [0, worldRenderer.worldRadius + 25]


checkInputs = function
	if key.available then
		k = key.get
		if k == "=" or k == "+" or k == "]" then
			worldRenderer.zoomIn
		else if k == "-" or k == "[" or k == "/" then
			worldRenderer.zoomOut
		else if k == char(27) then
			exit
		end if
	end if
end function

main = function
	while true
		yield
		worldRenderer.update
		checkInputs
	end while
end function


main
