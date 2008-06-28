--Adds an ingame time readout to you PDA and HUD
if not tcs then declare("tcs",{}) end
tcs.clock = {}

tcs.clock.color = gkini.ReadString("colors", "chatcolors.activechannel", "28b4f0")

tcs.clock.PDAformat = gkini.ReadString("tcs", "clock.PDAformat", "!%H:%M %A, %b. %d %Y")
tcs.clock.timeformat = gkini.ReadString("tcs", "clock.timeformat", "!Current time: %H:%M:%S %A, %b. %d %Y")
tcs.clock.HUDformat = gkini.ReadString("tcs", "clock.HUDformat", "!%H:%M")
tcs.clock.freq = gkini.ReadInt("tcs","clock.pollingfreq", 500)
tcs.clock.curstate = gkini.ReadInt("tcs", "clock.enabled", 1)

tcs.clock.PDATime = iup.label{title=gkmisc.date(tcs.clock.PDAformat), font=PDASecondaryInfo.font, fgolor=tabunseltextcolor,alignment="ACENTER"}
tcs.clock.PDAmain = iup.hbox {
	iup.fill{},tcs.clock.PDATime,iup.fill{}
}
tcs.clock.StationTime = iup.label{title=gkmisc.date(tcs.clock.PDAformat), font=StationSecondaryInfo.font, fgolor=tabunseltextcolor,alignment="ACENTER"}
tcs.clock.Stationmain = iup.hbox {
	iup.fill{},tcs.clock.StationTime,iup.fill{}
}
tcs.clock.CapShipTime = iup.label{title=gkmisc.date(tcs.clock.PDAformat), font=CapShipSecondaryInfo.font, fgolor=tabunseltextcolor,alignment="ACENTER"}
tcs.clock.CapShipmain = iup.hbox {
	iup.fill{},tcs.clock.CapShipTime,iup.fill{}
}

tcs.clock.HUDTime = iup.label { title = gkmisc.date(tcs.clock.HUDformat), font = iup.GetNextChild(HUD.selfinfo).font, fgcolor = iup.GetBrother(iup.GetNextChild(HUD.selfinfo)).fgcolor, expand = "HORIZONTAL", alignment = "ACENTER" }
tcs.clock.HUDmain = iup.vbox {
	iup.fill { size = 3 },
	iup.hbox {
		tcs.clock.HUDTime;
		alignment = "ACENTER"
	}
}

function tcs.clock.UpdateTimes()
	if(not pcall(function() tcs.clock.HUDTime.title = gkmisc.date(tcs.clock.HUDformat)end)) then tcs.clock.CreateTimeAreas() end
	tcs.clock.PDATime.title = gkmisc.date(tcs.clock.PDAformat)
	tcs.clock.StationTime.title = gkmisc.date(tcs.clock.PDAformat)
	tcs.clock.CapShipTime.title = gkmisc.date(tcs.clock.PDAformat)
end
tcs.clock.UpdateTimer = Timer()

function tcs.clock.CreateTimeAreas(first)
	if tcs.clock.curstate ~= 1 then return end
	if(not first) then
		tcs.clock.HUDTime = iup.label { title = gkmisc.date(tcs.clock.HUDformat), font = iup.GetNextChild(HUD.selfinfo).font, fgcolor = iup.GetBrother(iup.GetNextChild(HUD.selfinfo)).fgcolor, expand = "HORIZONTAL", alignment = "ACENTER" }
			tcs.clock.HUDmain = iup.vbox {
			iup.fill { size = 3 },
			iup.hbox {
			tcs.clock.HUDTime;
			alignment = "ACENTER"
			}
		}
		iup.Append(HUD.selfinfo, tcs.clock.HUDmain)
		ShowDialog(tcs.clock.HUDmain)
	else
		iup.Append(HUD.selfinfo, tcs.clock.HUDmain)
		iup.Append(tcs.GetRelative(StationCurrentLocationInfo, 1), tcs.clock.Stationmain)
		iup.Append(tcs.GetRelative(PDACurrentLocationInfo, 1), tcs.clock.PDAmain)
		iup.Append(tcs.GetRelative(CapShipCurrentLocationInfo, 1), tcs.clock.CapShipmain)
		ShowDialog(tcs.clock.Stationmain)
		ShowDialog(tcs.clock.PDAmain)
		ShowDialog(tcs.clock.CapShipmain)
		iup.Refresh(tcs.GetRelative(StationCurrentLocationInfo, 1))
		iup.Refresh(tcs.GetRelative(PDACurrentLocationInfo, 1))
		iup.Refresh(tcs.GetRelative(CapShipCurrentLocationInfo, 1))
		ShowDialog(tcs.clock.HUDmain)
	end
