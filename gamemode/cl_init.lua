--[[

Derp

]]
local function NewFaction( data )
	local fname = data:ReadString()
	local idfloat = data:ReadFloat()
	local vec = data:ReadVector()
	print("team.SetUp( " .. math.floor(idfloat+0.5).. ", " .. fname .. ", " .. "Color( " .. vec.x .. ", " .. vec.y .. ", " .. vec.z .. ", 255 ) )")
	team.SetUp( math.floor(idfloat+0.5), fname, Color( vec.x, vec.y, vec.z, 255 ) )
end
usermessage.Hook( "NewFaction", NewFaction )

//Scoreboard
ScoreBoard = {}
ScoreBoard.Teams = {}
function StrandedScoreboard()
	// le derma
	ScoreBoard.Frame = vgui.Create("DPanel")
	ScoreBoard.Frame:SetPos(surface.ScreenWidth()  / 4, surface.ScreenHeight() / 4 )
	ScoreBoard.Frame:SetSize(surface.ScreenWidth()  / 2, surface.ScreenHeight() / 2 )
	ScoreBoard.Frame:SetVisible( true )
	ScoreBoard.Frame:MakePopup()
	ScoreBoard.ContentList = vgui.Create("DCategoryList", ScoreBoard.Frame)
	ScoreBoard.ContentList:SetPos(5,5)
	ScoreBoard.ContentList:SetSize( (surface.ScreenWidth()  / 2 ) - 10, (surface.ScreenHeight() / 2 ) - 10 )
	for k,v in pairs(team.GetAllTeams()) do
		local teamname = team.GetName(k)
		if k != 0 and k != 1001 and k != 1002 then
			local teamname = team.GetName(k)
			ScoreBoard.Teams[k] = vgui.Create("DCollapsibleCategory", ScoreBoard.ContentList)
			ScoreBoard.Teams[k]:SetText("")
			local textcolor = InvertColor( team.GetColor(k) )
			ScoreBoard.Teams[k].Paint = function(  )
				draw.RoundedBox(4, 0, 0, ScoreBoard.Teams[k]:GetWide(), ScoreBoard.Teams[k]:GetTall(), team.GetColor(k))
				draw.DrawText(teamname, "Default", 5, 2, textcolor, TEXT_ALIGN_LEFT )
				return true
			end
			ScoreBoard.Teams[k].Panel = vgui.Create("DPanelList")
			ScoreBoard.Teams[k].Panel:SetSpacing( 5 )
			ScoreBoard.Teams[k].Panel:EnableHorizontal( false )
			ScoreBoard.Teams[k].Panel:EnableVerticalScrollbar( true )
			ScoreBoard.Teams[k].Panel:SetSize(ScoreBoard.Teams[k]:GetWide(), ScoreBoard.Teams[k]:GetTall())
			ScoreBoard.Teams[k].Members = {}
			for kk,vv in pairs(player.GetAll()) do 
				if vv:Team() == k then
					ScoreBoard.Teams[k].Members[kk] = vgui.Create("DLabel")
					ScoreBoard.Teams[k].Members[kk]:SetText(vv:Nick())
					ScoreBoard.Teams[k].Members[kk]:SizeToContents()
					ScoreBoard.Teams[k].Panel:AddItem(ScoreBoard.Teams[k].Members[kk])
				end
			end
			ScoreBoard.Teams[k]:SetContents(ScoreBoard.Teams[k].Panel)
		end
	end

	//hide other
	return true
end
hook.Add("ScoreboardShow", "WebbaScoreboard", StrandedScoreboard)

function HideScoreBoard()
	ScoreBoard.Frame:SetVisible( false )
end
hook.Add("ScoreboardHide", "WebbaScoreboard", HideScoreBoard)

function InvertColor( color )
	local var_R = ( color.r / 255 )                     //RGB from 0 to 255
	local var_G = ( color.g / 255 )
	local var_B = ( color.b / 255 )
	
	local var_Min = math.min( var_R, var_G, var_B )    //Min. value of RGB
	local var_Max = math.max( var_R, var_G, var_B )    //Max. value of RGB
	local del_Max = var_Max - var_Min             //Delta RGB value
	
	local L = ( var_Max + var_Min ) / 2
	local H = 0
	local S = 0

	if ( del_Max == 0 ) then                    //This is a gray, no chroma...
		H = 0                                //HSL results from 0 to 1
		S = 0
	else                                    //Chromatic data...
		if ( L < 0.5 ) then 
			S = del_Max / ( var_Max + var_Min )
		else           
			S = del_Max / ( 2 - var_Max - var_Min )
		end
	
		local del_R = ( ( ( var_Max - var_R ) / 6 ) + ( del_Max / 2 ) ) / del_Max
		local del_G = ( ( ( var_Max - var_G ) / 6 ) + ( del_Max / 2 ) ) / del_Max
		local del_B = ( ( ( var_Max - var_B ) / 6 ) + ( del_Max / 2 ) ) / del_Max
	
		if      ( var_R == var_Max ) then
			H = del_B - del_G
		elseif ( var_G == var_Max ) then 
			H = ( 1 / 3 ) + del_R - del_B
		elseif ( var_B == var_Max ) then 
			H = ( 2 / 3 ) + del_G - del_R
		end
	
		if ( H < 0 ) then 
			H =  H + 1
		end
		if ( H > 1 ) then 
			H = H - 1
		end
	end
	local Hdeg = H * 360 
	local Hdegnew = H + 180
	if Hdegnew > 360 then
		Hdegnew = Hdegnew - 360
	end 
	H = Hdegnew / 360
	if ( S == 0 ) then                      //HSL from 0 to 1
		color.r = L * 255                      //RGB results from 0 to 255
		color.g = L * 255
		color.b = L * 255
	else
		local var_2 = 0
		if ( L < 0.5 ) then 
			var_2 = L * ( 1 + S )
		else           
			var_2 = ( L + S ) - ( S * L )
		end
	
		local var_1 = 2 * L - var_2
	
		color.r = 255 * Hue_2_RGB( var_1, var_2, H + ( 1 / 3 ) ) 
		color.g = 255 * Hue_2_RGB( var_1, var_2, H )
		color.b = 255 * Hue_2_RGB( var_1, var_2, H - ( 1 / 3 ) )
	end
	return color
end

function Hue_2_RGB( v1, v2, vH )             //Function Hue_2_RGB
	if ( vH < 0 ) then 
		vH = vH + 1
	end 
	if ( vH > 1 ) then 
		vH = vH - 1
	end 
	if ( ( 6 * vH ) < 1 ) then  
		return ( v1 + ( v2 - v1 ) * 6 * vH )
	end
	if ( ( 2 * vH ) < 1 ) then  
		return ( v2 )
	end
	if ( ( 3 * vH ) < 2 ) then  
		return ( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - vH ) * 6 )
	end
	return ( v1 )
end

