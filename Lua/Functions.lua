--This is a quick fix for alarms:

_alarm = {}
_alarm[1] = 0;
_alarm[2] = 0;

function alarm(n,m)
	_alarm[n] = m;
	return true;
end

function alarmProccess()
	--Recode this:
	_alarm[1]=_alarm[1]-1;
	if(_alarm[1] == 0)then onAlarm1();end
	_alarm[2]=_alarm[2]-1;
	if(_alarm[2] == 0)then onAlarm2();end
end
