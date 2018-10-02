--[[---------------------------------------------
	ScrLib (C) Mijyuoon 2014-2020
	Contains useful drawing functions
-----------------------------------------------]]

if scr then return end

local mat_lit2d = CreateMaterial("Lit2D", "VertexLitGeneric", {
	["$basetexture"] = "", ["$translucent"] = 1,
})
local mat_pngrt = CreateMaterial("PngRT", "UnlitGeneric", {
	["$basetexture"] = "", ["$ignorez"] = 1, ["$model"] = 1,
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1,
})
local mat_gui0 = CreateMaterial("Gui0", "UnlitGeneric", {
	["$basetexture"] = "", ["$ignorez"] = 1,
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1,
})
scr = {
	-- Constants
	LIT_2D = mat_lit2d,
	PNG_RT = mat_pngrt,
	GUI_0  = mat_gui0,
}

function scr.Clear(col)
    render.Clear(col.r,col.g,col.b,col.a)
end

function scr.EnableTexture(tex)
	local m_type = type(tex)
	if m_type == "IMaterial" then
		surface.SetMaterial(tex)
	elseif m_type == "number" then
		surface.SetTexture(tex)
	elseif not tex then
		surface.SetTexture(0)
	end
end

function scr.DrawRect(x,y,w,h,col)
    surface.SetDrawColor(col)
    surface.DrawRect(x,y,w,h)
end

function scr.DrawTexRect(x,y,w,h,tex,col)
	surface.SetDrawColor(col or color_white)
	scr.EnableTexture(tex)
	surface.DrawTexturedRectRotated(x+w/2,y+h/2,w,h,0)
end

function scr.DrawTexRectUV(x,y,w,h,tex,col,ul,vl,uh,vh)
	surface.SetDrawColor(col or color_white)
	scr.EnableTexture(tex)
	--[[ -- No idea.
	local rw = tex:GetInt("$realwidth") or tex:Width()
	local rh = tex:GetInt("$realheight") or tex:Height()
	ul = (ul < 1e-7) and ul-0.5/rw or ul
	vl = (vl < 1e-7) and vl-0.5/rh or vl
	uh = (1 - uh < 1e-7) and uh+0.5/rw or uh
	vh = (1 - vh < 1e-7) and vh+0.5/rh or vh
	--]]
	surface.DrawTexturedRectUV(x,y,w,h, ul,vl, uh,vh)
end

function scr.DrawTexRectFrag(x,y,w,h,tex,col,x0,y0,w0,h0)
	surface.SetDrawColor(col or color_white)
	scr.EnableTexture(tex)
	local rw = tex:GetInt("$realwidth") or tex:Width()
	local rh = tex:GetInt("$realheight") or tex:Height()
	local ul, vl = x0/(rw-1), y0/(rh-1)
	local uh, vh = (x0+w0-1)/(rw-1), (y0+h0-1)/(rh-1)
	--[[ -- No idea.
	ul = (ul < 1e-7) and ul-0.5/rw or ul
	vl = (vl < 1e-7) and vl-0.5/rh or vl
	uh = (1 - uh < 1e-7) and uh+0.5/rw or uh
	vh = (1 - vh < 1e-7) and vh+0.5/rh or vh
	--]]
	surface.DrawTexturedRectUV(x,y,w,h, ul,vl, uh,vh)
end

function scr.DrawLine(x1,y1,x2,y2,col,sz)
	if x1 > x2 then
		x1, y1, x2, y2 = x2, y2, x1, y1
	end
	if y1 > y2 then
		x1, y1, x2, y2 = x2, y2, x1, y1
	end
    surface.SetDrawColor(col)
    if x1 == x2 then
        -- vertical lines
        local wid = (sz or 1) / 2
        surface.DrawRect(x1-wid, y1, wid*2, y2-y1)
    elseif y1 == y2 then
        -- horizontal lines
        local wid = (sz or 1) / 2
        surface.DrawRect(x1, y1-wid, x2-x1, wid*2)
    else
        -- non-axial lines
        local x3 = (x1 + x2) / 2
        local y3 = (y1 + y2) / 2
        local wx = math.sqrt((x2-x1) ^ 2 + (y2-y1) ^ 2)
        local angle = math.deg(math.atan2(y1-y2, x2-x1))
        surface.SetTexture(0)
        surface.DrawTexturedRectRotated(x3, y3, wx, (sz or 1), angle)
    end
end

