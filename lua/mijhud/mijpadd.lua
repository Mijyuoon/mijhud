local MOD = {
	LoadName = "PADDSystem",
}
MijHUD.LoadModule(MOD)

function MOD.Initialize()
	local utils_rt = MijHUD.Basic.UtilsDispRt
	function utils_rt:CustomDrawFunc(x,y,w,h)
		local font = MijHUD.GetFont("HUD_Txt30")
		local col_m = MijHUD.GetColor("Pri_ColA")
		
		local padd = LocalPlayer().MijPADD
		if IsValid(padd) and padd:IsOnline() then
			scr.DrawText(x+w-38, y+82, "PADD ONLINE", 1, -1, col_m, font)
		end
	end
end
