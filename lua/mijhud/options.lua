-- Quick options menu
local MOD = {
	LoadName = "OptionMenu",
	
	ToggleKey = KEY_O,
	NavUpKey  = KEY_UP,
	NavDnKey  = KEY_DOWN,
	SetLtKey  = KEY_LEFT,
	SetRtKey  = KEY_RIGHT,
}
MijHUD.LoadModule(MOD)

MOD.SaveFilename = "mijhud-settings.txt"

local itypes = {}
MOD.List_ItemTypes = itypes

itypes.Chk = {
	Draw = function(ob,x,y)
		local f = MijHUD.Options(ob.Var)
		local tex = MijHUD.GetTexture("HUD_OptsUI")
		local col_a = MijHUD.GetColor("Pri_ColA")
		local font = MijHUD.GetFont("HUD_Txt20b")
		scr.DrawTexRectFrag(x, y, 30, 30, tex, col_a, f and 30 or 0, 0, 30, 30)
		scr.DrawText(x+35, y+15, ob.Name, -1, 0, col_a, font)
	end;
	Set = function(ob)
		local f = MijHUD.Options(ob.Var)
		MijHUD.Options(ob.Var, not f)
	end;
	Save = function(ob, tbl)
		tbl[ob.Var] = MijHUD.Options(ob.Var) 
	end;
}
itypes.Num = {
	Draw = function(ob,x,y)
		local val = MijHUD.Options(ob.Var)
		local vstr = Format(ob.Fmt or "%d", val)
		local tex = MijHUD.GetTexture("HUD_OptsUI")
		local col_a = MijHUD.GetColor("Pri_ColA")
		local font = MijHUD.GetFont("HUD_Txt20b")
		local txw, _ = scr.TextSize(vstr, font)
		scr.DrawTexRectFrag(x, y, 30, 30, tex, col_a, 0, 30, 30, 30)
		scr.DrawText(x+35, y+15, vstr, -1, 0, col_a, font)
		scr.DrawRect(x+40+txw, y, 2, 30, col_a)
		scr.DrawText(x+47+txw, y+15, ob.Name, -1, 0, col_a, font)
	end;
	Set = function(ob,dir)
		local val = MijHUD.Options(ob.Var)
		val = dir and val+ob.Step or val-ob.Step
		MijHUD.Options(ob.Var, math.Clamp(val, ob.Min, ob.Max))
	end;
	Save = function(ob, tbl)
		tbl[ob.Var] = MijHUD.Options(ob.Var) 
	end;
}
itypes.Goto = {
	Draw = function(ob,x,y)
		local tex = MijHUD.GetTexture("HUD_OptsUI")
		local col_a = MijHUD.GetColor("Pri_ColA")
		local font = MijHUD.GetFont("HUD_Txt20b")
		scr.DrawTexRectFrag(x, y, 30, 30, tex, col_a, 30, 30, 30, 30)
		scr.DrawText(x+35, y+15, ob.Name, -1, 0, col_a, font)
	end;
	Set = function(ob)
		local pnl = MOD.OptionsWindow
		pnl.MenuStack[#pnl.MenuStack+1] = {
			pnl.Selected, pnl.Offset, ob.Data,
		}
		pnl.Selected, pnl.Offset = 1, 0
	end;
	Save = function(ob, tbl)
		for _, mn in ipairs(ob.Data) do
			local sfn = itypes[mn.Type].Save
			if sfn then sfn(mn, tbl) end
		end
	end;
}
itypes.Back = {
	Draw = function(ob,x,y)
		local tex = MijHUD.GetTexture("HUD_OptsUI")
		local col_a = MijHUD.GetColor("Pri_ColA")
		local font = MijHUD.GetFont("HUD_Txt20b")
		scr.DrawTexRectFrag(x, y, 30, 30, tex, col_a, 0, 60, 30, 30)
		scr.DrawText(x+35, y+15, "(Return)", -1, 0, col_a, font)
	end;
	Set = function(ob)
		local pnl = MOD.OptionsWindow
		local st = pnl.MenuStack[#pnl.MenuStack]
		pnl.MenuStack[#pnl.MenuStack] = nil
		pnl.Selected, pnl.Offset = st[1], st[2]
	end;
}
itypes.Btn = {
	Draw = function(ob,x,y)
		local tex = MijHUD.GetTexture("HUD_OptsUI")
		local col_a = MijHUD.GetColor("Pri_ColA")
		local font = MijHUD.GetFont("HUD_Txt20b")
		scr.DrawTexRectFrag(x, y, 30, 30, tex, col_a, 30, 60, 30, 30)
		scr.DrawText(x+35, y+15, ob.Name, -1, 0, col_a, font)
	end;
	Set = function(ob)
		local mod, fn = ob.Fn:match("^([%w_]+):([%w_]+)$")
		if mod and fn then
			mod = MijHUD[mod]
			fn = mod and mod[fn]
			if fn then fn() end
		end
	end;
}

function MOD.Initialize()
	if not MijHUD.Options.OptionMenu then
		MijHUD.Options.OptionMenu = {}
	end
	MOD.LoadSettings()

	MijHUD.CreateFont("HUD", {
		Name = "Txt20b",
		Font = "OCR A Extended",
		Size = 20,
		--Bold = true
	})
	MijHUD.LoadTextures("HUD", {
		OptsWnd = "mijhud/opts_wnd.png",
		OptsUI = "mijhud/opts_ui.png",
	})

	local optwnd = MijHUD.NewComponent()
	MOD.OptionsWindow = optwnd
	function optwnd:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_OptsWnd")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_s = MijHUD.GetColor("Pri_ColB")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		local opts = self.MenuStack[#self.MenuStack]
		opts = opts and opts[3] or MijHUD.Options.OptionMenu
		for i = 1, 10 do
			local ob = opts[self.Offset+i]
			if not ob then break end
			local ix, iy = x+15, y+14+38*(i-1)
			itypes[ob.Type].Draw(ob, ix+10, iy)
			if i == self.Selected then
				scr.DrawRect(ix, iy, 5, 30, col_s)
			end
		end
	end
	function optwnd:OnInterval()
		if MijHUD.IsKeyPressed(MOD.ToggleKey) then
			self.Visible = not self.Visible
		end
		if not self.Visible then return end

		local opts = self.MenuStack[#self.MenuStack]
		opts = opts and opts[3] or MijHUD.Options.OptionMenu
		if MijHUD.IsKeyPressed(MOD.NavDnKey, 0.2) then
			local msel = math.min(#opts, 10)
			if self.Selected < msel then
				self.Selected = self.Selected + 1
			elseif self.Offset < #opts - 10 then
				self.Offset = self.Offset + 1
			end
		end
		if MijHUD.IsKeyPressed(MOD.NavUpKey, 0.2) then
			if self.Selected > 1 then
				self.Selected = self.Selected - 1
			elseif self.Offset > 0 then
				self.Offset = self.Offset - 1
			end
		end
		if MijHUD.IsKeyPressed(MOD.SetLtKey)
		or MijHUD.IsKeyPressed(MOD.SetRtKey) then
			local ob = opts[self.Selected + self.Offset]
			itypes[ob.Type].Set(ob, MijHUD.IsKeyDown(MOD.SetRtKey))
		end
	end
	local utl = MijHUD.Basic.UtilsDispRt
	local pos_y = utl.Y + utl.H - 32
	local pos_x = utl.X + utl.W - 360
	optwnd:SetViewport(pos_x, pos_y, 360, 400)
	optwnd.Selected, optwnd.Offset = 1, 0
	optwnd.MenuStack = {}
	optwnd.Visible = false
end

function MOD.SaveSettings()
	local data = {}
	for _, mn in ipairs(MijHUD.Options.OptionMenu) do
		local sfn = itypes[mn.Type].Save
		if sfn then sfn(mn, data) end
	end
	file.Write(MOD.SaveFilename, util.TableToJSON(data))
end

function MOD.LoadSettings()
	local json = file.Read(MOD.SaveFilename, "DATA")
	if not json or #json < 1 then return end
	for var, dat in pairs(util.JSONToTable(json)) do
		MijHUD.Options(var, dat)
	end
end

