local MOD = {
	LoadName = "GameText",
}
MijHUD.LoadModule(MOD)

function MOD.Initialize()
	MijHUD.CreateFont("HUD", {
		Name = "GameMsg",
		Font = "OCR A Extended",
		Size = 18,
		--Bold = true,
	})
	MijHUD.LoadTextures("HUD", {
		GameMsg = "mijhud/gametext.png",
	})

	hook.Add("GameText.Display", "MijHUD.GameText.Display", MOD.GameTextDisplay)

	local mbtex = MijHUD.GetTexture("HUD_GameMsg")
	local msgbox = scr.BorderBox(0, 0, 100, 100, mbtex, 20, 20, 20, 20)

	local pnlmsg = MijHUD.NewComponent()
	MOD.MessagePanel = pnlmsg
	pnlmsg.MessageBox = msgbox
	function pnlmsg:OnRender(x,y,w,h)
		local font = MijHUD.GetFont("HUD_GameMsg")

		local tCi = self.Time.Char
		local tHd = self.Time.Hold
		local tFa = self.Time.Fade

		local ky = y
		for i = 16, 1, -1 do
			local msg = self.Messages[i]
			if not msg then continue end

			local dt = RealTime()-msg.InitTime
			local iw, ih = scr.TextSize(msg.Text, font)

			local col_f = ColorAlpha(msg.Color, 255)
			local bh, bs, bv = msg.Color:ToHSV()
			local col_b = HSVToColor(bh, bs, bv*0.65)
			local kText, kLen = msg.Text, utf8.len(msg.Text)

			local tChr = tCi
			local tStr = kLen*tCi
			if msg.IsScanOut then
				tStr = msg.FxTime
				tChr = tStr/kLen
			end

			if dt > tFa+tHd+tStr then
				self.Messages[i] = nil
				continue
			elseif dt > tStr+tHd then
				local a = 255*(1-(dt-tStr-tHd)/tFa)
				col_f.a, col_b.a = a, a
			elseif dt < tStr then
				local cn = math.floor(dt/tChr)
				kText = kText:sub(1, cn)
			end

			self.MessageBox(x-iw/2-15, ky-ih-12, iw+30, ih+24, col_b)
			scr.DrawTextEx(x-iw/2, ky-ih, kText, -1, col_f, font)

			ky = ky-(ih+30)
		end
	end
	function pnlmsg:AddMessage(data)
		data.InitTime = RealTime()
		self.Messages[data.Channel] = data
	end
	pnlmsg:SetViewport(ScrW()/2, ScrH()-100, 600, 0)
	pnlmsg.Time = { Char = 0.015, Hold = 1.5, Fade = 0.5 }
	pnlmsg.Messages = {}
end

function MOD.GameTextDisplay(data)
	if MijHUD.IsShown and not data.IsPaper then
		MOD.MessagePanel:AddMessage(data)
		return true
	end
end