function scr.DrawRectOL(x,y,w,h,col,sz)
    sz = math.floor(sz) or 1
    surface.SetDrawColor(col)
    if sz < 0 then
    	for i = 0, -sz-1 do
    		surface.DrawOutlinedRect(x-i, y-i, w+2*i, h+2*i)
		end
    elseif sz > 0 then
    	for i = 0, sz-1 do
    		surface.DrawOutlinedRect(x+i, y+i, w-2*i, h-2*i)
		end
    end
end

function scr.Circle(dx,dy,rx,ry,rot,fi)
	local rot2, fi = math.rad(rot or 0), (fi or 45)
    local vert, s, c = {}, math.sin(rot2), math.cos(rot2)
    for ii = 0, fi do
        local ik = math.rad(ii*360/fi)
        local x, y = math.cos(ik), math.sin(ik)
        local xs = x * rx * c - y * ry * s + dx
        local ys = x * rx * s + y * ry * c + dy
        vert[#vert+1] = { x = xs, y = ys }
    end
    return vert
end

function scr.Sector(dx,dy,rx,ry,ang,rot,fi)
	local rot2, fi = math.rad(rot or 0), (fi or 45)
    local vert, s, c = {}, math.sin(rot2), math.cos(rot2)
	vert[1] = { x = dx, y = dy }
	for ii = 0, fi do
		local ik = math.rad(ii*ang/fi)
        local x, y = math.cos(ik), math.sin(ik)
        local xs = x * rx * c - y * ry * s + dx
        local ys = x * rx * s + y * ry * c + dy
        vert[#vert+1] = { x = xs, y = ys }
    end
    return vert
end

function scr.Poly(xr,yr,argv)
    local vert = {}
    for i=1, #argv, 2 do
        local xs, ys = (argv[i] or 0), (argv[i+1] or 0)
        vert[#vert+1] = { x = xs+xr, y = ys+yr }
    end
    return vert
end

function scr.BorderBox(ix,iy,iw,ih,tex,l,t,r,b)
	local rw = tex:GetInt("$realwidth") or tex:Width()
	local rh = tex:GetInt("$realheight") or tex:Height()
	local il, it, ir, ib = l/rw, t/rh, r/rw, b/rh
	ix, iy, iw, ih = ix/rw, iy/rh, iw/rw, ih/rh

	return function(x,y,w,h,col)
		surface.SetDrawColor(col or color_white)
		scr.EnableTexture(tex)

		-- Top row
		surface.DrawTexturedRectUV(x, y, l, t, ix, iy, ix+il, iy+it)
		surface.DrawTexturedRectUV(x+l, y, w-l-r, t, ix+il, iy, ix+iw-ir, iy+it)
		surface.DrawTexturedRectUV(x+w-r, y, r, t, ix+iw-ir, iy, ix+iw, iy+it)

		-- Middle row
		surface.DrawTexturedRectUV(x, y+t, l, h-t-b, ix, iy+it, ix+il, iy+ih-ib)
		surface.DrawTexturedRectUV(x+l, y+t, w-l-r, h-t-b, ix+il, iy+it, ix+iw-ir, iy+ih-ib)
		surface.DrawTexturedRectUV(x+w-r, y+t, r, h-t-b, ix+iw-ir, iy+it, ix+iw, iy+ih-ib)

		-- Bottom row
		surface.DrawTexturedRectUV(x, y+h-b, l, b, ix, iy+ih-ib, ix+il, iy+ih)
		surface.DrawTexturedRectUV(x+l, y+h-b, w-l-r, b, ix+il, iy+ih-ib, ix+iw-ir, iy+ih)
		surface.DrawTexturedRectUV(x+w-r, y+h-b, r, b, ix+iw-ir, iy+ih-ib, ix+iw, iy+ih)
	end
end

function scr.DrawTri(x1,y1,x2,y2,x3,y3,col)
	local verts = {
		{ x = x1, y = y1 },
		{ x = x2, y = y2 },
		{ x = x3, y = y3 },
	}
	scr.DrawPoly(verts,col)
end

function scr.DrawPoly(poly,col,tex)
    surface.SetDrawColor(col or color_white)
	scr.EnableTexture(tex)
    surface.DrawPoly(poly)
end

function scr.DrawPolyOL(poly,col,sz)
    for i=1, #poly do
        local va, vb = poly[i], (poly[i+1] or poly[1])
        scr.DrawLine(va.x, va.y, vb.x, vb.y, col, sz)
    end
end

function scr.DrawQuadUnlit(pos, norm, wid, hgt, tex, ang)
	render.SetMaterial(tex)
	render.DrawQuadEasy(pos, norm, wid, hgt, nil, ang or 180)
end

function scr.DrawQuadLit2D(pos, norm, wid, hgt, tex, ang)
	local lm = render.ComputeLighting(pos, norm)
	render.SetLightingOrigin(pos)
	render.ResetModelLighting(lm.x, lm.y, lm.z)
	local vtex = tex:GetTexture("$basetexture")
	mat_lit2d:SetTexture("$basetexture", vtex)
	scr.DrawQuadUnlit(pos, norm, wid, hgt, mat_lit2d, ang)
	render.SuppressEngineLighting(false)
end

local function proctex(tex, target)
	local m_type = type(tex)
	if m_type == "IMaterial" then
		tex = tex:GetTexture("$basetexture")
		target:SetTexture("$basetexture", tex)
	elseif m_type == "ITexture" then
		target:SetTexture("$basetexture", tex)
	end
	return target
end

function scr.PngToRT(tex)
	return proctex(tex, mat_pngrt)
end

function scr.TexGui0(tex)
	return proctex(tex, mat_gui0)
end

local font_bits = {
	"antialias",
	"additive",
	"shadow",
	"outline",
	"rotary",
	"underline",
	"italic",
	"strikeout",
	"extended",
}

local function mangle_font(fd)
	local bits = ""
	for _, kv in ipairs(font_bits) do
		bits = bits .. (fd[kv] and "1" or "0")
	end
	return string.format("%q_%d,%d_%d,%d_%s",
		fd.font, fd.size, fd.weight, fd.blursize or 0, fd.scanlines or 0, bits)
end

local fonts_cache = {}
adv.FONTS_CACHE = fonts_cache

function scr.CreateFont(name,font,size,weight,params)
	local fdata = {
		font	= font,
		size	= size or 12,
		weight	= weight or 400,
	}
	if isstring(params) then
		local options = {}
		for _, s in ipairs(params:Split(",")) do
			local k, v = s:match("(%w+)=(%d+)")
			options[k or s] = tonumber(v) or true
		end
		params = options
	end
	if istable(params) then
		for i = 1, #font_bits do
			local key = font_bits[i]
			fdata[key] = params[key]
		end
		fdata.blursize 	= params.blursize
		fdata.scanlines = params.scanlines
	end
	if not name then
		name = mangle_font(fdata)
		if fonts_cache[name] then
			return name
		end
		fonts_cache[name] = true
	end
	surface.CreateFont(name, fdata)
	return name
end

function scr.AutoFont(font,size,weight,params)
	return scr.CreateFont(nil,font,size,weight,params)
end

local halign_map = {
	[-1] = TEXT_ALIGN_LEFT,
	[ 0] = TEXT_ALIGN_CENTER,
	[ 1] = TEXT_ALIGN_RIGHT,
}

local valign_map = {
	[-1] = TEXT_ALIGN_TOP,
	[ 0] = TEXT_ALIGN_CENTER,
	[ 1] = TEXT_ALIGN_BOTTOM,
}

function scr.DrawText(x,y,text,xal,yal,col,font)
	col = col or color_white
	font = font or "Default"
	xal = halign_map[xal]
	yal = valign_map[yal]
	draw.SimpleText(text, font, x, y, col, xal, yal)
end

function scr.DrawTextEx(x,y,text,xal,col,font)
	col = col or color_white
	font = font or "Default"
	xal = halign_map[xal]
	draw.DrawText(text, font, x, y, col, xal)
end

function scr.TextSize(text,font)
    surface.SetFont(font)
    return surface.GetTextSize(text)
end

local default_ellipsis = {pos = 1, text = "..."}

function scr.TextEllipsis(str, maxw, font, ellipsis)
	ellipsis = ellipsis or default_ellipsis
	local fullw, _ = scr.TextSize(str, font)
	if fullw <= maxw then return str end
	local waccum, etxt = 0, ellipsis.text
	local dotw, _ = scr.TextSize(etxt, font)
	for j, ci in utf8.codes(str) do
		local ch = utf8.char(ci)
		local chw = scr.TextSize(ch, font)
		waccum = waccum + chw
		if waccum + dotw > maxw then
			local epos = ellipsis.pos
			local newstr = str:sub(1, j-1)
			if not epos then
				return newstr
			elseif epos < 0 then
				return etxt .. newstr
			elseif epos > 0 then
				return newstr .. etxt
			elseif epos == 0 then
				-- TODO: Ellipsis in the middle
				return newstr
			end
		end
	end
end

function scr.MatSize(mat)
	local wid = mat:GetInt("$realwidth") or mat:Width()
	local hgt = mat:GetInt("$realheight") or mat:Height()
	return wid, hgt
end

local cliprect_stack = {
	{0, 0, 1e9, 1e9, false}, -- Dummy
}

function scr.PushAbsClipRect(x,y,w,h,clamp)
	local id = #cliprect_stack
	local x1, y1, x2, y2 = x, y, x+w, y+h
	if clamp then
		local prev = cliprect_stack[id]
		x1, y1 = math.max(x1, prev[1]), math.max(y1, prev[2])
		x2, y2 = math.min(x2, prev[3]), math.min(y2, prev[4])
	end
	cliprect_stack[id+1] = {x1, y1, x2, y2, true}
	render.SetScissorRect(x1, y1, x2, y2, true)
end

function scr.PushRelClipRect(x,y,w,h,clamp)
	error("not implemented")
end

function scr.PopClipRect()
	local id = #cliprect_stack
	if id < 2 then return end
	cliprect_stack[id] = nil
	render.SetScissorRect(unpack(cliprect_stack[id-1]))
end

function scr.ClearClipRect()
	for i = #cliprect_stack, 2, -1 do
		cliprect_stack[i] = nil
	end
	render.SetScissorRect(0, 0, 0, 0, false)
end

function scr.GenTranslateMatrix(x,y)
	local mat = Matrix()
	mat:Translate(Vector(x,y,0))
	return mat
end

function scr.GenRotateMatrix(x,y,ang)
	local mat = Matrix()
	local pos = Vector(x,y,0)
	mat:Translate(pos)
	mat:Rotate(Angle(0,ang,0))
	mat:Translate(-pos)
	return mat
end

function scr.GenScaleMatrix(x,y,sx,sy)
	scy = scy or scx
	local mat = Matrix()
	local pos = Vector(x,y,0)
	mat:Translate(pos)
	mat:Scale(Vector(sx,sy,0))
	mat:Translate(-pos)
	return mat
end

local matrix_stack = {
	Matrix() -- Identity
}

function scr.PushMatrix(mat,nomul)
	local id = #matrix_stack
	if not nomul then
		mat = matrix_stack[id] * mat
	end
	matrix_stack[id+1] = mat
	cam.PushModelMatrix(mat)
end

function scr.PopMatrix()
	if #matrix_stack < 2 then return end
	matrix_stack[#matrix_stack] = nil
	cam.PopModelMatrix()
end

function scr.ClearMatrix()
	while #matrix_stack > 1 do
		scr.PopMatrix()
	end
end

function scr.PushTranslateMatrix(x,y,nomul)
	scr.PushMatrix(scr.GenTranslateMatrix(x,y), nomul)
end

function scr.PushRotateMatrix(x,y,ang,nomul)
	scr.PushMatrix(scr.GenRotateMatrix(x,y,ang), nomul)
end

function scr.PushScaleMatrix(x,y,sx,sy,nomul)
	scr.PushMatrix(scr.GenScaleMatrix(x,y,sx,sy), nomul)
end

local mt_anim = {}
mt_anim.__index = mt_anim
scr.META_AnimTex = mt_anim

function mt_anim:Render(x,y,tex,col)
	scr.PushTranslateMatrix(x,y)
		local frame = self:GetFrame()
		scr.DrawPoly(frame,col,tex)
	scr.PopMatrix()
end

function mt_anim:GetFrame(clk)
	clk = clk or RealTime()
	if self._mode then
		return 0, 0
	end
	local fi = clk / self.Speed % self.Length
	return self._frames[math.floor(fi)+1]
end

function scr.AnimTexture1D(w,h,len,ds)
	local polys = {}
	for i = 1, len do
		polys[i] = {
			{x = 0, y = 0, u = 1/len*(i-1), v = 0},
			{x = w, y = 0, u = 1/len*i, v = 0},
			{x = w, y = h, u = 1/len*i, v = 1},
			{x = 0,	y = h, u = 1/len*(i-1), v = 1},
		}
	end
	return setmetatable({
		_mode = false,
		_frames = polys,
		Width = w,
		Height = h,
		Length = len,
		Speed = ds,
	}, mt_anim)
end

local mt_wraptxt = {}
mt_wraptxt.__index = mt_wraptxt
scr.META_WordWrapper = mt_wraptxt

local worditer

local CK_NONE = 0
local CK_SPACE = 1
local CK_TAB = 3
local CK_LINE = 2

do ---- Word iterator ------------------
	local whitespace = {
		[0x0009] = CK_TAB,
		[0x000A] = CK_LINE,
		[0x000B] = CK_SPACE,
		[0x000C] = CK_SPACE,
		[0x000D] = CK_LINE,
		[0x0020] = CK_SPACE,
	}
	
	function worditer(str)
		local iterator = utf8.codes(str)
		local ltPos, ltChar = iterator()
		local ltKind = whitespace[ltChar]
		local rtPos, rtChar, rtKind
		local wordPos, endPos = 1, 1
		return function()
			while true do
				if not wordPos then break end
				local word, wType = nil
				rtPos, rtChar = iterator()
				rtKind = whitespace[rtChar]
				if not rtPos or rtKind ~= ltKind then
					endPos = (rtPos or 0) - 1
					word = str:sub(wordPos, endPos)
					wType = ltKind or CK_NONE
					wordPos = rtPos
				end
				ltPos, ltChar, ltKind = rtPos, rtChar, rtKind
				if word then return word, wType end
			end
			return nil
		end
	end
end ------------------------------------

function mt_wraptxt:PerformUpdate()
	local wrapW = self._wrapwidth
	if wrapW < 1 then return end
	local lines, maxW = {}, 0
	local curW, curBuf = 0, ""
	for word, wType in worditer(self._text) do
		if wType == CK_NONE then
			local w0 = scr.TextSize(word, self._font)
			if curW + w0 <= wrapW then
				curBuf = curBuf .. word
				curW = curW + w0
			elseif w0 > wrapW then
				for j, ci in utf8.codes(word) do
					local ch = utf8.char(ci)
					local nxtBuf = curBuf .. ch
					local w1 = scr.TextSize(nxtBuf, self._font)
					if w1 > wrapW then
						lines[#lines+1] = curBuf
						maxW = math.max(maxW, curW)
						local csz = scr.TextSize(ch, self._font)
						curW, curBuf = csz, ch
					else
						curW, curBuf = w1, nxtBuf	
					end
				end
			else
				lines[#lines+1] = curBuf
				maxW = math.max(maxW, curW)
				curW, curBuf = w0, word
			end
		elseif wType == CK_TAB
		or wType == CK_SPACE then
			if wType == CK_TAB then
				word = string.rep(" ", #word * self._tabwidth)
			end
			local w0 = scr.TextSize(word, self._font)
			if curW + w0 <= wrapW then
				curBuf = curBuf .. word
			end
			curW = curW + w0
		elseif wType == CK_LINE then
			lines[#lines+1] = curBuf
			maxW = math.max(maxW, curW)
			curW, curBuf = 0, ""
			for i = 1, #word-1 do
				lines[#lines+1] = false
			end
		end
	end
	if #curBuf > 0 then
		lines[#lines+1] = curBuf
		maxW = math.max(maxW, curW)
	end
	local _, hgt = scr.TextSize(" ", self._font)
	self._size[1] = math.min(wrapW, maxW)
	self._size[2] = #lines * hgt
	self._lines = lines
end

function mt_wraptxt:QueryUpdate()
	if self._isdirty then
		self._isdirty = nil
		self:PerformUpdate()
	end
end

function mt_wraptxt:GetText()
	return self._text
end

function mt_wraptxt:SetText(txt)
	if self._text ~= txt then
		self._isdirty = true
	end
	self._text = txt
end

function mt_wraptxt:GetFont()
	return self._font
end

function mt_wraptxt:SetFont(fnt)
	if self._font ~= fnt then
		self._isdirty = true
	end
	self._font = fnt
end

function mt_wraptxt:GetSize()
	return unpack(self._size)
end

function mt_wraptxt:GetWrapWidth()
	return self._wrapwidth
end

function mt_wraptxt:SetWrapWidth(w)
	if self._wrapwidth ~= w then
		self._isdirty = true
	end
	self._wrapwidth = w
end

function mt_wraptxt:Clear()
	self._text = ""
	self._lines = {}
end

function mt_wraptxt:Render(x,y,col,xal)
	self:QueryUpdate()
	local count = #self._lines
	if count < 1 then return end
	local lineHgt = self._size[2] / count
	for i = 1, count do
		local line = self._lines[i]
		if not line then continue end
		scr.DrawText(x, y+lineHgt*(i-1), line, xal or -1, -1, col, self._font)
	end
end

function scr.WordWrapper(fnt, txt)
	return setmetatable({
		_lines = {},
		_size = {0, 0},
		_wrapwidth = 0,
		_tabwidth = 4,
		_text = txt or "",
		_font = fnt or "Default",
	}, mt_wraptxt)
end