end

function tcs.clock:OnEvent()
	tcs.clock.CreateTimeAreas(true)
	tcs.clock.UpdateTimer:SetTimeout(1001 - tonumber(string.sub(gkmisc.GetGameTime(), 8)), function () 
																				if(not pcall(tcs.clock.UpdateTimes)) then tcs.clock.CreateTimeAreas() end
																				tcs.clock.UpdateTimer:SetTimeout(tcs.clock.freq) 
																			end)
	UnregisterEvent(self, "SHIP_SPAWNED")
	UnregisterEvent(self, "SHOW_STATION")
end
RegisterEvent(tcs.clock, "SHIP_SPAWNED")
RegisterEvent(tcs.clock, "SHOW_STATION")

if(GetCharacterID()) then 
	tcs.clock:OnEvent() 
end

function tcs.clock.printtime()
	print("\127" .. tcs.clock.color .. gkmisc.date(tcs.clock.timeformat))
end

RegisterUserCommand("time", tcs.clock.printtime)

local function TableChair(form)
	if form.value ~= "*t" then
		if form.value ~= "!*t" then
			return
		end
	end
	form.value = "Chair"
	return
end
--[[-----------------------------------------Configuration Interface-------------------------------------------]]

local pdaform = iup.text{value=tcs.clock.PDAform,size="200x"}
local hudform = iup.text{value=tcs.clock.HUDform,size="200x"}
local timeform = iup.text{value=tcs.clock.timeform,size="200x"}
local freq = iup.text{value=tcs.clock.freq,size="50x"}
local closeb = iup.stationbutton{title="OK", action=function()
										HideDialog(tcs.clock.maindlg)
										TableChair(pdaform)
										TableChair(timeform)
										TableChair(hudform)
										gkini.WriteString("tcs", "clock.PDAformat",pdaform.value)
										gkini.WriteString("tcs", "clock.timeformat",timeform.value)
										gkini.WriteString("tcs", "clock.HUDformat",hudform.value)
										gkini.WriteInt("tcs","clock.pollingfreq", tonumber(freq.value))
										tcs.clock.PDAformat = pdaform.value
										tcs.clock.timeformat = timeform.value
										tcs.clock.HUDformat = hudform.value
										tcs.clock.freq = tonumber(freq.value)
										ShowDialog(tcs.ui.confdlg, iup.CENTER, iup.CENTER)
									end}
local cancelb = iup.stationbutton{title="Cancel", action=function()
										HideDialog(tcs.clock.maindlg)
										pdaform.value = tcs.clock.PDAformat
										timeform.value = tcs.clock.timeformat
										hudform.value = tcs.clock.HUDformat
										freq.value = tcs.clock.freq
										ShowDialog(tcs.ui.confdlg, iup.CENTER, iup.CENTER)
									end}
									
