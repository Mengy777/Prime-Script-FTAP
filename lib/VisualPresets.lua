-- Visual parameters traced from DctRKW; see docs/Visual-Source-Audit.md.
local skies = {
				Nebula = {
					SkyboxBk = "http://www.roblox.com/asset?id=135207744",
					SkyboxDn = "http://www.roblox.com/asset?id=135207662",
					SkyboxFt = "http://www.roblox.com/asset?id=135207770",
					SkyboxLf = "http://www.roblox.com/asset?id=135207615",
					SkyboxRt = "http://www.roblox.com/asset?id=135207695",
					SkyboxUp = "http://www.roblox.com/asset?id=135207794",
				},
				Storm = {
					SkyboxBk = "rbxassetid://15502511288",
					SkyboxDn = "rbxassetid://15502508460",
					SkyboxFt = "rbxassetid://15502510289",
					SkyboxLf = "rbxassetid://15502507918",
					SkyboxRt = "rbxassetid://15502509398",
					SkyboxUp = "rbxassetid://15502511911",
				},
				Sunset = {
					SkyboxBk = "rbxassetid://600830446",
					SkyboxDn = "rbxassetid://600831635",
					SkyboxFt = "rbxassetid://600832720",
					SkyboxLf = "rbxassetid://600886090",
					SkyboxRt = "rbxassetid://600833862",
					SkyboxUp = "rbxassetid://600835177",
				},
				["Deep Space"] = {
					SkyboxBk = "http://www.roblox.com/asset/?id=159248188",
					SkyboxDn = "http://www.roblox.com/asset/?id=159248183",
					SkyboxFt = "http://www.roblox.com/asset/?id=159248187",
					SkyboxLf = "http://www.roblox.com/asset/?id=159248173",
					SkyboxRt = "http://www.roblox.com/asset/?id=159248192",
					SkyboxUp = "http://www.roblox.com/asset/?id=159248176",
				},
				Crimson = {
					SkyboxBk = "http://www.roblox.com/asset/?id=401664839",
					SkyboxDn = "http://www.roblox.com/asset/?id=401664862",
					SkyboxFt = "http://www.roblox.com/asset/?id=401664960",
					SkyboxLf = "http://www.roblox.com/asset/?id=401664881",
					SkyboxRt = "http://www.roblox.com/asset/?id=401664901",
					SkyboxUp = "http://www.roblox.com/asset/?id=401664936",
				},
				Galaxy = {
					SkyboxBk = "rbxassetid://15983968922",
					SkyboxDn = "rbxassetid://15983966825",
					SkyboxFt = "rbxassetid://15983965025",
					SkyboxLf = "rbxassetid://15983967420",
					SkyboxRt = "rbxassetid://15983966246",
					SkyboxUp = "rbxassetid://15983964246",
				},
				Blossom = {
					SkyboxBk = "http://www.roblox.com/asset/?id=271042516",
					SkyboxDn = "http://www.roblox.com/asset/?id=271077243",
					SkyboxFt = "http://www.roblox.com/asset/?id=271042556",
					SkyboxLf = "http://www.roblox.com/asset/?id=271042310",
					SkyboxRt = "http://www.roblox.com/asset/?id=271042467",
					SkyboxUp = "http://www.roblox.com/asset/?id=271077958",
				},
				Arctic = {
					SkyboxBk = "http://www.roblox.com/asset/?id=225469390",
					SkyboxDn = "http://www.roblox.com/asset/?id=225469395",
					SkyboxFt = "http://www.roblox.com/asset/?id=225469403",
					SkyboxLf = "http://www.roblox.com/asset/?id=225469450",
					SkyboxRt = "http://www.roblox.com/asset/?id=225469471",
					SkyboxUp = "http://www.roblox.com/asset/?id=225469481",
				},
				Midnight = {
					SkyboxBk = "http://www.roblox.com/asset/?id=12064107",
					SkyboxDn = "http://www.roblox.com/asset/?id=12064152",
					SkyboxFt = "http://www.roblox.com/asset/?id=12064121",
					SkyboxLf = "http://www.roblox.com/asset/?id=12063984",
					SkyboxRt = "http://www.roblox.com/asset/?id=12064115",
					SkyboxUp = "http://www.roblox.com/asset/?id=12064131",
				},
				Stylized = {
					SkyboxBk = "rbxassetid://18351376859",
					SkyboxDn = "rbxassetid://18351374919",
					SkyboxFt = "rbxassetid://18351376800",
					SkyboxLf = "rbxassetid://18351376469",
					SkyboxRt = "rbxassetid://18351376457",
					SkyboxUp = "rbxassetid://18351377189",
				},
				Overcast = {
					SkyboxBk = "http://www.roblox.com/asset/?id=4498828382",
					SkyboxDn = "http://www.roblox.com/asset/?id=4498828812",
					SkyboxFt = "http://www.roblox.com/asset/?id=4498829917",
					SkyboxLf = "http://www.roblox.com/asset/?id=4498830911",
					SkyboxRt = "http://www.roblox.com/asset/?id=4498830417",
					SkyboxUp = "http://www.roblox.com/asset/?id=4498831746",
				},
				Frostfall = {
					SkyboxBk = "http://www.roblox.com/asset/?id=155657655",
					SkyboxDn = "http://www.roblox.com/asset/?id=155674246",
					SkyboxFt = "http://www.roblox.com/asset/?id=155657609",
					SkyboxLf = "http://www.roblox.com/asset/?id=155657671",
					SkyboxRt = "http://www.roblox.com/asset/?id=155657619",
					SkyboxUp = "http://www.roblox.com/asset/?id=155674931",
				},
				Default = {
					SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex",
					SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex",
					SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex",
					SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex",
					SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex",
					SkyboxUp = "rbxasset://textures/sky/sky512_up.tex",
				},
			}

