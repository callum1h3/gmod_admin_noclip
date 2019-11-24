if (SERVER) then

	AddCSLuaFile("cl_admin_noclip.lua")

	AddCSLuaFile("sh_admin_noclip_config.lua")
	include("sh_admin_noclip_config.lua")

	include("sv_admin_noclip.lua")

else
	
	include("cl_admin_noclip.lua")

	include("sh_admin_noclip_config.lua")	

end

