local function createSkin()
	surface.CreateFont("WeaponPlacerFont", {
		font = "HudDefault",
		size = 14,
		weight = 800,
		antialias = true,
		extended = true
	})

	local SKIN = table.Copy(derma.GetNamedSkin("Default"))

	SKIN.Colours.Window = {}
	SKIN.Colours.Window.TitleActive			= Color(0,255,255,255)
	SKIN.Colours.Window.TitleInactive		= SKIN.Colours.Window.TitleActive

	SKIN.Colours.Tab = {}
	SKIN.Colours.Tab.Active = {}
	SKIN.Colours.Tab.Active.Normal			= SKIN.Colours.Button.Normal
	SKIN.Colours.Tab.Active.Hover			= SKIN.Colours.Button.Normal
	SKIN.Colours.Tab.Active.Down			= SKIN.Colours.Button.Normal
	SKIN.Colours.Tab.Active.Disabled		= SKIN.Colours.Button.Disabled

	SKIN.Colours.Tab.Inactive = {}
	SKIN.Colours.Tab.Inactive.Normal		= SKIN.Colours.Button.Normal
	SKIN.Colours.Tab.Inactive.Hover			= SKIN.Colours.Button.Normal
	SKIN.Colours.Tab.Inactive.Down			= SKIN.Colours.Button.Normal
	SKIN.Colours.Tab.Inactive.Disabled		= SKIN.Colours.Button.Disabled

	SKIN.Colours.Label = {}
	SKIN.Colours.Label.Default				= SKIN.Colours.Button.Normal
	SKIN.Colours.Label.Bright				= SKIN.Colours.Button.Normal
	SKIN.Colours.Label.Dark					= SKIN.Colours.Button.Normal
	SKIN.Colours.Label.Highlight			= SKIN.Colours.Button.Normal

	SKIN.Colours.Tree = {}
	SKIN.Colours.Tree.Lines					= Color(100,100,100,255)
	SKIN.Colours.Tree.Normal				= SKIN.Colours.Button.Normal
	SKIN.Colours.Tree.Hover					= Color(50,25,200,255)
	SKIN.Colours.Tree.Selected				= Color(50,25,175,255)

	SKIN.Colours.Properties = {}
	SKIN.Colours.Properties.Line_Normal			= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Line_Selected		= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Line_Hover			= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Title				= Color(135, 206, 250, 255)
	SKIN.Colours.Properties.Column_Normal		= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Column_Selected		= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Column_Hover		= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Border				= Color(0, 0, 0, 0)
	SKIN.Colours.Properties.Label_Normal		= Color(255, 255, 255, 255)
	SKIN.Colours.Properties.Label_Selected		= Color(255, 255, 255, 255)
	SKIN.Colours.Properties.Label_Hover			= Color(255, 255, 255, 255)

	SKIN.Colours.Category = {}
	SKIN.Colours.Category.Header					= Color(135, 206, 250, 255)
	SKIN.Colours.Category.Header_Closed				= Color(135, 206, 250, 255)
	SKIN.Colours.Category.Line = {}
	SKIN.Colours.Category.Line.Text					= Color(255, 255, 255,255)
	SKIN.Colours.Category.Line.Text_Hover			= Color(255, 255, 255, 255)
	SKIN.Colours.Category.Line.Text_Selected		= Color(255, 255, 255, 255)
	SKIN.Colours.Category.Line.Button				= Color(0, 0, 0, 20)
	SKIN.Colours.Category.Line.Button_Hover			= Color(135, 206, 250, 50)
	SKIN.Colours.Category.Line.Button_Selected		= Color(135, 206, 250, 20)
	SKIN.Colours.Category.LineAlt = {}
	SKIN.Colours.Category.LineAlt.Text				= Color(255, 255, 255, 255)
	SKIN.Colours.Category.LineAlt.Text_Hover		= Color(255, 255, 255, 255)
	SKIN.Colours.Category.LineAlt.Text_Selected		= Color(255, 255, 255, 255)
	SKIN.Colours.Category.LineAlt.Button			= Color(0, 0, 0, 100)
	SKIN.Colours.Category.LineAlt.Button_Hover		= Color(135, 206, 250, 50)
	SKIN.Colours.Category.LineAlt.Button_Selected	= Color(135, 206, 250, 20)

	SKIN.Colours.TooltipText = Color(0,0,0,255)

	SKIN.Colours._Button = {}
	SKIN.Colours._Button.Normal = Color(75, 115, 140, 130)
	SKIN.Colours._Button.Hover = Color(94, 144, 175, 255)

	function SKIN:PaintButton( panel, w, h )
		if not panel.m_bBackground then
			return
		end

		if panel:IsHovered() then
			draw.RoundedBox(3, 0, 0, w, h, self.Colours._Button.Hover)
		else
			draw.RoundedBox(3, 0, 0, w, h, self.Colours._Button.Normal)
		end
	end

	function SKIN:PaintWindowCloseButton( panel, w, h )
		if not panel.m_bBackground then
			return
		end

		draw.RoundedBox(0, 5, 6, w - 6, h - 12, panel:IsHovered() and Color(255, 0, 0, 255) or Color(150, 0, 0, 255))
		draw.SimpleText("x", "DermaDefault", (w - 2.5)/2, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	function SKIN:PaintCollapsibleCategory( panel, w, h )
		surface.SetDrawColor(Color(0, 0, 0, 0))

		panel.Header.Paint = function()
			surface.SetDrawColor(Color(0, 0, 0, 150))
			surface.DrawRect(0, 0, w, h)
		end

		if not panel.Header.fontSet then
			panel.Header:SetFont("WeaponPlacerFont")
			panel.Header.fontSet = true
		end

		if ( h <= panel:GetHeaderHeight() ) then
			if ( !panel:GetExpanded() ) then
				self.tex.Input.UpDown.Down.Hover( w - 18, h / 2 - 8, 15, 15 )
			end

			return
		end

		self.tex.Input.UpDown.Up.Hover(w - 18, 2, 15, 15 )
	end

	function SKIN:PaintCollapsibleCategoryHeader( w, h )
		surface.SetDrawColor(Color(255, 0, 0, 255))
		surface.DrawRect(0,0,w,h)
	end

	function SKIN:PaintCategoryList( panel, w, h )
		return
	end

	function SKIN:PaintVScrollBar( panel, w, h )
		surface.SetDrawColor(Color(0, 0, 0, 180))
		surface.DrawRect(0, 0, w, h)
	end

	function SKIN:PaintScrollBarGrip( panel, w, h )
		surface.SetDrawColor(Color(135, 206, 250, 255))
		surface.DrawRect(0, 0, w, h)
	end

	SKIN.PaintButtonDown = SKIN.PaintScrollBarGrip
	SKIN.PaintButtonUp = SKIN.PaintScrollBarGrip

	derma.DefineSkin("WepPlacerSkin", "", SKIN)
	derma.RefreshSkins()
end

hook.Add("InitPostEntity", "WeaponPlacerCreateSkin", function()
	createSkin()
end)