-- Retained additions: VISUALBOSS/readme.md (docs/View-2.2.1.md).
-- Four replacements: Roblox models/previews in docs/Sky-Collection-2.3.0.md.
skies["Blue Horizon"]={SkyboxBk="rbxassetid://135483466",SkyboxDn="rbxassetid://135483484",SkyboxFt="rbxassetid://135483461",SkyboxLf="rbxassetid://135483495",SkyboxRt="rbxassetid://135483499",SkyboxUp="rbxassetid://135483475"}
skies["Purple Nebula"]={SkyboxBk="rbxassetid://159454299",SkyboxDn="rbxassetid://159454296",SkyboxFt="rbxassetid://159454293",SkyboxLf="rbxassetid://159454286",SkyboxRt="rbxassetid://159454300",SkyboxUp="rbxassetid://159454288"}
skies["Rainbow Galaxy"]={AssetId="4943578383"}
skies["Pink Morning"]={SkyboxBk="rbxassetid://12635309703",SkyboxDn="rbxassetid://12635311686",SkyboxFt="rbxassetid://12635312870",SkyboxLf="rbxassetid://12635313718",SkyboxRt="rbxassetid://12635315817",SkyboxUp="rbxassetid://12635316856"}
skies["Purple Radiance"]={SkyboxBk="rbxassetid://570557514",SkyboxDn="rbxassetid://570557775",SkyboxFt="rbxassetid://570557559",SkyboxLf="rbxassetid://570557620",SkyboxRt="rbxassetid://570557672",SkyboxUp="rbxassetid://570557727",CelestialBodiesShown=false}
skies["Dark Matter"]={AssetId="110290405998332"}
skies["Milky Way"]={AssetId="545702970"}
-- Migrate saved selection names without retaining rejected entries in the menu.
local skyAliases={Vaporwave="Rainbow Galaxy",["Lavender Gradient"]="Purple Radiance",["Rose Gradient"]="Dark Matter",["Golden Hour"]="Milky Way"}
return {Skies=skies,SkyAliases=skyAliases}
