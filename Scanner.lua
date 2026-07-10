--========================================================--
-- EVOMON QA SCANNER
-- Roblox Studio Internal QA Plugin
-- Single File GUI Version
--========================================================--

local toolbar = plugin:CreateToolbar("Evomon QA")


local button = toolbar:CreateButton(
	"Evomon QA",
	"Abrir Scanner",
	""
)


------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------

local Running = false

local Data = {

	Objects = 0,
	Warnings = 0,
	Critical = 0,
	Modules = 0,
	Remotes = 0,

	Logs = {}

}



------------------------------------------------------------
-- REPORT LOGGER
------------------------------------------------------------

local function Log(level,text)


	local line =
		os.date("%X")
		.." ["
		..level
		.."] "
		..text


	table.insert(Data.Logs,line)


	print(line)


	if level=="WARNING" then
		Data.Warnings +=1
	end


	if level=="CRITICAL" then
		Data.Critical +=1
	end

end



------------------------------------------------------------
-- SCANNER
------------------------------------------------------------

local function ScanObject(obj)


	Data.Objects +=1


	if obj:IsA("ModuleScript") then

		Data.Modules +=1

		Log(
			"INFO",
			"Module: "..obj:GetFullName()
		)

	end



	if obj:IsA("RemoteEvent")
	or obj:IsA("RemoteFunction") then

		Data.Remotes +=1

		Log(
			"INFO",
			"Remote: "..obj:GetFullName()
		)

	end



	local name =
		string.lower(obj.Name)



local keys={

	"evomon",
	"monster",
	"creature",
	"capture",
	"battle",
	"combat",
	"inventory",
	"item",
	"evolution",
	"spawn",
	"npc",
	"teleport"

}



for _,k in ipairs(keys) do


	if string.find(name,k) then


		Log(
			"INFO",
			"Sistema detectado: "
			..obj:GetFullName()
		)


		break

	end

end



end



local function StartScan()


	Data.Objects=0
	Data.Warnings=0
	Data.Critical=0
	Data.Modules=0
	Data.Remotes=0
	Data.Logs={}



	Running=true


	Log(
		"INFO",
		"Inicio auditoría Evomon"
	)



local folders={

	game.Workspace,
	game.ReplicatedStorage,
	game.ServerStorage,
	game.ServerScriptService,
	game.StarterGui,
	game.StarterPlayer

}



for _,folder in ipairs(folders) do


	if not Running then
		break
	end



	for _,obj in ipairs(folder:GetDescendants()) do


		if not Running then
			break
		end



		ScanObject(obj)


		task.wait()

	end


end



Running=false


Log(
	"INFO",
	"Scan terminado"
)


end



------------------------------------------------------------
-- REPORT
------------------------------------------------------------

local function ExportReport()


local report =
"EVOMON QA REPORT\n\n"


.."Fecha: "
..os.date()
.."\n\n"


.."OBJETOS:"
..Data.Objects
.."\n"


.."MODULES:"
..Data.Modules
.."\n"


.."REMOTES:"
..Data.Remotes
.."\n"


.."WARNINGS:"
..Data.Warnings
.."\n"


.."CRITICAL:"
..Data.Critical
.."\n\n"


.."====================\n"



for _,line in ipairs(Data.Logs) do

	report =
	report
	..line
	.."\n"

end



plugin:SetSetting(
	"EvomonQA_Report",
	report
)



print(report)


end



------------------------------------------------------------
-- GUI
------------------------------------------------------------


local info = DockWidgetPluginGuiInfo.new(

	Enum.InitialDockState.Float,

	true,

	false,

	400,

	500,

	300,

	300

)



local widget =
plugin:CreateDockWidgetPluginGui(
"EvomonQA",
info
)


widget.Title =
"Evomon QA Scanner"



local frame =
Instance.new("Frame")

frame.Size =
UDim2.new(1,0,1,0)

frame.BackgroundColor3 =
Color3.fromRGB(35,35,35)

frame.Parent=widget



local function CreateButton(text,y)


local b =
Instance.new("TextButton")


b.Size =
UDim2.new(
0.8,
0,
0,
45
)


b.Position =
UDim2.new(
0.1,
0,
0,
y
)



b.Text=text


b.TextSize=18


b.Parent=frame


return b


end




local title =
Instance.new("TextLabel")


title.Size =
UDim2.new(
1,
0,
0,
50
)


title.Text =
"EVOMON QA SCANNER"


title.TextSize=24


title.Parent=frame




local status =
Instance.new("TextLabel")


status.Position =
UDim2.new(0,0,0,60)


status.Size =
UDim2.new(1,0,0,100)


status.TextSize=16


status.TextColor3 =
Color3.new(1,1,1)


status.Parent=frame




local scan =
CreateButton(
"SCAN GENERAL",
180
)


local live =
CreateButton(
"LIVE MONITOR",
240
)


local stop =
CreateButton(
"STOP",
300
)


local export =
CreateButton(
"EXPORT REPORT",
360
)




scan.MouseButton1Click:Connect(function()


	task.spawn(StartScan)

end)



stop.MouseButton1Click:Connect(function()

	Running=false

	Log(
		"WARNING",
		"Scanner detenido"
	)

end)



export.MouseButton1Click:Connect(function()

	ExportReport()

end)



live.MouseButton1Click:Connect(function()


	Log(
		"INFO",
		"LIVE MONITOR ACTIVADO"
	)



game.DescendantAdded:Connect(function(obj)

	Log(
		"INFO",
		"Nuevo objeto: "
		..obj:GetFullName()
	)

end)



end)




task.spawn(function()

while true do


	status.Text =
	"Objetos: "
	..Data.Objects
	.."\nModules: "
	..Data.Modules
	.."\nRemotes: "
	..Data.Remotes
	.."\nWarnings: "
	..Data.Warnings
	.."\nCritical: "
	..Data.Critical


	task.wait(1)

end


end)




button.Click:Connect(function()

	widget.Enabled =
	not widget.Enabled

end)



print(
"Evomon QA Scanner cargado"
)
