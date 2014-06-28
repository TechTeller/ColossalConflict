-- Quintinity's Timer Module --
timers = {};

--[[
	Timer Data Structure:

	{
		executeImmediately [boolean] -- execute callback immediately or not (INTERVAL timers only)
		duration [float], -- callback gets triggered at the end of the duration (DURATION timers only)
		interval [float], -- the duration between intervals (INTERVAL timers only)
		loops [int], -- how many times to execute the loop, -1 for infinite (INTERVAL timers only)
		callback [function(timer)]
	}
]]--

--TODO: infinite timers

--- Timer Types ---
DURATION = 0;
INTERVAL = 1;
-------------------

function CreateTimer(name, timerType, timerData)
	timerData.startTime = Time();
	timerData.name = name;
	timerData.timerType = timerType;

	if timerType == DURATION then
		timerData.endTime = timerData.startTime + timerData.duration;
	elseif timerType == INTERVAL then
		timerData.nextInterval = Time() + timerData.interval;
		if not timerData.executeImmediately then
			timerData.executeImmediately = false;
		elseif timerData.executeImmediately then
			timerData.callback(timerData);
		end
		if not timerData.onExpired then
			timerData.onExpired = (function(t) end);
		end
	else
		print("Invalid timer type for " .. name);
		return;
	end

	timers[name] = timerData;
end

--this needs to be called every 0.1 seconds or so
function UpdateTimers()
	for k, timer in pairs(timers) do
		if timer.timerType == DURATION then
			if Time() >= timer.endTime then
				timer.callback(timer);
				DeleteTimer(timer.name);
			end
		elseif timer.timerType == INTERVAL then
			if timer.interval == 0.1 then
				timer.callback(timer);
				if timer.loops ~= -1 then
					timer.loops = timer.loops - 1;
					if timer.loops <= 0 then
						timer.onExpired(timer);
						DeleteTimer(timer.name);
					end
				end
			elseif Time() >= timer.nextInterval then
				timer.callback(timer);
				timer.nextInterval = Time() + timer.interval;
				if timer.loops ~= -1 then
					timer.loops = timer.loops - 1;
					if timer.loops <= 0 then
						DeleteTimer(timer.name);
					end
				end
			end
		end
	end
end

function DeleteTimer(name)
	timers[name] = nil;
end