local function OpenHelp()
	StationHelpDialog:Open(
[[On this menu you can adjust settings for the clock displayed in your interface. 
The various format options help adjust how the time is displayed, and "Update Frequency" adjusts the granularity of the time update command. A lower number here updates the time counters more often. It's suggested you keep this in multiples or factors of your chosen precision settings.

The format options follow the same syntax as lua's os.date() function, and more specifically, VO's gkmisc.GetGameTime() function. All times are based off your local system clock.
For any questions on syntax, please look below:

	%a	abbreviated weekday name (e.g., Wed)
	%A	full weekday name (e.g., Wednesday)
	%b	abbreviated month name (e.g., Sep)
	%B	full month name (e.g., September)
	%c	date and time (e.g., 09/16/98 23:48:10)
	%d	day of the month (16) [01-31]
	%H	hour, using a 24-hour clock (23) [00-23]
	%I	hour, using a 12-hour clock (11) [01-12]
	%M	minute (48) [00-59]
	%m	month (09) [01-12]
	%p	either "am" or "pm" (pm)
	%S	second (10) [00-61]
	%w	weekday (3) [0-6 = Sunday-Saturday]
	%x	date (e.g., 09/16/98)
	%X	time (e.g., 23:48:10)
	%Y	full year (1998)
	%y	two-digit year (98) [00-99]
	%%	the character '%'
When no format is specified, the plugin will default to the %c format, adding a '!' in front of the format string will convert the output time into UTC/GMT

The year format is, and will be, based on VO ingame year. It won't change, no matter how much you forget which year it is in real life.]])
end
local helpclose = iup.hbox{iup.stationbutton{title="Help", hotkey=iup.K_h, action=function() OpenHelp() end}, iup.fill{}, closeb, cancelb}

local mainv = {
	iup.hbox{iup.label{title="PDA Format:"},iup.fill{},pdaform},
	iup.hbox{iup.label{title="HUD Format:"},iup.fill{},hudform},
	iup.hbox{iup.label{title="/time Format:"},iup.fill{},timeform},
	iup.hbox{iup.label{title="Update Frequency:"},iup.fill{},freq},
	iup.fill{},
	helpclose
}

tcs.clock.maindlg = tcs.ConfigConstructor("VO Clock Config", mainv, {defaultesc = closeb})

function tcs.clock.maindlg:init()
	tcs.clock.PDAformat = gkini.ReadString("tcs", "clock.PDAformat", "!%H:%M %A, %b. %d %Y")
	tcs.clock.timeformat = gkini.ReadString("tcs", "clock.timeformat", "!Current time: %H:%M:%S %A, %b. %d %Y")
	tcs.clock.HUDformat = gkini.ReadString("tcs", "clock.HUDformat", "!%H:%M")
	tcs.clock.freq = gkini.ReadInt("tcs","clock.pollingfreq", 500)
	pdaform.value = tcs.clock.PDAformat
	timeform.value = tcs.clock.timeformat
	hudform.value = tcs.clock.HUDformat
	freq.value = tcs.clock.freq
end

--State modification function.
function tcs.clock.state(_, v)
	if v == 1 then
		tcs.clock.maindlg:init()
		tcs.clock.curstate = 1
		tcs.clock.CreateTimeAreas(true)
		gkini.WriteInt("tcs", "clock.enabled", 1)
	elseif v == 0 then
		iup.Detach(tcs.clock.PDAmain)
		iup.Detach(tcs.clock.HUDmain)
		iup.Detach(tcs.clock.Stationmain)
		iup.Detach(tcs.clock.CapShipmain)
		iup.Refresh(tcs.GetRelative(StationCurrentLocationInfo, 1))
		iup.Refresh(tcs.GetRelative(PDACurrentLocationInfo, 1))
		iup.Refresh(tcs.GetRelative(CapShipCurrentLocationInfo, 1))
		tcs.clock.curstate = 0
		gkini.WriteInt("tcs", "clock.enabled", 0)
	elseif v == -1 then
		return tcs.IntToToggleState(tcs.clock.curstate)
	end
	return
end
--Make the configuration menu available to TCS
tcs.ProvideConfig("VO Clock", tcs.clock.maindlg, "Adds a clock to your HUD and PDA.",tcs.clock.state)