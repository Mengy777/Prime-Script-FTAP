from support import Disk,session
lua,source,_,_=session(Disk(),execute=False)
lua.execute(source)
lua.execute(r"""
local pg=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
local intro=pg:FindFirstChild('PrimeLoading')assert(intro)
local card=intro:FindFirstChild('LoadingCard',true)
local brand=intro:FindFirstChild('LoadingBrand',true)
local status=intro:FindFirstChild('LoadingStatus',true)
local omega=intro:FindFirstChild('PrimeOmega',true)
assert(card and card:IsA('CanvasGroup')and card.Size.Y.Offset==170)
assert(not intro:GetChildren()[1]:IsA('CanvasGroup'),'fullscreen offscreen CanvasGroup retained')
assert(intro:GetChildren()[1].BackgroundColor3.R==0 and intro:GetChildren()[1].BackgroundColor3.G==0)
assert(brand.Font==Enum.Font.Arcade and brand.RichText and brand.Text:find('<font',1,true))
assert(status.TextColor3.R==1 and status.TextColor3.G==1 and status.TextColor3.B==1)
assert(omega,'actual menu Omega not used')
local rotation=omega.Rotation or0
TEST_SERVICES.RunService.RenderStepped:Fire(.08)
assert(omega.Rotation~=rotation)
TEST_ACTIONS['Unload script']()
assert(not pg:FindFirstChild('PrimeLoading'),'unload before fade leaves loading screen')
TEST_SERVICES.RunService.RenderStepped:Fire(.1)TEST_DRAIN()
""".replace('or0','or 0'))
print('PASS black/white bootstrap, actual Arcade rainbow wordmark/menu Omega, compact CanvasGroup, rotation and early-unload fade cleanup')
# Cooperative transport: real startup runs with four yielded HTTP workers.
lua,source,_,_=session(Disk(),execute=False)
lua.globals().BOOT_SOURCE=source
lua.execute(r"""
local originalHttp=game.HttpGet local originalWait=task.wait
local queue={}local active,maximum=0,0 local calls={}
task.spawn=function(fn)
 local thread=coroutine.create(fn)queue[#queue+1]=thread
 local ok,message=coroutine.resume(thread)assert(ok,message)
 return thread
end
task.defer=task.spawn
task.wait=function(dt)coroutine.yield('wait')return dt or .01 end
game.HttpGet=function(self,url)
 local name=url:match('/lib/([^/?]+)%.lua')
 if name then
  calls[name]=(calls[name]or0)+1 active=active+1 maximum=math.max(maximum,active)
  coroutine.yield('http')active=active-1
 end
 return originalHttp(self,url)
end
local main=task.spawn(assert(load(BOOT_SOURCE)))
for tick=1,200 do
 local pending=false
 for _,thread in ipairs(queue)do if coroutine.status(thread)~='dead'then
  pending=true local ok,message=coroutine.resume(thread)assert(ok,message)
 end end
 if not pending then break end
end
assert(coroutine.status(main)=='dead'and TEST_LIBRARY.Toggled,'parallel startup did not finish')
assert(maximum>=4 and maximum<=5,'unbounded/serial requests '..maximum)
for name,count in pairs(calls)do assert(count==1,'duplicate successful module request '..name..':'..count)end
TEST_ACTIONS['Unload script']()TEST_DRAIN()
""".replace('or0','or 0'))
print('PASS cooperative delayed transport: bounded parallel downloads, no duplicate successful requests, dependency-order startup and cleanup')
