if CLIENT then
noclipcamera = noclipcamera or {}

noclipcamera.IsNoclipEnabled = false
noclipcamera.cameraData = {}
noclipcamera.NoclipPos = Vector(0,0,0)
local delay = 0

function noclipcamera.sendinformationtoserver()
    if !table.IsEmpty(noclipcamera.cameraData) then
 	    net.Start( "noclipcam_senddata" )
 	    net.WriteTable(noclipcamera.cameraData)
	    net.SendToServer() 	  
	end 
end
function noclipcamera.controlcamera()
	noclipcamera.NoclipPos = LocalPlayer():EyePos()
	noclipcamera.IsNoclipEnabled = true
    if !( timer.Exists( "NoclipCameraTimer" ) ) then
	    timer.Create( "NoclipCameraTimer", noclipcamera.cameraupdate, 0, function() noclipcamera.sendinformationtoserver() end )
	end
end
function noclipcamera.deselectcamera()
	timer.Remove( "NoclipCameraTimer" )

	noclipcamera.IsNoclipEnabled = false
end
function noclipcamera.clrequestcamera()
	net.Start( "noclipcam_request" )
	net.SendToServer()
end
net.Receive( "noclipcam_senddata", function()
	local option = net.ReadInt(3)
	if option == 1 then
		noclipcamera.controlcamera()
		
	end
	if option == 2 then
		noclipcamera.deselectcamera()
		
	end
end )

net.Receive( "noclipcam_sendtext", function()
	local text = net.ReadString()
	local text2 = net.ReadString()
	chat.AddText( noclipcamera.playernamecolor, text, noclipcamera.playertextcolor, text2  )
	
end )

hook.Add( "CalcView", "ClientSideNoclip", function(ply, Pos, Ang, FOV)
    if noclipcamera.IsNoclipEnabled then             
        local CamData = {}
                       
        local Speed = noclipcamera.cameraspeed/5
        MouseAngs = Angle( NoclipY, NoclipX, 0 )
        if LocalPlayer():KeyDown(IN_SPEED) then
            Speed = Speed * noclipcamera.cameraspeedboost
        end
        if LocalPlayer():KeyDown(IN_FORWARD) then
            noclipcamera.NoclipPos = noclipcamera.NoclipPos+(MouseAngs:Forward()*Speed)
        end
        if LocalPlayer():KeyDown(IN_BACK) then
            noclipcamera.NoclipPos = noclipcamera.NoclipPos-(MouseAngs:Forward()*Speed)
        end
        if LocalPlayer():KeyDown(IN_MOVELEFT) then
            noclipcamera.NoclipPos = noclipcamera.NoclipPos-(MouseAngs:Right()*Speed)
        end
        if LocalPlayer():KeyDown(IN_MOVERIGHT) then
            noclipcamera.NoclipPos = noclipcamera.NoclipPos+(MouseAngs:Right()*Speed)
        end
        if NoclipJump then
            noclipcamera.NoclipPos = noclipcamera.NoclipPos+Vector(0,0,Speed)
        end
        if NoclipDuck then
            noclipcamera.NoclipPos = noclipcamera.NoclipPos-Vector(0,0,Speed)
        end
        CamData.origin = noclipcamera.NoclipPos
        CamData.angles = MouseAngs
        CamData.fov = FOV
        CamData.drawviewer = true

        noclipcamera.cameraData.posvec = CamData.origin              
        return CamData
    end      
end)

hook.Add( "CreateMove", "ClientSideNoclip2", function(ucmd)

               
    if noclipcamera.IsNoclipEnabled then               
        NoclipAngles = ucmd:GetViewAngles()
        NoclipY, NoclipX = ucmd:GetViewAngles().x, ucmd:GetViewAngles().y
        NoclipOn = true
                      
        ucmd:ClearMovement()
        if ucmd:KeyDown(IN_JUMP) then
            ucmd:RemoveKey(IN_JUMP)
            NoclipJump = true
        elseif NoclipJump then
            NoclipJump = false
        end
        if ucmd:KeyDown(IN_DUCK) then
            ucmd:RemoveKey(IN_DUCK)
            NoclipDuck = true
        elseif NoclipDuck then
            NoclipDuck = false
        end
        NoclipX = NoclipX-(ucmd:GetMouseX()/50)
        if NoclipY+(ucmd:GetMouseY()/50) > 89 then NoclipY = 89 elseif NoclipY+(ucmd:GetMouseY()/50) < -89 then NoclipY = -89 else NoclipY = NoclipY+(ucmd:GetMouseY()/50) end
        ucmd:SetViewAngles(NoclipAngles)

        return false
    end


end)

concommand.Add( "admin_noclip_toggle", function( ply, cmd, args )
	noclipcamera.clrequestcamera()
end )

 
hook.Add( "HUDPaint", "AdminEsp", function()
    if noclipcamera.IsNoclipEnabled then
        for k,v in pairs ( player.GetAll() ) do
            local Position = ( v:GetPos() + Vector( 0,0,80 ) ):ToScreen()
            local Name = ""
 
            if v == LocalPlayer() then Name = "" else Name = v:Name() end
 
            draw.DrawText( Name, "DermaDefault", Position.x, Position.y, Color( 255, 255, 255, 255 ), 1 )
        end
    end 
end )

hook.Add( "PostDrawOpaqueRenderables", "StencilWallhack", function()

    if noclipcamera.IsNoclipEnabled then
        render.SetStencilReferenceValue( 0 )
        
        render.SetStencilPassOperation( STENCIL_KEEP )
       
        render.SetStencilZFailOperation( STENCIL_KEEP )
        render.ClearStencil()

       
        render.SetStencilEnable( true )
     
        render.SetStencilCompareFunction( STENCIL_NEVER )
        
        render.SetStencilFailOperation( STENCIL_REPLACE )


        render.SetStencilReferenceValue( 0x1C )
 

        render.SetStencilWriteMask( 0x55 )

  
        for _, ent in pairs(  player.GetAll()  ) do
            ent:DrawModel()
        end


        render.SetStencilTestMask( 0xF3 )
      
        render.SetStencilReferenceValue( 0x10 )
        
        render.SetStencilCompareFunction( STENCIL_EQUAL )

        
        render.ClearBuffersObeyStencil( 100, 100, 100, 100, true );

        
        render.SetStencilEnable( false )
    end
end )
end