function onCreate()
	-- background shit
	makeLuaSprite('place', 'place', -600, -300);
	setScrollFactor('place', 0.9, 0.9);
	
	addLuaSprite('place', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end