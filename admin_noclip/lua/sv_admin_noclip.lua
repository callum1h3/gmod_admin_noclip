if SERVER then
noclipcamera = noclipcamera or {}
noclipcamera.admincameralist = {}

util.AddNetworkString( "noclipcam_request" )
util.AddNetworkString( "noclipcam_senddata" )
util.AddNetworkString( "noclipcam_recievedata" )
util.AddNetworkString( "noclipcam_sendtext" )

function noclipcamera.hasvalidrank(ply)
	if table.HasValue(noclipcamera.adminranks, ply:GetUserGroup()) then
	    return true
	else
		return false

	end
end
function noclipcamera.logevent(text)
	print(text)
end
function noclipcamera.getadmincamera(ply)
	for k, v in pairs( noclipcamera.admincameralist ) do
		if v[2] == ply then
			return v[1]			
		end
	end
	return false
end
function noclipcamera.adminalreadyhascamera(ply)
	for k, v in pairs( noclipcamera.admincameralist ) do
		if v[2] == ply then

			local tab = table.Copy(v) 
			table.remove(noclipcamera.admincameralist, k)
			return tab[1]
			
		end
	end
	return false
end
function noclipcamera.sendcameradata(ply)
	net.Start( "noclipcam_senddata" )
	net.WriteInt(1,3)
	net.Send( ply )
end
function noclipcamera.sendchattocamera(ply, text, text2)

	net.Start( "noclipcam_sendtext" )
	net.WriteString(text)
	net.WriteString(text2)
	net.Send( ply )

end
function noclipcamera.cameracreate(ply)
	local ifstatement = noclipcamera.adminalreadyhascamera(ply)
    if !ifstatement then
    	noclipcamera.logevent(ply:Name().."["..ply:SteamID().."]".." is in admin noclip.")

        local cameraent = ents.Create( "prop_physics" )
        if ( !IsValid( cameraent ) ) then return end
        cameraent:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
        cameraent:SetPos( Vector( 0, 0, 0 ) )
        cameraent:Spawn()
        cameraent:SetNoDraw( true )
	    local phys = cameraent:GetPhysicsObject()
 
	    if phys and phys:IsValid() then
		    phys:EnableMotion(false) -- Freezes the object in place.
	    end
	    ply:SpectateEntity( cameraent )
        table.insert(noclipcamera.admincameralist, {cameraent, ply})
        noclipcamera.sendcameradata(ply)

      
    else
    	noclipcamera.logevent(ply:Name().."["..ply:SteamID().."]".." came out of admin noclip.")
    	if noclipcamera.bringplayer then
            ply:SetPos(ifstatement:GetPos())
        end
    	ifstatement:Remove()
    	ply:UnSpectate()
	    net.Start( "noclipcam_senddata" )
	    net.WriteInt(2,3)
	    net.Send( ply )

    end


end

hook.Add( "PlayerInitialSpawn", "PlayerRemindCommand", function( ply, text, team )	
	if noclipcamera.camerareminder then
	    if noclipcamera.hasvalidrank(ply) then
		    ply:ChatPrint("Reminder to bind admin_noclip_toggle for admin noclip.")
		    ply:ChatPrint("This will hide you from hackers using wall hacks, they can")
		    ply:ChatPrint("still see you when you are in normal noclip but they cant")
		    ply:ChatPrint("see you in admin noclip.")
		end
	end
end )

hook.Add( "PlayerSay", "PlayerSayExample", function( ply, text, team )	
	for k, v in pairs( noclipcamera.admincameralist ) do
		if v[1]:GetPos():DistToSqr( ply:GetPos() ) < ( noclipcamera.voicechatrange*noclipcamera.voicechatrange ) then
			noclipcamera.sendchattocamera(v[2], ply:Name().."["..ply:SteamID().."]: ", text)
		end

	end	
end )

hook.Add( "PlayerCanHearPlayersVoice", "Maximum Range", function( listener, talker )
	if noclipcamera.hasvalidrank(listener) then
		local camera = noclipcamera.getadmincamera(listener)
		if isentity(camera) then
	        if camera:GetPos():DistToSqr( talker:GetPos() ) < ( noclipcamera.textchatrange*noclipcamera.textchatrange ) then
		        return true,noclipcamera.voice3d
	        end
	    end
	end
end )

net.Receive( "noclipcam_request", function( len, ply ) 
	if noclipcamera.hasvalidrank(ply) then
		noclipcamera.cameracreate(ply)
	end
end )

net.Receive( "noclipcam_senddata", function( len, ply ) 
	if noclipcamera.hasvalidrank(ply) then
	    local tab = net.ReadTable()
	    local camera = noclipcamera.getadmincamera(ply)

	    if isentity(camera) then
		    camera:SetPos(tab.posvec)
	    end
	end
end )



end