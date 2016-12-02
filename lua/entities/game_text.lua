AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_point"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Message", { KeyName = "message" })
	self:NetworkVar("Int", 0, "Channel", { KeyName = "channel" })

	self:NetworkVar("Float", 0, "PosX", { KeyName = "x" })
	self:NetworkVar("Float", 1, "PosY", { KeyName = "y" })

	self:NetworkVar("Vector", 0, "MsgColor", { KeyName = "color" })
	self:NetworkVar("Vector", 1, "FxColor", { KeyName = "color2" })

	self:NetworkVar("Float", 2, "FadeIn", { KeyName = "fadein" })
	self:NetworkVar("Float", 3, "FadeOut", { KeyName = "fadeout" })
	self:NetworkVar("Float", 4, "HoldTime", { KeyName = "holdtime" })
	self:NetworkVar("Float", 5, "FxTime", { KeyName = "fxtime" })
	self:NetworkVar("Int", 1, "Effect", { KeyName = "effect" })
end

if SERVER then
	util.AddNetworkString("game_text.Display")

	function ENT:KeyValue(name, value)
		self:SetNetworkKeyValue(name, value)
	end

	function ENT:AcceptInput(name, activator, _, _)
		if name:lower() == "display" then
			self:Display(activator)
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Display(ply)
		if hook.Run("GameText.Display", self) then return end
		net.Start("game_text.Display")
		net.WriteEntity(self)
		if not ply or self.AllPlayers then
			net.Send(player.GetAll())
		elseif ply:IsPlayer() then
			net.Send(ply)
		end
	end
end

if CLIENT then
	net.Receive("game_text.Display",
	function()
		local ent = net.ReadEntity()
		if ent.Display then
			ent:Display()
		end
	end)

	local channels = {}
	hook.Add("HUDPaint", "game_text.Draw",
	function()
		for i = 1, 16 do
			local ent = channels[i]
			if ent and ent:DrawText() then
				ent.Data, ent.InitTime = nil
				channels[i] = nil
			end
		end
	end)

	hook.Add("InitPostEntity", "game_text.Init",
	function()
		scr.CreateFont("GameText_Default", "Default", 26)
	end)

	ENT.Font = "GameText_Default"
	ENT.BlinkTime = 0.3

	function ENT:Display()
		local col = self:GetMsgColor()
		local data = {
			Text = self:GetMessage(),
			X = self:GetPosX(),
			Y = self:GetPosY(),
			Color = Color(col.x, col.y, col.z),
			FadeIn = self:GetFadeIn(),
			FadeOut = self:GetFadeOut(),
			Hold = self:GetHoldTime(),
			Channel = self:GetChannel(),
		}
		local fx = self:GetEffect()
		if fx > 0 then
			local col = self:GetFxColor()
			data.FxColor = Color(col.x, col.y, col.z)
			data.FxTime = self:GetFxTime()
		end
		if fx == 2 then
			data.IsScanOut = true
		elseif fx > 10 and fx < 110 then
			local paper = paperlib["PAPER_"..(fx-10)]
			if not paper then return end
			paperlib.SetPaper(paper)
			paperlib.Display(data.Text)
			data.IsPaper = true
		end

		if hook.Run("GameText.Display", data) then return end
		if fx > 10 and fx < 110 then return end

		self.InitTime, self.Data = RealTime(), data
		channels[self:GetChannel()] = self
	end

	function ENT:DrawText()
		local dat = self.Data
		local ti = RealTime()-self.InitTime

		local tw, th = scr.TextSize(dat.Text, self.Font)
		local x = (dat.X == -1) and (ScrW()-tw)/2 or ScrW()*dat.X
		local y = (dat.Y == -1) and (ScrH()-th)/2 or ScrH()*dat.Y

		if dat.IsScanOut then
			local kCol = ColorAlpha(dat.Color, 255)
			local kText = dat.Text

			local t2 = dat.Hold+dat.FxTime
			local t3 = dat.FadeOut+t2

			if ti > t3 then
				return true
			elseif ti > t2 then
				kCol.a = 255*(1-(ti-t2)/dat.FadeOut)
			elseif ti < dat.FxTime then
				local cn = #kText*(ti/dat.FxTime)
				kText = kText:sub(1, math.floor(cn))

				--if ti % self.BlinkTime < self.BlinkTime/2 then
					local tw, th = scr.TextSize(kText, self.Font)
					scr.DrawRect(x+tw+3, y, 4, th, dat.FxColor)
				--end
			end

			scr.DrawText(x, y, kText, -1, -1, kCol, self.Font)
		else
			local kCol = ColorAlpha(dat.Color, 255)

			local t2 = dat.Hold+dat.FadeIn
			local t3 = dat.FadeOut+t2

			if ti > t3 then
				return true
			elseif ti > t2 then
				kCol.a = 255*(1-(ti-t2)/dat.FadeOut)
			elseif ti < dat.FadeIn then
				kCol.a = 255*(ti/dat.FadeIn)
			end

			scr.DrawTextEx(x, y, dat.Text, -1, kCol, self.Font)
		end
	end
end

