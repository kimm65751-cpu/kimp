--========================================================--
-- EVOMON QA SCANNER
-- Internal Roblox Studio QA Tool
-- Single File Version
--========================================================--

local plugin = plugin

local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------

local Scanner = {}

Scanner.Results = {
	Info = {},
	Warnings = {},
	Critical = {}
}

Scanner.ScannedObjects = 0
Scanner.Running = false


------------------------------------------------------------
-- LOGGER
------------------------------------------------------------

function Scanner:Add(level,message)

	local data = os.date("%X").." | "..message

	if level == "CRITICAL" then
		table.insert(self.Results.Critical,data)

	elseif level == "WARNING" then
		table.insert(self.Results.Warnings,data)

	else
		table.insert(self.Results.Info,data)
	end

	print(level,data)

end



------------------------------------------------------------
-- OBJECT SCANNER
------------------------------------------------------------

function Scanner:ScanObject(obj)

	self.ScannedObjects += 1


	local name = string.lower(obj.Name)


	------------------------------------------------
	-- REMOTES
	------------------------------------------------

	if obj:IsA("RemoteEvent") 
	or obj:IsA("RemoteFunction") then


		self:Add(
			"INFO",
			"Remote encontrado: "
			..obj:GetFullName()
		)

	end



	------------------------------------------------
	-- MODULES
	------------------------------------------------

	if obj:IsA("ModuleScript") then

		self:Add(
			"INFO",
			"Module encontrado: "
			..obj:GetFullName()
		)

	end



	------------------------------------------------
	-- EVOMON DETECTION
	------------------------------------------------

	local keywords = {

		"evomon",
		"pokemon",
		"monster",
		"creature",
		"evolution",
		"capture",
		"battle",
		"combat",
		"damage",
		"inventory",
		"item",
		"quest",
		"npc",
		"spawn",
		"teleport"

	}


	for _,word in ipairs(keywords) do

		if string.find(name,word) then

			self:Add(
				"INFO",
				"Sistema relacionado detectado: "
				..obj:GetFullName()
				.." ["..word.."]"
			)

			break
		end

	end



	------------------------------------------------
	-- SCRIPTS
	------------------------------------------------

	if obj:IsA("Script")
	or obj:IsA("LocalScript")
	or obj:IsA("ModuleScript") then


		local source

		local success,err = pcall(function()

			source = obj.Source

		end)



		if success and source then


			if string.find(source,"while true do") then

				self:Add(
					"WARNING",
					"Posible loop infinito: "
					..obj:GetFullName()
				)

			end



			if string.find(source,"wait%(") then

				self:Add(
					"INFO",
					"Uso de wait detectado: "
					..obj:GetFullName()
				)

			end



			if string.find(source,"RemoteEvent")
			and not string.find(source,"OnServerEvent") then


				self:Add(
					"WARNING",
					"Remote posiblemente sin validación servidor: "
					..obj:GetFullName()
				)

			end


		end

	end


end



------------------------------------------------------------
-- FULL SCAN
------------------------------------------------------------

function Scanner:Start()

	self.Running=true

	self.Results={
		Info={},
		Warnings={},
		Critical={}
	}


	self.ScannedObjects=0


	self:Add(
		"INFO",
		"===== INICIO SCAN EVOMON ====="
	)



	local services={

		game.Workspace,
		game.ReplicatedStorage,
		game.ServerStorage,
		game.ServerScriptService,
		game.StarterGui,
		game.StarterPlayer

	}


	for _,service in ipairs(services) do


		if self.Running then


			self:Add(
				"INFO",
				"Analizando "
				..service.Name
			)


			for _,obj in ipairs(service:GetDescendants()) do


				if not self.Running then
					break
				end


				self:ScanObject(obj)

				task.wait()

			end

		end

	end



	self:Add(
		"INFO",
		"SCAN TERMINADO"
	)


	self.Running=false

end



------------------------------------------------------------
-- LIVE MONITOR
------------------------------------------------------------

function Scanner:Live()

	self:Add(
		"INFO",
		"LIVE MONITOR ACTIVADO"
	)


	game.DescendantAdded:Connect(function(obj)

		self:Add(
			"INFO",
			"Nuevo objeto creado: "
			..obj:GetFullName()
		)

	end)

end



------------------------------------------------------------
-- REPORT TXT
------------------------------------------------------------

function Scanner:GenerateReport()


	local text=""


	text=text..
	"EVOMON QA REPORT\n\n"


	text=text..
	"DATE: "
	..os.date()
	.."\n\n"



	text=text..
	"OBJECTS SCANNED: "
	..Scanner.ScannedObjects
	.."\n\n"



	text=text..
	"========== CRITICAL ==========\n"


	for _,v in ipairs(Scanner.Results.Critical) do

		text=text..v.."\n"

	end



	text=text..
	"\n========== WARNINGS ==========\n"



	for _,v in ipairs(Scanner.Results.Warnings) do

		text=text..v.."\n"

	end



	text=text..
	"\n========== INFO ==========\n"



	for _,v in ipairs(Scanner.Results.Info) do

		text=text..v.."\n"

	end



	local json =
		HttpService:JSONEncode({
			report=text
		})


	plugin:SetSetting(
		"LastReport",
		json
	)



	print(
		"REPORT GENERATED"
	)


	print(text)


end



------------------------------------------------------------
-- SIMPLE TOOLBAR
------------------------------------------------------------


local toolbar =
	plugin:CreateToolbar(
	"Evomon QA"
	)


local button =
	toolbar:CreateButton(
	"Scanner",
	"Open QA Scanner",
	""
	)



button.Click:Connect(function()


	print(
		"===================="
	)

	print(
		"EVOMON QA SCANNER"
	)

	print(
		"Use commands:"
	)

	print(
		"Scanner:Start()"
	)

	print(
		"Scanner:GenerateReport()"
	)


end)



_G.EvomonQA = Scanner


print(
"EVOMON QA SCANNER LOADED"
)
