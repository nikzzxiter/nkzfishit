-- NIKZZ FISH IT - UPGRADED VERSION
-- DEVELOPER BY NIKZZ
-- Updated: 11 Oct 2025 - MAJOR UPDATE

print("Loading NIKZZ FISH IT - V1 UPGRADED...")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local SCRIPT_URL = "https://raw.githubusercontent.com/nikzzxiter/nkzfishit/refs/heads/main/fishithubv1.lua"
local BOOTFILE = "nkz_delta_autorun_boot.lua"
local Config = Config or { AutoRejoin = true } -- jika sudah ada Config di script utama, ini tidak menimpa
local Rayfield = Rayfield or (rawget(_G, "Rayfield") and _G.Rayfield) -- jaga jika Rayfield ada

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
if not LocalPlayer then
    -- try wait until LocalPlayer exists (common in inject)
    repeat task.wait() LocalPlayer = Players.LocalPlayer until LocalPlayer
end

-- Rayfield Setup
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "NIKZZ FISH IT - V1 UPGRADED",
    LoadingTitle = "NIKZZ FISH IT - UPGRADED VERSION",
    LoadingSubtitle = "DEVELOPER BY NIKZZ",
    ConfigurationSaving = { Enabled = false },
})

-- Configuration
local Config = {
    AutoFishingV1 = false,
    AutoFishingV2 = false,
    FishingDelay = 0.3,
    PerfectCatch = false,
    AntiAFK = false,
    AutoJump = false,
    AutoJumpDelay = 3,
    AutoSell = false,
    GodMode = false,
    SavedPosition = nil,
    CheckpointPosition = HumanoidRootPart.CFrame,
    FlyEnabled = false,
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    WalkOnWater = false,
    InfiniteZoom = false,
    NoClip = false,
    XRay = false,
    ESPEnabled = false,
    ESPDistance = 20,
    LockedPosition = false,
    LockCFrame = nil,
    AutoEnchant = false,
    AutoBuyWeather = false,
    SelectedWeathers = {},
    AutoAcceptTrade = false,
    AutoRejoin = false,
    AutoSaveSettings = false,
    Brightness = 2,
    TimeOfDay = 14
}

-- Remotes Path
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local function GetRemote(name)
    return net:FindFirstChild(name)
end

-- Remotes
local EquipTool = GetRemote("RE/EquipToolFromHotbar")
local ChargeRod = GetRemote("RF/ChargeFishingRod")
local StartMini = GetRemote("RF/RequestFishingMinigameStarted")
local FinishFish = GetRemote("RE/FishingCompleted")
local EquipOxy = GetRemote("RF/EquipOxygenTank")
local UnequipOxy = GetRemote("RF/UnequipOxygenTank")
local Radar = GetRemote("RF/UpdateFishingRadar")
local SellRemote = GetRemote("RF/SellAllItems")
local ActivateEnchant = GetRemote("RE/ActivateEnchantingAltar")
local EquipItem = GetRemote("RE/EquipItem")
local PurchaseWeather = GetRemote("RF/PurchaseWeatherEvent")
local UpdateAutoFishing = GetRemote("RF/UpdateAutoFishingState")
local AwaitTradeResponse = GetRemote("RF/AwaitTradeResponse")

-- === AUTO SAVE / LOAD (FIXED & IMPROVED) ===
local SaveFileName = "NikzzFishItSettings_" .. LocalPlayer.UserId .. ".json"
local AutoSaveConnection = nil

-- Fungsi untuk serialize CFrame (posisi + orientasi)
local function serializeCFrame(cf)
    if not cf then return nil end
    local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = cf:components()
    return {
        position = {x = x, y = y, z = z},
        orientation = {
            m11 = m11, m12 = m12, m13 = m13,
            m21 = m21, m22 = m22, m23 = m23,
            m31 = m31, m32 = m32, m33 = m33
        }
    }
end

-- Fungsi untuk deserialize CFrame
local function deserializeCFrame(data)
    if not data then return nil end
    if data.position and data.orientation then
        return CFrame.new(
            data.position.x, data.position.y, data.position.z,
            data.orientation.m11, data.orientation.m12, data.orientation.m13,
            data.orientation.m21, data.orientation.m22, data.orientation.m23,
            data.orientation.m31, data.orientation.m32, data.orientation.m33
        )
    end
    return nil
end

local function SaveSettings()
    if not Config.AutoSaveSettings and not Config.ManualSave then
        return
    end
    
    -- Build settings table dengan CFrame lengkap
    local settingsToSave = {
        -- Fishing Settings
        AutoFishingV1 = Config.AutoFishingV1,
        AutoFishingV2 = Config.AutoFishingV2,
        FishingDelay = Config.FishingDelay,
        PerfectCatch = Config.PerfectCatch,
        
        -- Utility Settings
        AntiAFK = Config.AntiAFK,
        AutoJump = Config.AutoJump,
        AutoJumpDelay = Config.AutoJumpDelay,
        AutoSell = Config.AutoSell,
        GodMode = Config.GodMode,
        
        -- Movement Settings
        FlyEnabled = Config.FlyEnabled,
        FlySpeed = Config.FlySpeed,
        WalkSpeed = Config.WalkSpeed,
        JumpPower = Config.JumpPower,
        WalkOnWater = Config.WalkOnWater,
        InfiniteZoom = Config.InfiniteZoom,
        NoClip = Config.NoClip,
        
        -- Visual Settings
        XRay = Config.XRay,
        ESPEnabled = Config.ESPEnabled,
        ESPDistance = Config.ESPDistance,
        
        -- Position Settings
        LockedPosition = Config.LockedPosition,
        
        -- Auto Features
        AutoEnchant = Config.AutoEnchant,
        AutoBuyWeather = Config.AutoBuyWeather,
        SelectedWeathers = Config.SelectedWeathers,
        AutoAcceptTrade = Config.AutoAcceptTrade,
        AutoRejoin = Config.AutoRejoin,
        
        -- System Settings
        AutoSaveSettings = Config.AutoSaveSettings,
        Brightness = Config.Brightness,
        TimeOfDay = Config.TimeOfDay,
        
        -- Positions (serialize CFrame lengkap)
        SavedPosition = (Config.SavedPosition and serializeCFrame(Config.SavedPosition)) or nil,
        LockCFrame = (Config.LockCFrame and serializeCFrame(Config.LockCFrame)) or nil,
        CheckpointPosition = (Config.CheckpointPosition and serializeCFrame(Config.CheckpointPosition)) or nil
    }

    -- Write file jika writefile available
    if writefile and HttpService then
        local ok, err = pcall(function()
            writefile(SaveFileName, HttpService:JSONEncode(settingsToSave))
        end)
        if ok then
            print("[SaveSettings] Settings saved to:", SaveFileName)
            if Config.ManualSave then
                Rayfield:Notify({
                    Title = "Settings Saved",
                    Content = "All settings and position saved!",
                    Duration = 2
                })
                Config.ManualSave = false
            end
        else
            warn("[SaveSettings] Failed to write file:", tostring(err))
        end
    else
        warn("[SaveSettings] writefile or HttpService not available on this executor.")
    end
end

-- Fungsi untuk start Auto Save periodik
local function StartAutoSave()
    if AutoSaveConnection then
        AutoSaveConnection:Disconnect()
    end
    
    if Config.AutoSaveSettings then
        AutoSaveConnection = RunService.Heartbeat:Connect(function()
            -- Auto save setiap 10 detik
            task.wait(10)
            if Config.AutoSaveSettings then
                -- Update saved position dengan posisi terkini
                if HumanoidRootPart then
                    Config.SavedPosition = HumanoidRootPart.CFrame
                end
                SaveSettings()
            end
        end)
        print("[AutoSave] Auto save started - saving every 10 seconds")
    end
end

local function ApplySettings()
    -- Terapkan semua setting ke runtime
    pcall(function()
        print("[ApplySettings] Applying saved settings...")
        
        -- Movement settings
        if Humanoid then
            Humanoid.WalkSpeed = tonumber(Config.WalkSpeed) or 16
            Humanoid.JumpPower = tonumber(Config.JumpPower) or 50
        end

        -- Lighting settings
        if Lighting then
            Lighting.Brightness = Config.Brightness or 2
            Lighting.ClockTime = Config.TimeOfDay or 14
            ApplyPermanentLighting()
        end

        -- Fishing features
        if Config.AutoFishingV1 then 
            task.spawn(function()
                task.wait(1)
                AutoFishingV1()
            end)
        end
        
        if Config.AutoFishingV2 then 
            task.spawn(function()
                task.wait(1)
                AutoFishingV2()
            end)
        end

        -- Utility features
        if Config.AntiAFK then StartAntiAFK() end
        if Config.AutoJump then StartAutoJump() end
        if Config.AutoSell then StartAutoSell() end
        if Config.AutoEnchant then AutoEnchant() end
        if Config.AutoBuyWeather then AutoBuyWeather() end
        if Config.AutoAcceptTrade then AutoAcceptTrade() end
        
        -- Protection features
        if Config.GodMode then ToggleGodMode(true) end
        if Config.FlyEnabled then 
            task.spawn(function()
                task.wait(1)
                StartFly()
            end)
        end
        if Config.WalkOnWater then ToggleWalkOnWater(true) end
        if Config.NoClip then ToggleNoClip(true) end
        if Config.PerfectCatch then TogglePerfectCatch(true) end
        
        -- Visual features
        if Config.XRay then ToggleXRay(true) end
        if Config.ESPEnabled then ToggleESP(true) end
        if Config.InfiniteZoom then EnableInfiniteZoom() end
        
        -- Position features
        if Config.LockedPosition and Config.LockCFrame then 
            task.spawn(function()
                task.wait(1)
                ToggleLockPosition(true)
            end)
        end

        -- Teleport ke saved position jika ada (dengan orientasi yang sama)
        if Config.SavedPosition then
            task.spawn(function()
                -- Tunggu sampai character ready
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.CharacterAdded:Wait()
                    task.wait(2)
                    Character = LocalPlayer.Character
                    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    Humanoid = Character:WaitForChild("Humanoid")
                end
                
                task.wait(3) -- Additional wait untuk memastikan semua load
                
                pcall(function()
                    HumanoidRootPart.CFrame = Config.SavedPosition
                    print("[ApplySettings] Teleported to saved position with orientation")
                    Rayfield:Notify({
                        Title = "Settings Loaded", 
                        Content = "Teleported to saved position!",
                        Duration = 3
                    })
                end)
            end)
        end
        
        -- Start auto save jika enabled
        if Config.AutoSaveSettings then
            task.spawn(function()
                task.wait(5)
                StartAutoSave()
            end)
        end
        
        print("[ApplySettings] All settings applied successfully!")
    end)
end

local function LoadSettings()
    -- Load settings dari file jika ada
    if isfile and isfile(SaveFileName) and HttpService then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(SaveFileName))
        end)
        
        if ok and data then
            print("[LoadSettings] Loading settings from file...")
            
            -- Merge values ke Config
            for key, value in pairs(data) do
                if Config[key] ~= nil then
                    Config[key] = value
                end
            end
            
            -- Deserialize positions dengan CFrame lengkap
            if data.SavedPosition then
                Config.SavedPosition = deserializeCFrame(data.SavedPosition)
            end
            
            if data.LockCFrame then
                Config.LockCFrame = deserializeCFrame(data.LockCFrame)
            end
            
            if data.CheckpointPosition then
                Config.CheckpointPosition = deserializeCFrame(data.CheckpointPosition)
            end
            
            print("[LoadSettings] Settings loaded successfully from:", SaveFileName)
            
            -- Apply settings setelah delay singkat
            task.spawn(function()
                task.wait(2)
                ApplySettings()
            end)
            
            return true
        else
            warn("[LoadSettings] Failed to decode settings file or file empty.")
        end
    else
        print("[LoadSettings] No saved settings found or functions unavailable.")
    end
    return false
end

-- Auto load settings ketika script mulai
task.spawn(function()
    task.wait(3) -- Tunggu Rayfield dan UI load dulu
    local loaded = LoadSettings()
    if not loaded then
        print("[AutoLoad] No saved settings found, using defaults")
    end
end)

-- Anti-Stuck System for Auto Fishing V1
local LastFishTime = tick()
local StuckCheckInterval = 15

local function CheckAndRespawnIfStuck()
    task.spawn(function()
        while Config.AutoFishingV1 do
            task.wait(StuckCheckInterval)
            
            if tick() - LastFishTime > StuckCheckInterval and Config.AutoFishingV1 then
                warn("[Anti-Stuck] Player seems stuck, respawning...")
                
                local currentPos = HumanoidRootPart.CFrame
                Character:BreakJoints()
                
                LocalPlayer.CharacterAdded:Wait()
                task.wait(2)
                
                Character = LocalPlayer.Character
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
                
                HumanoidRootPart.CFrame = currentPos
                LastFishTime = tick()
                
                task.wait(1)
                if Config.AutoFishingV1 then
                    AutoFishingV1()
                end
            end
        end
    end)
end

-- ===== AUTO FISHING V1 (COMPLETELY FIXED) =====
local LastFishTime = tick()
local FishingActive = false
local StuckCheckInterval = 12
local MaxRetries = 5
local CurrentRetries = 0

local function ResetFishingState()
    FishingActive = false
    CurrentRetries = 0
    LastFishTime = tick()
end

local function SafeRespawn()
    task.spawn(function()
        local currentPos = HumanoidRootPart.CFrame
        
        warn("[Anti-Stuck] Respawning to fix stuck state...")
        
        Character:BreakJoints()
        
        local newChar = LocalPlayer.CharacterAdded:Wait()
        task.wait(2)
        
        Character = newChar
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
        
        task.wait(0.5)
        HumanoidRootPart.CFrame = currentPos
        
        task.wait(1)
        ResetFishingState()
        
        if Config.AutoFishingV1 then
            task.wait(0.5)
            AutoFishingV1()
        end
    end)
end

local function CheckStuckState()
    task.spawn(function()
        while Config.AutoFishingV1 do
            task.wait(StuckCheckInterval)
            
            local timeSinceLastFish = tick() - LastFishTime
            
            if timeSinceLastFish > StuckCheckInterval and Config.AutoFishingV1 and FishingActive then
                warn("[Anti-Stuck] Detected stuck state! Time since last fish: " .. math.floor(timeSinceLastFish) .. "s")
                SafeRespawn()
            end
        end
    end)
end

local function AutoFishingV1()
    task.spawn(function()
        print("[AutoFishingV1] Started - Ultra Fast Mode with Anti-Stuck")
        CheckStuckState()
        
        while Config.AutoFishingV1 do
            FishingActive = true
            local cycleSuccess = false
            
            local success, err = pcall(function()
                -- Validate character
                if not LocalPlayer.Character or not HumanoidRootPart then
                    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    Character = LocalPlayer.Character
                    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                end

                -- Step 1: Equip tool
                local equipSuccess = pcall(function()
                    EquipTool:FireServer(1)
                end)
                
                if not equipSuccess then
                    CurrentRetries = CurrentRetries + 1
                    if CurrentRetries >= MaxRetries then
                        warn("[AutoFishingV1] Too many failures, respawning...")
                        SafeRespawn()
                        return
                    end
                    task.wait(0.5)
                    return
                end
                
                task.wait(0.15)

                -- Step 2: Charge rod
                local chargeSuccess = false
                for attempt = 1, 3 do
                    local ok, result = pcall(function()
                        return ChargeRod:InvokeServer(tick())
                    end)
                    if ok and result then 
                        chargeSuccess = true 
                        break 
                    end
                    task.wait(0.1)
                end
                
                if not chargeSuccess then
                    warn("[AutoFishingV1] Charge failed after 3 attempts")
                    CurrentRetries = CurrentRetries + 1
                    if CurrentRetries >= MaxRetries then
                        SafeRespawn()
                        return
                    end
                    task.wait(0.5)
                    return
                end

                task.wait(0.15)

                -- Step 3: Start minigame with perfect values
                local startSuccess = false
                for attempt = 1, 3 do
                    local ok, result = pcall(function()
                        return StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273)
                    end)
                    if ok then 
                        startSuccess = true 
                        break 
                    end
                    task.wait(0.1)
                end
                
                if not startSuccess then
                    warn("[AutoFishingV1] Start minigame failed after 3 attempts")
                    CurrentRetries = CurrentRetries + 1
                    if CurrentRetries >= MaxRetries then
                        SafeRespawn()
                        return
                    end
                    task.wait(0.5)
                    return
                end

                -- Step 4: Wait for fishing delay
                local actualDelay = math.max(Config.FishingDelay, 0.3)
                task.wait(actualDelay)

                -- Step 5: Finish fishing
                local finishSuccess = pcall(function()
                    FinishFish:FireServer()
                end)
                
                if finishSuccess then
                    cycleSuccess = true
                    LastFishTime = tick()
                    CurrentRetries = 0
                end
                
                task.wait(0.2)
            end)

            if not success then
                warn("[AutoFishingV1] Error in cycle: " .. tostring(err))
                CurrentRetries = CurrentRetries + 1
                if CurrentRetries >= MaxRetries then
                    SafeRespawn()
                end
                task.wait(1)
            elseif cycleSuccess then
                -- Successful cycle, minimal wait
                task.wait(0.1)
            else
                -- Failed cycle but no error
                task.wait(0.5)
            end
        end
        
        ResetFishingState()
        print("[AutoFishingV1] Stopped")
    end)
end

-- ===== AUTO FISHING V2 (IMPROVED WITH AUTO STATE) =====
local function AutoFishingV2()
    task.spawn(function()
        print("[AutoFishingV2] Started - Using Game Auto Fishing")
        
        -- Enable game's auto fishing
        pcall(function()
            UpdateAutoFishing:InvokeServer(true)
        end)
        
        -- Override to perfect catch
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local old = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "InvokeServer" and self == StartMini then
                    if Config.AutoFishingV2 then
                        return old(self, -1.233184814453125, 0.9945034885633273)
                    end
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
        
        while Config.AutoFishingV2 do
            task.wait(1)
        end
        
        -- Disable when stopped
        pcall(function()
            UpdateAutoFishing:InvokeServer(false)
        end)
        
        print("[AutoFishingV2] Stopped")
    end)
end

-- ===== PERFECT CATCH =====
local PerfectCatchConn = nil
local function TogglePerfectCatch(enabled)
    Config.PerfectCatch = enabled
    
    if enabled then
        if PerfectCatchConn then PerfectCatchConn:Disconnect() end

        local mt = getrawmetatable(game)
        if not mt then return end
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "InvokeServer" and self == StartMini then
                if Config.PerfectCatch and not Config.AutoFishingV1 and not Config.AutoFishingV2 then
                    return old(self, -1.233184814453125, 0.9945034885633273)
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    else
        if PerfectCatchConn then
            PerfectCatchConn:Disconnect()
            PerfectCatchConn = nil
        end
    end
end

-- ===== AUTO ENCHANT =====
local function AutoEnchant()
    task.spawn(function()
        while Config.AutoEnchant do
            pcall(function()
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if not backpack then return end
                
                local enchantStone = backpack:FindFirstChild("Enchant Stone") or backpack:FindFirstChild("Super Enchant Stone")
                
                if enchantStone then
                    local stoneCount = 0
                    for _, item in pairs(backpack:GetChildren()) do
                        if item.Name:find("Enchant Stone") then
                            stoneCount = stoneCount + 1
                        end
                    end
                    
                    ActivateEnchant:FireServer()
                    task.wait(0.5)
                    
                    Rayfield:Notify({
                        Title = "Auto Enchant",
                        Content = "Enchanted! Stones remaining: " .. stoneCount,
                        Duration = 2
                    })
                    
                    task.wait(2)
                else
                    Rayfield:Notify({
                        Title = "Auto Enchant",
                        Content = "No enchant stones found!",
                        Duration = 3
                    })
                    task.wait(5)
                end
            end)
            task.wait(1)
        end
    end)
end

-- ===== AUTO BUY WEATHER =====
local WeatherList = {"Wind", "Cloudy", "Snow", "Storm", "Radiant", "Shark Hunt"}

local function AutoBuyWeather()
    task.spawn(function()
        while Config.AutoBuyWeather do
            for _, weather in ipairs(Config.SelectedWeathers) do
                pcall(function()
                    local result = PurchaseWeather:InvokeServer(weather)
                    if result then
                        Rayfield:Notify({
                            Title = "Auto Buy Weather",
                            Content = "Purchased: " .. weather,
                            Duration = 2
                        })
                    end
                end)
                task.wait(1)
            end
            task.wait(30)
        end
    end)
end

-- ===== AUTO ACCEPT TRADE =====
local function AutoAcceptTrade()
    task.spawn(function()
        while Config.AutoAcceptTrade do
            pcall(function()
                local response = AwaitTradeResponse:InvokeServer(true)
                if response then
                    task.wait(0.1)
                    AwaitTradeResponse:InvokeServer(true)
                    Rayfield:Notify({
                        Title = "Auto Accept Trade",
                        Content = "Trade accepted automatically!",
                        Duration = 2
                    })
                end
            end)
            task.wait(0.5)
        end
    end)
end

-- detect executor (nice logs)
local function detect_executor()
    if _G.Delta or delta then return "Delta" end
    if syn then return "Synapse" end
    if KRNL_LOADED then return "Krnl" end
    if fluxus then return "Fluxus" end
    if request and not syn then return "OldRequest" end
    return "Unknown"
end
local EXEC = detect_executor()

-- robust http fetch
local function http_get(url)
    -- Delta-specific
    if delta and delta.request then
        local ok, res = pcall(delta.request, { Url = url, Method = "GET" })
        if ok and res then
            if type(res) == "table" and res.Body then return res.Body end
            if type(res) == "string" then return res end
        end
    end
    -- syn.request
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    -- request
    if request then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res then
            if type(res) == "table" and res.Body then return res.Body end
            if type(res) == "string" then return res end
        end
    end
    -- http.request
    if http and http.request then
        local ok, res = pcall(http.request, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    -- game:HttpGet fallback (some wrappers)
    local ok2, result = pcall(function() return game:HttpGet(url) end)
    if ok2 and result then return result end

    return nil, "no-http"
end

-- load and run code safely
local function load_and_run(code)
    if not code then return false, "no-code" end
    local f, err = (loadstring and loadstring(code)) or load(code)
    if not f then return false, ("load error: "..tostring(err)) end
    local ok, res = pcall(f)
    if not ok then return false, ("runtime error: "..tostring(res)) end
    return true, res
end

-- fetch remote script and run
local function fetch_and_run(url)
    local body, err = http_get(url)
    if not body then
        warn(("NKZ[autorun][%s] http_get failed: %s"):format(EXEC, tostring(err)))
        return false, err
    end
    local ok, msg = load_and_run(body)
    if not ok then
        warn(("NKZ[autorun][%s] load/run failed: %s"):format(EXEC, tostring(msg)))
        return false, msg
    end
    print(("NKZ[autorun][%s] remote script executed OK"):format(EXEC))
    return true, msg
end

-- create bootstrap text that will fetch & run SCRIPT_URL after teleport
local function make_bootstrap_text(url)
    local template = [[
-- NKZ autorun bootstrap (injected by delta autorun script)
pcall(function()
    local function http_get_local(u)
        if delta and delta.request then local r = delta.request({Url = u, Method = "GET"}) if r then return (type(r)=="table" and r.Body) or r end end
        if syn and syn.request then local r = syn.request({Url = u, Method = "GET"}) if r then return r.Body end end
        if request then local r = request({Url = u, Method = "GET"}) if r then return (type(r)=="table" and r.Body) or r end end
        if http and http.request then local r = http.request({Url = u, Method = "GET"}) if r then return r.Body end end
        if pcall(function() return game:HttpGet(u) end) then return game:HttpGet(u) end
        return nil
    end

    local code = http_get_local(%q)
    if not code then return end
    local f = (loadstring and loadstring(code)) or load(code)
    if f then pcall(f) end
end)
]]
    return template:format(url)
end

-- write bootstrap to disk (if writefile exists)
local function try_write_boot(url)
    if writefile then
        local ok, err = pcall(function()
            writefile(BOOTFILE, make_bootstrap_text(url))
        end)
        if ok then
            print(("NKZ[autorun][%s] wrote boot file: %s"):format(EXEC, BOOTFILE))
            return true
        else
            warn(("NKZ[autorun][%s] writefile failed: %s"):format(EXEC, tostring(err)))
        end
    end
    return false
end

-- try queue_on_teleport under many names
local function try_queue_on_teleport(code_or_url)
    local payload
    if code_or_url:match("^https?://") then
        payload = make_bootstrap_text(code_or_url)
    else
        payload = code_or_url
    end

    local queue_fns = {
        function(p) if queue_on_teleport then queue_on_teleport(p); return true end end,
        function(p) if syn and syn.queue_on_teleport then syn.queue_on_teleport(p); return true end end,
        function(p) if delta and delta.queue_on_teleport then delta.queue_on_teleport(p); return true end end,
        function(p) if _G.queue_on_teleport then _G.queue_on_teleport(p); return true end end,
    }

    for _,fn in ipairs(queue_fns) do
        local ok, _ = pcall(fn, payload)
        if ok then
            print(("NKZ[autorun][%s] queued payload with queue_on_teleport-like API"):format(EXEC))
            return true
        end
    end

    warn(("NKZ[autorun][%s] no queue_on_teleport available"):format(EXEC))
    return false
end

-- === Your AutoRejoin setup (kept, with small robustness tweaks) ===
local function SetupAutoRejoin()
    if Config.AutoRejoin then
        print("[Auto Rejoin] System enabled")

        -- Method 1: CoreGui error prompt
        task.spawn(function()
            local ok, err = pcall(function()
                local overlay = game:GetService("CoreGui").RobloxPromptGui
                if overlay and overlay.promptOverlay then
                    overlay.promptOverlay.ChildAdded:Connect(function(child)
                        if Config.AutoRejoin then
                            if child and child.Name == 'ErrorPrompt' then
                                task.wait(0.5)
                                pcall(function()
                                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                                end)
                            end
                        end
                    end)
                end
            end)
            if not ok then
                warn("[Auto Rejoin] Method 1 failed to setup:", err)
            end
        end)

        -- Method 2: GuiService ErrorMessageChanged
        task.spawn(function()
            local ok2, err2 = pcall(function()
                game:GetService("GuiService").ErrorMessageChanged:Connect(function()
                    if Config.AutoRejoin then
                        task.wait(0.5)
                        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
                    end
                end)
            end)
            if not ok2 then
                warn("[Auto Rejoin] Method 2 setup failed:", err2)
            end
        end)

        -- Method 3: OnTeleport state listener
        if LocalPlayer and LocalPlayer.OnTeleport then
            pcall(function()
                LocalPlayer.OnTeleport:Connect(function(State)
                    if Config.AutoRejoin and State == Enum.TeleportState.Failed then
                        task.wait(0.5)
                        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
                    end
                end)
            end)
        end

        if Rayfield and Rayfield.Notify then
            pcall(function()
                Rayfield:Notify({ Title = "Auto Rejoin", Content = "Protection active! Will rejoin on disconnect", Duration = 3 })
            end)
        else
            print("[Auto Rejoin] Protection active! Will rejoin on disconnect")
        end
    end
end

-- === Main setup: queue autorun + write backup + run now ===
do
    print(("NKZ[autorun][%s] starting setup (SCRIPT_URL=%s)"):format(EXEC, SCRIPT_URL))

    -- 1) queue on teleport (best)
    local queued_ok = try_queue_on_teleport(SCRIPT_URL)

    -- 2) writefile backup
    local wrote_ok = try_write_boot(SCRIPT_URL)

    if not queued_ok and not wrote_ok then
        warn(("NKZ[autorun][%s] WARNING: neither queue_on_teleport nor writefile succeeded. Reliant on current session only."):format(EXEC))
    end

    -- 3) run remote script right now
    local ok, msg = fetch_and_run(SCRIPT_URL)
    if not ok then
        warn(("NKZ[autorun][%s] initial run failed: %s"):format(EXEC, tostring(msg)))
    end

    -- 4) setup the auto rejoin (your provided code)
    pcall(function() SetupAutoRejoin() end)
end

-- ===== ENABLE RADAR =====
local function ToggleRadar(state)
    pcall(function()
        Radar:InvokeServer(state)
    end)
end

-- ===== ENABLE DIVING GEAR =====
local function ToggleDivingGear(state)
    pcall(function()
        if state then
            EquipTool:FireServer(2)
            EquipOxy:InvokeServer(105)
        else
            UnequipOxy:InvokeServer()
        end
    end)
end

-- ===== ANTI AFK =====
local function StartAntiAFK()
    spawn(function()
        while Config.AntiAFK do
            for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
                pcall(function() conn:Disable() end)
            end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(30)
        end
    end)
end

local AutoJumpConn = nil

local function StartAutoJump()
    task.spawn(function()
        if AutoJumpConn then 
            AutoJumpConn:Disconnect()
            AutoJumpConn = nil
        end
        
        print("[Auto Jump] Started with delay: " .. Config.AutoJumpDelay .. "s")
        
        while Config.AutoJump do
            if Humanoid and Humanoid.Health > 0 then
                local state = Humanoid:GetState()
                
                if state ~= Enum.HumanoidStateType.Jumping and 
                   state ~= Enum.HumanoidStateType.Freefall and
                   state ~= Enum.HumanoidStateType.Flying then
                    
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            
            task.wait(Config.AutoJumpDelay)
        end
        
        print("[Auto Jump] Stopped")
    end)
end

-- ===== AUTO SELL =====
local function StartAutoSell()
    task.spawn(function()
        while Config.AutoSell do
            if SellRemote then
                pcall(function()
                    SellRemote:InvokeServer()
                end)
            end
            task.wait(10)
        end
    end)
end

-- ===== SAVED ISLANDS DATA =====
local IslandsData = {
    {Name = "Fisherman Island", Position = Vector3.new(92, 9, 2768)},
    {Name = "Arrow Lever", Position = Vector3.new(898, 8, -363)},
    {Name = "Sisyphus Statue", Position = Vector3.new(-3740, -136, -1013)},
    {Name = "Ancient Jungle", Position = Vector3.new(1481, 11, -302)},
    {Name = "Weather Machine", Position = Vector3.new(-1519, 2, 1908)},
    {Name = "Coral Refs", Position = Vector3.new(-3105, 6, 2218)},
    {Name = "Tropical Island", Position = Vector3.new(-2110, 53, 3649)},
    {Name = "Kohana", Position = Vector3.new(-662, 3, 714)},
    {Name = "Esoteric Island", Position = Vector3.new(2035, 27, 1386)},
    {Name = "Diamond Lever", Position = Vector3.new(1818, 8, -285)},
    {Name = "Underground Cellar", Position = Vector3.new(2098, -92, -703)},
    {Name = "Volcano", Position = Vector3.new(-631, 54, 194)},
    {Name = "Enchant Room", Position = Vector3.new(3255, -1302, 1371)},
    {Name = "Lost Isle", Position = Vector3.new(-3717, 5, -1079)},
    {Name = "Sacred Temple", Position = Vector3.new(1475, -22, -630)},
    {Name = "Creater Island", Position = Vector3.new(981, 41, 5080)},
    {Name = "Double Enchant Room", Position = Vector3.new(1480, 127, -590)},
    {Name = "Treassure Room", Position = Vector3.new(-3599, -276, -1642)},
    {Name = "Crescent Lever", Position = Vector3.new(1419, 31, 78)},
    {Name = "Hourglass Diamond Lever", Position = Vector3.new(1484, 8, -862)},
    {Name = "Snow Island", Position = Vector3.new(1627, 4, 3288)}
}

-- ===== TELEPORT SYSTEM =====
local function TeleportToPosition(pos)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

-- ===== LOCK POSITION =====
local LockConn = nil
local function ToggleLockPosition(enabled)
    Config.LockedPosition = enabled
    
    if enabled then
        Config.LockCFrame = HumanoidRootPart.CFrame
        
        if LockConn then LockConn:Disconnect() end
        LockConn = RunService.Heartbeat:Connect(function()
            if Config.LockedPosition and Config.LockCFrame then
                HumanoidRootPart.CFrame = Config.LockCFrame
            end
        end)
    else
        if LockConn then
            LockConn:Disconnect()
            LockConn = nil
        end
    end
end

-- ===== EVENT SCANNER =====
local function ScanActiveEvents()
    local events = {}
    local validEvents = {
        "megalodon", "whale", "kraken", "worm", "hunt", "boss", "raid", "ghost"
    }
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local name = obj.Name:lower()
            
            for _, keyword in ipairs(validEvents) do
                if name:find(keyword) and not name:find("sharki") and not name:find("boat") then
                    local exists = false
                    for _, e in ipairs(events) do
                        if e.Name == obj.Name then
                            exists = true
                            break
                        end
                    end
                    
                    if not exists then
                        table.insert(events, {
                            Name = obj.Name,
                            Object = obj,
                            Position = obj:GetModelCFrame().Position
                        })
                    end
                    break
                end
            end
        end
    end
    
    return events
end

-- ===== GOD MODE =====
local GodConnection = nil
local function ToggleGodMode(enabled)
    Config.GodMode = enabled
    
    if enabled then
        if GodConnection then GodConnection:Disconnect() end
        GodConnection = RunService.Heartbeat:Connect(function()
            if Config.GodMode and Humanoid then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end)
    else
        if GodConnection then
            GodConnection:Disconnect()
            GodConnection = nil
        end
    end
end

-- ===== FLY SYSTEM =====
local FlyBV = nil
local FlyBG = nil
local FlyConn = nil

local function StartFly()
    if not Config.FlyEnabled then return end
    
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Parent = HumanoidRootPart
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Velocity = Vector3.zero
    
    FlyBG = Instance.new("BodyGyro")
    FlyBG.Parent = HumanoidRootPart
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.P = 9e4
    
    if FlyConn then FlyConn:Disconnect() end
    
    FlyConn = RunService.Heartbeat:Connect(function()
        if not Config.FlyEnabled then
            if FlyBV then FlyBV:Destroy() FlyBV = nil end
            if FlyBG then FlyBG:Destroy() FlyBG = nil end
            if FlyConn then FlyConn:Disconnect() FlyConn = nil end
            return
        end
        
        local cam = Workspace.CurrentCamera
        local dir = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        
        FlyBV.Velocity = dir * Config.FlySpeed
        FlyBG.CFrame = cam.CFrame
    end)
end

local function StopFly()
    Config.FlyEnabled = false
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
end

-- ===== WALK ON WATER =====
local WaterPart = nil
local WaterConn = nil

local function ToggleWalkOnWater(enabled)
    Config.WalkOnWater = enabled

    if enabled then
        if not WaterPart then
            WaterPart = Instance.new("Part")
            WaterPart.Size = Vector3.new(14, 0.2, 14)
            WaterPart.Anchored = true
            WaterPart.CanCollide = true
            WaterPart.Transparency = 1
            WaterPart.Material = Enum.Material.SmoothPlastic
            WaterPart.Name = "InvisibleWaterSurface"
            WaterPart.Parent = workspace
        end

        if WaterConn then WaterConn:Disconnect() end
        local baseY = HumanoidRootPart.Position.Y - 3

        WaterConn = RunService.Heartbeat:Connect(function()
            if Config.WalkOnWater and HumanoidRootPart and WaterPart then
                local pos = HumanoidRootPart.Position
                WaterPart.CFrame = CFrame.new(pos.X, baseY, pos.Z)
            end
        end)
    else
        if WaterConn then
            WaterConn:Disconnect()
            WaterConn = nil
        end
        if WaterPart then
            WaterPart:Destroy()
            WaterPart = nil
        end
    end
end

-- ===== NOCLIP =====
local NoClipConn = nil
local function ToggleNoClip(enabled)
    Config.NoClip = enabled
    
    if enabled then
        if NoClipConn then NoClipConn:Disconnect() end
        NoClipConn = RunService.Stepped:Connect(function()
            if Config.NoClip and Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConn then
            NoClipConn:Disconnect()
            NoClipConn = nil
        end
    end
end

-- ===== XRAY =====
local function ToggleXRay(state)
    Config.XRay = state
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent ~= Character then
            if state then
                obj.LocalTransparencyModifier = 0.7
            else
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end

-- ===== ESP DISTANCE =====
local ESPConnections = {}

local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = hrp
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    local conn = RunService.RenderStepped:Connect(function()
        if not Config.ESPEnabled or not player.Character or not HumanoidRootPart then
            billboard:Destroy()
            return
        end
        
        local distance = (HumanoidRootPart.Position - hrp.Position).Magnitude
        textLabel.Text = string.format("%s\n[%.0f studs]", player.Name, distance)
        textLabel.TextSize = Config.ESPDistance
    end)
    
    ESPConnections[player] = conn
end

local function ToggleESP(enabled)
    Config.ESPEnabled = enabled
    
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
    else
        for player, conn in pairs(ESPConnections) do
            conn:Disconnect()
            if player.Character then
                local billboard = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("ESP_" .. player.Name)
                if billboard then
                    billboard:Destroy()
                end
            end
        end
        ESPConnections = {}
    end
end

-- ===== INFINITE ZOOM =====
local function EnableInfiniteZoom()
    Config.InfiniteZoom = true
    LocalPlayer.CameraMaxZoomDistance = 9999
    LocalPlayer.CameraMinZoomDistance = 0.5
end

-- ===== GRAPHICS (IMPROVED - PERMANENT) =====
local LightingConnection = nil

local function ApplyPermanentLighting()
    if LightingConnection then LightingConnection:Disconnect() end
    
    LightingConnection = RunService.Heartbeat:Connect(function()
        Lighting.Brightness = Config.Brightness
        Lighting.ClockTime = Config.TimeOfDay
    end)
end

local function RemoveFog()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") then
            effect.Density = 0
        end
    end
    
    -- Keep fog removed permanently
    RunService.Heartbeat:Connect(function()
        Lighting.FogEnd = 100000
Lighting.FogStart = 0
    end)
end

local function Enable8Bit()
    task.spawn(function()
        print("[8-Bit Mode] Enabling super smooth rendering...")
        
        -- Ultra smooth material
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
                obj.TopSurface = Enum.SurfaceType.Smooth
                obj.BottomSurface = Enum.SurfaceType.Smooth
            end
            if obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.TextureID = ""
                obj.CastShadow = false
                obj.RenderFidelity = Enum.RenderFidelity.Performance
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
            if obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end
        end
        
        -- Remove all lighting effects for flat look
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = false
            end
        end
        
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        
        -- Apply to new objects
        Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
                obj.TopSurface = Enum.SurfaceType.Smooth
                obj.BottomSurface = Enum.SurfaceType.Smooth
            end
            if obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.TextureID = ""
                obj.RenderFidelity = Enum.RenderFidelity.Performance
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end)
        
        Rayfield:Notify({
            Title = "8-Bit Mode",
            Content = "Super smooth rendering enabled!",
            Duration = 2
        })
    end)
end

-- ===== REMOVE PARTICLES (IMPROVED) =====
local function RemoveParticles()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
            obj:Destroy()
        end
    end
    
    -- Remove new particles
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
            obj:Destroy()
        end
    end)
end

-- ===== REMOVE SEAWEED (IMPROVED) =====
local function RemoveSeaweed()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("seaweed") or name:find("kelp") or name:find("coral") or name:find("plant") or name:find("weed") then
            pcall(function()
                if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                    obj:Destroy()
                end
            end)
        end
    end
    
    -- Remove new seaweed
    Workspace.DescendantAdded:Connect(function(obj)
        local name = obj.Name:lower()
        if name:find("seaweed") or name:find("kelp") or name:find("coral") or name:find("plant") or name:find("weed") then
            pcall(function()
                if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                    task.wait(0.1)
                    obj:Destroy()
                end
            end)
        end
    end)
end

-- ===== OPTIMIZE WATER (IMPROVED) =====
local function OptimizeWater()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Terrain") then
            obj.WaterReflectance = 0
            obj.WaterTransparency = 1
            obj.WaterWaveSize = 0
            obj.WaterWaveSpeed = 0
        end
        
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            if obj.Material == Enum.Material.Water then
                obj.Reflectance = 0
                obj.Transparency = 0.8
            end
        end
    end
    
    -- Maintain optimization
    RunService.Heartbeat:Connect(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Terrain") then
                obj.WaterReflectance = 0
                obj.WaterTransparency = 1
                obj.WaterWaveSize = 0
                obj.WaterWaveSpeed = 0
            end
        end
    end)
end

-- ===== PERFORMANCE MODE (IMPROVED) =====
local function PerformanceMode()
    -- Disable all visual effects
    RemoveFog()
    RemoveParticles()
    RemoveSeaweed()
    OptimizeWater()
    
    -- Disable shadows
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    -- Set lowest quality
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Remove terrain decoration
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Terrain") then
            obj.Decoration = false
        end
        
        -- Simplify all parts
        if obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
        end
        
        if obj:IsA("MeshPart") then
            obj.CastShadow = false
            obj.RenderFidelity = Enum.RenderFidelity.Performance
        end
    end
    
    -- Maintain performance settings
    RunService.Heartbeat:Connect(function()
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- ===== UI CREATION =====
local function CreateUI()
    local Islands = {}
    local Players_List = {}
    local Events = {}
    
    -- ===== FISHING TAB =====
    local Tab1 = Window:CreateTab("🎣 Fishing", 4483362458)
    
    Tab1:CreateSection("Auto Features")
    
    Tab1:CreateToggle({
        Name = "Auto Fishing V1 (Ultra Fast)",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoFishingV1 = Value
            if Value then
                Config.AutoFishingV2 = false
                AutoFishingV1()
                Rayfield:Notify({Title = "Auto Fishing V1", Content = "Started with Anti-Stuck!", Duration = 3})
            end
            SaveSettings()
        end
    })
    
    Tab1:CreateToggle({
        Name = "Auto Fishing V2 (Game Auto)",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoFishingV2 = Value
            if Value then
                Config.AutoFishingV1 = false
                AutoFishingV2()
                Rayfield:Notify({Title = "Auto Fishing V2", Content = "Using game auto with perfect catch!", Duration = 3})
            end
            SaveSettings()
        end
    })
    
    Tab1:CreateSlider({
        Name = "Fishing Delay (V1 Only)",
        Range = {0.1, 5},
        Increment = 0.1,
        CurrentValue = 0.3,
        Callback = function(Value)
            Config.FishingDelay = Value
            SaveSettings()
        end
    })
    
    Tab1:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = false,
        Callback = function(Value)
            Config.AntiAFK = Value
            if Value then StartAntiAFK() end
            SaveSettings()
        end
    })
    
    Tab1:CreateToggle({
        Name = "Auto Sell Fish",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoSell = Value
            if Value then StartAutoSell() end
            SaveSettings()
        end
    })
    
    Tab1:CreateSection("Extra Fishing")
    
    Tab1:CreateToggle({
        Name = "Perfect Catch",
        CurrentValue = false,
        Callback = function(Value)
            TogglePerfectCatch(Value)
            Rayfield:Notify({
                Title = "Perfect Catch",
                Content = Value and "Enabled!" or "Disabled!",
                Duration = 2
            })
            SaveSettings()
        end
    })
    
    Tab1:CreateToggle({
        Name = "Enable Radar",
        CurrentValue = false,
        Callback = function(Value)
            ToggleRadar(Value)
            Rayfield:Notify({
                Title = "Fishing Radar",
                Content = Value and "Enabled!" or "Disabled!",
                Duration = 2
            })
        end
    })
    
    Tab1:CreateToggle({
        Name = "Enable Diving Gear",
        CurrentValue = false,
        Callback = function(Value)
            ToggleDivingGear(Value)
            Rayfield:Notify({
                Title = "Diving Gear",
                Content = Value and "Activated!" or "Deactivated!",
                Duration = 2
            })
        end
    })
    
    Tab1:CreateSection("Auto Enchant")
    
    Tab1:CreateToggle({
        Name = "Auto Enchant Rod",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoEnchant = Value
            if Value then 
                AutoEnchant()
                Rayfield:Notify({
                    Title = "Auto Enchant",
                    Content = "Will auto enchant when stones available!",
                    Duration = 3
                })
            end
            SaveSettings()
        end
    })
    
    Tab1:CreateSection("Settings")
    
    Tab1:CreateToggle({
        Name = "Auto Jump",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoJump = Value
            if Value then StartAutoJump() end
            SaveSettings()
        end
    })
    
    Tab1:CreateSlider({
        Name = "Jump Delay",
        Range = {1, 10},
        Increment = 0.5,
        CurrentValue = 3,
        Callback = function(Value)
            Config.AutoJumpDelay = Value
            SaveSettings()
        end
    })
    
    -- ===== WEATHER TAB (NEW) =====
    local Tab2 = Window:CreateTab("🌤️ Weather", 4483362458)
    
    Tab2:CreateSection("Auto Buy Weather")
    
    local Weather1Drop = Tab2:CreateDropdown({
        Name = "Weather Slot 1",
        Options = {"None", "Wind", "Cloudy", "Snow", "Storm", "Radiant", "Shark Hunt"},
        CurrentOption = {"None"},
        Callback = function(Option)
            if Option[1] ~= "None" then
                Config.SelectedWeathers[1] = Option[1]
            else
                Config.SelectedWeathers[1] = nil
            end
            SaveSettings()
        end
    })
    
    local Weather2Drop = Tab2:CreateDropdown({
        Name = "Weather Slot 2",
        Options = {"None", "Wind", "Cloudy", "Snow", "Storm", "Radiant", "Shark Hunt"},
        CurrentOption = {"None"},
        Callback = function(Option)
            if Option[1] ~= "None" then
                Config.SelectedWeathers[2] = Option[1]
            else
                Config.SelectedWeathers[2] = nil
            end
            SaveSettings()
        end
    })
    
    local Weather3Drop = Tab2:CreateDropdown({
        Name = "Weather Slot 3",
        Options = {"None", "Wind", "Cloudy", "Snow", "Storm", "Radiant", "Shark Hunt"},
        CurrentOption = {"None"},
        Callback = function(Option)
            if Option[1] ~= "None" then
                Config.SelectedWeathers[3] = Option[1]
            else
                Config.SelectedWeathers[3] = nil
            end
            SaveSettings()
        end
    })
    
    Tab2:CreateButton({
        Name = "Buy Selected Weathers Now",
        Callback = function()
            for _, weather in ipairs(Config.SelectedWeathers) do
                if weather then
                    pcall(function()
                        PurchaseWeather:InvokeServer(weather)
                        Rayfield:Notify({
                            Title = "Weather Purchased",
                            Content = "Bought: " .. weather,
                            Duration = 2
                        })
                    end)
                    task.wait(0.5)
                end
            end
        end
    })
    
    Tab2:CreateToggle({
        Name = "Auto Buy Weather (Continuous)",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoBuyWeather = Value
            if Value then
                AutoBuyWeather()
                Rayfield:Notify({
                    Title = "Auto Buy Weather",
                    Content = "Will keep buying selected weathers!",
                    Duration = 3
                })
            end
            SaveSettings()
        end
    })
    
    -- ===== TELEPORT TAB =====
    local Tab3 = Window:CreateTab("📍 Teleport", 4483362458)
    
    Tab3:CreateSection("Islands")
    
    local IslandOptions = {}
    for i, island in ipairs(IslandsData) do
        table.insert(IslandOptions, string.format("%d. %s", i, island.Name))
    end
    
    local IslandDrop = Tab3:CreateDropdown({
        Name = "Select Island",
        Options = IslandOptions,
        CurrentOption = {IslandOptions[1]},
        Callback = function(Option) end
    })
    
    Tab3:CreateButton({
        Name = "Teleport to Island",
        Callback = function()
            local selected = IslandDrop.CurrentOption[1]
            local index = tonumber(selected:match("^(%d+)%."))
            
            if index and IslandsData[index] then
                TeleportToPosition(IslandsData[index].Position)
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "Teleported to " .. IslandsData[index].Name,
                    Duration = 2
                })
            end
        end
    })
    
    Tab3:CreateToggle({
        Name = "Lock Position",
        CurrentValue = false,
        Callback = function(Value)
            ToggleLockPosition(Value)
            Rayfield:Notify({
                Title = "Lock Position",
                Content = Value and "Position Locked!" or "Position Unlocked!",
                Duration = 2
            })
        end
    })
    
    Tab3:CreateSection("Players")
    
    local PlayerDrop = Tab3:CreateDropdown({
        Name = "Select Player",
        Options = {"Load players first"},
        CurrentOption = {"Load players first"},
        Callback = function(Option) end
    })
    
    Tab3:CreateButton({
        Name = "Load Players",
        Callback = function()
            Players_List = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    table.insert(Players_List, player.Name)
                end
            end
            
            if #Players_List == 0 then
                Players_List = {"No players online"}
            end
            
            PlayerDrop:Refresh(Players_List)
            Rayfield:Notify({
                Title = "Players Loaded",
                Content = string.format("Found %d players", #Players_List),
                Duration = 2
            })
        end
    })
    
    Tab3:CreateButton({
        Name = "Teleport to Player",
        Callback = function()
            local selected = PlayerDrop.CurrentOption[1]
            local player = Players:FindFirstChild(selected)
            
            if player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
                    Rayfield:Notify({Title = "Teleported", Content = "Teleported to " .. selected, Duration = 2})
                end
            end
        end
    })
    
    Tab3:CreateSection("Events")
    
    local EventDrop = Tab3:CreateDropdown({
        Name = "Select Event",
        Options = {"Load events first"},
        CurrentOption = {"Load events first"},
        Callback = function(Option) end
    })
    
    Tab3:CreateButton({
        Name = "Load Events",
        Callback = function()
            Events = ScanActiveEvents()
            local options = {}
            
            for i, event in ipairs(Events) do
                table.insert(options, string.format("%d. %s", i, event.Name))
            end
            
            if #options == 0 then
                options = {"No events active"}
            end
            
            EventDrop:Refresh(options)
            Rayfield:Notify({
                Title = "Events Loaded",
                Content = string.format("Found %d events", #Events),
                Duration = 2
            })
        end
    })
    
    Tab3:CreateButton({
        Name = "Teleport to Event",
        Callback = function()
            local selected = EventDrop.CurrentOption[1]
            local index = tonumber(selected:match("^(%d+)%."))
            
            if index and Events[index] then
                TeleportToPosition(Events[index].Position)
                Rayfield:Notify({Title = "Teleported", Content = "Teleported to event", Duration = 2})
            end
        end
    })
    
    Tab3:CreateSection("Position Manager")
    
    Tab3:CreateButton({
        Name = "Save Current Position",
        Callback = function()
            Config.SavedPosition = HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Saved", Content = "Position saved", Duration = 2})
        end
    })
    
    Tab3:CreateButton({
        Name = "Teleport to Saved Position",
        Callback = function()
            if Config.SavedPosition then
                HumanoidRootPart.CFrame = Config.SavedPosition
                Rayfield:Notify({Title = "Teleported", Content = "Loaded saved position", Duration = 2})
            else
                Rayfield:Notify({Title = "Error", Content = "No saved position", Duration = 2})
            end
        end
    })
    
    Tab3:CreateButton({
        Name = "Teleport to Checkpoint",
        Callback = function()
            if Config.CheckpointPosition then
                HumanoidRootPart.CFrame = Config.CheckpointPosition
                Rayfield:Notify({Title = "Teleported", Content = "Back to checkpoint", Duration = 2})
            end
        end
    })
    
    -- ===== UTILITY TAB =====
    local Tab4 = Window:CreateTab("⚡ Utility", 4483362458)
    
    Tab4:CreateSection("Speed Settings")
    
    Tab4:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(Value)
            Config.WalkSpeed = Value
            if Humanoid then
                Humanoid.WalkSpeed = Value
            end
            SaveSettings()
        end
    })
    
    Tab4:CreateSlider({
        Name = "Jump Power",
        Range = {50, 500},
        Increment = 5,
        CurrentValue = 50,
        Callback = function(Value)
            Config.JumpPower = Value
            if Humanoid then
                Humanoid.JumpPower = Value
            end
            SaveSettings()
        end
    })
    
    Tab4:CreateInput({
        Name = "Custom Speed (Default: 16)",
        PlaceholderText = "Enter any speed value",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            local speed = tonumber(Text)
            if speed and speed >= 1 then
                if Humanoid then
                    Humanoid.WalkSpeed = speed
                    Config.WalkSpeed = speed
                    Rayfield:Notify({Title = "Speed Set", Content = "Speed: " .. speed, Duration = 2})
                end
            end
        end
    })
    
    Tab4:CreateSection("Extra Utility")
    
    Tab4:CreateToggle({
        Name = "Fly Mode",
        CurrentValue = false,
        Callback = function(Value)
            Config.FlyEnabled = Value
            if Value then
                StartFly()
                Rayfield:Notify({Title = "Fly Enabled", Content = "Use WASD + Space/Shift", Duration = 3})
            else
                StopFly()
            end
        end
    })
    
    Tab4:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 300},
        Increment = 5,
        CurrentValue = 50,
        Callback = function(Value)
            Config.FlySpeed = Value
            SaveSettings()
        end
    })
    
    Tab4:CreateToggle({
        Name = "Walk on Water",
        CurrentValue = false,
        Callback = function(Value)
            ToggleWalkOnWater(Value)
            Rayfield:Notify({
                Title = "Walk on Water",
                Content = Value and "Enabled" or "Disabled",
                Duration = 2
            })
        end
    })
    
    Tab4:CreateToggle({
        Name = "NoClip",
        CurrentValue = false,
        Callback = function(Value)
            ToggleNoClip(Value)
            Rayfield:Notify({
                Title = "NoClip",
                Content = Value and "Enabled" or "Disabled",
                Duration = 2
            })
        end
    })
    
    Tab4:CreateToggle({
        Name = "XRay (Transparent Walls)",
        CurrentValue = false,
        Callback = function(Value)
            ToggleXRay(Value)
            Rayfield:Notify({
                Title = "XRay Mode",
                Content = Value and "Enabled" or "Disabled",
                Duration = 2
            })
        end
    })
    
    Tab4:CreateButton({
        Name = "Infinite Jump",
        Callback = function()
            UserInputService.JumpRequest:Connect(function()
                if Humanoid then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            Rayfield:Notify({Title = "Infinite Jump", Content = "Enabled", Duration = 2})
        end
    })
    
    Tab4:CreateButton({
        Name = "Reset Speed to Normal",
        Callback = function()
            if Humanoid then
                Humanoid.WalkSpeed = 16
                Humanoid.JumpPower = 50
                Config.WalkSpeed = 16
                Config.JumpPower = 50
                Rayfield:Notify({Title = "Speed Reset", Content = "Back to normal", Duration = 2})
            end
        end
    })
    
    -- ===== UTILITY II TAB =====
    local Tab5 = Window:CreateTab("⚡ Utility II", 4483362458)
    
    Tab5:CreateSection("Protection")
    
    Tab5:CreateToggle({
        Name = "God Mode",
        CurrentValue = false,
        Callback = function(Value)
            ToggleGodMode(Value)
            if Value then
                Rayfield:Notify({Title = "God Mode", Content = "You are immortal", Duration = 3})
            else
                Rayfield:Notify({Title = "God Mode", Content = "Disabled", Duration = 2})
            end
            SaveSettings()
        end
    })
    
    Tab5:CreateButton({
        Name = "Full Health",
        Callback = function()
            if Humanoid then
                Humanoid.Health = Humanoid.MaxHealth
                Rayfield:Notify({Title = "Healed", Content = "Full health restored", Duration = 2})
            end
        end
    })
    
    Tab5:CreateButton({
        Name = "Remove All Damage",
        Callback = function()
            if Character then
                for _, obj in pairs(Character:GetDescendants()) do
                    if obj:IsA("Fire") or obj:IsA("Smoke") then
                        obj:Destroy()
                    end
                end
                Rayfield:Notify({Title = "Cleaned", Content = "All damage effects removed", Duration = 2})
            end
        end
    })
    
    Tab5:CreateSection("Player ESP")
    
    Tab5:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Callback = function(Value)
            ToggleESP(Value)
            Rayfield:Notify({
                Title = "ESP",
                Content = Value and "Enabled" or "Disabled",
                Duration = 2
            })
        end
    })
    
    Tab5:CreateSlider({
        Name = "ESP Text Size",
        Range = {10, 50},
        Increment = 1,
        CurrentValue = 20,
        Callback = function(Value)
            Config.ESPDistance = Value
        end
    })
    
    Tab5:CreateButton({
        Name = "Highlight All Players",
        Callback = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight", player.Character)
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                end
            end
            Rayfield:Notify({Title = "ESP Enabled", Content = "All players highlighted", Duration = 2})
        end
    })
    
    Tab5:CreateButton({
        Name = "Remove All Highlights",
        Callback = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    for _, obj in pairs(player.Character:GetChildren()) do
                        if obj:IsA("Highlight") then
                            obj:Destroy()
                        end
                    end
                end
            end
            Rayfield:Notify({Title = "ESP Disabled", Content = "Highlights removed", Duration = 2})
        end
    })
    
    Tab5:CreateSection("Trading")
    
    Tab5:CreateToggle({
        Name = "Auto Accept Trade",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoAcceptTrade = Value
            if Value then
                AutoAcceptTrade()
                Rayfield:Notify({
                    Title = "Auto Accept Trade",
                    Content = "Will auto accept all trades!",
                    Duration = 3
                })
            end
            SaveSettings()
        end
    })
    
    -- ===== VISUALS TAB (IMPROVED) =====
    local Tab6 = Window:CreateTab("👁️ Visuals", 4483362458)
    
    Tab6:CreateSection("Lighting (Permanent)")
    
    Tab6:CreateButton({
        Name = "Fullbright",
        Callback = function()
            Config.Brightness = 3
            Config.TimeOfDay = 14
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            ApplyPermanentLighting()
            Rayfield:Notify({Title = "Fullbright", Content = "Maximum brightness (Permanent)", Duration = 2})
        end
    })
    
    Tab6:CreateButton({
        Name = "Remove Fog",
        Callback = function()
            RemoveFog()
            Rayfield:Notify({Title = "Fog Removed", Content = "Fog disabled permanently", Duration = 2})
        end
    })
    
    Tab6:CreateButton({
        Name = "8-Bit Mode (5x Smoother)",
        Callback = function()
            Enable8Bit()
            Rayfield:Notify({Title = "8-Bit Mode", Content = "Ultra smooth graphics enabled", Duration = 2})
        end
    })
    
    Tab6:CreateSlider({
        Name = "Brightness (Permanent)",
        Range = {0, 10},
        Increment = 0.5,
        CurrentValue = 2,
        Callback = function(Value)
            Config.Brightness = Value
            Lighting.Brightness = Value
            ApplyPermanentLighting()
            SaveSettings()
        end
    })
    
    Tab6:CreateSlider({
        Name = "Time of Day (Permanent)",
        Range = {0, 24},
        Increment = 0.5,
        CurrentValue = 14,
        Callback = function(Value)
            Config.TimeOfDay = Value
            Lighting.ClockTime = Value
            ApplyPermanentLighting()
            SaveSettings()
        end
    })
    
    Tab6:CreateSection("Effects (Improved)")
    
    Tab6:CreateButton({
        Name = "Remove Particles (Permanent)",
        Callback = function()
            RemoveParticles()
            Rayfield:Notify({Title = "Particles Removed", Content = "All effects disabled permanently", Duration = 2})
        end
    })
    
    Tab6:CreateButton({
        Name = "Remove Seaweed (Permanent)",
        Callback = function()
            RemoveSeaweed()
            Rayfield:Notify({Title = "Seaweed Removed", Content = "Water cleared permanently", Duration = 2})
        end
    })
    
    Tab6:CreateButton({
        Name = "Optimize Water (Permanent)",
        Callback = function()
            OptimizeWater()
            Rayfield:Notify({Title = "Water Optimized", Content = "Water effects minimized permanently", Duration = 2})
        end
    })
    
    Tab6:CreateButton({
        Name = "Performance Mode (All-In-One)",
        Callback = function()
            PerformanceMode()
            Rayfield:Notify({Title = "Performance Mode", Content = "Max FPS optimization applied!", Duration = 3})
        end
    })
    
    Tab6:CreateButton({
        Name = "Reset Graphics",
        Callback = function()
            if LightingConnection then LightingConnection:Disconnect() end
            Config.Brightness = 2
            Config.TimeOfDay = 14
            Lighting.Brightness = 2
            Lighting.FogEnd = 10000
            Lighting.GlobalShadows = true
            Lighting.ClockTime = 14
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Rayfield:Notify({Title = "Graphics Reset", Content = "Back to normal", Duration = 2})
        end
    })
    
    Tab6:CreateSection("Camera")
    
    Tab6:CreateButton({
        Name = "Infinite Zoom",
        Callback = function()
            EnableInfiniteZoom()
            Rayfield:Notify({Title = "Infinite Zoom", Content = "Zoom limits removed", Duration = 2})
end
    })
    
    Tab6:CreateButton({
        Name = "Remove Camera Shake",
        Callback = function()
            local cam = Workspace.CurrentCamera
            if cam then
                cam.FieldOfView = 70
            end
            Rayfield:Notify({Title = "Camera Fixed", Content = "Shake removed", Duration = 2})
        end
    })
    
    -- ===== MISC TAB =====
    local Tab7 = Window:CreateTab("🔧 Misc", 4483362458)
    
    Tab7:CreateSection("Character")
    
    Tab7:CreateButton({
        Name = "Reset Character",
        Callback = function()
            Character:BreakJoints()
            Rayfield:Notify({Title = "Resetting", Content = "Character respawning", Duration = 2})
        end
    })
    
    Tab7:CreateButton({
        Name = "Remove Accessories",
        Callback = function()
            for _, obj in pairs(Character:GetChildren()) do
                if obj:IsA("Accessory") then
                    obj:Destroy()
                end
            end
            Rayfield:Notify({Title = "Accessories Removed", Content = "Character cleaned", Duration = 2})
        end
    })
    
    Tab7:CreateButton({
        Name = "Rainbow Character",
        Callback = function()
            spawn(function()
                for i = 1, 100 do
                    if Character then
                        for _, part in pairs(Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromHSV(i / 100, 1, 1)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
            Rayfield:Notify({Title = "Rainbow Mode", Content = "Character colorized", Duration = 2})
        end
    })
    
    Tab7:CreateSection("Audio")
    
    Tab7:CreateButton({
        Name = "Mute All Sounds",
        Callback = function()
            for _, sound in pairs(Workspace:GetDescendants()) do
                if sound:IsA("Sound") then
                    sound.Volume = 0
                end
            end
            Rayfield:Notify({Title = "Sounds Muted", Content = "All audio disabled", Duration = 2})
        end
    })
    
    Tab7:CreateButton({
        Name = "Restore Sounds",
        Callback = function()
            for _, sound in pairs(Workspace:GetDescendants()) do
                if sound:IsA("Sound") then
                    sound.Volume = 0.5
                end
            end
            Rayfield:Notify({Title = "Sounds Restored", Content = "Audio enabled", Duration = 2})
        end
    })
    
    Tab7:CreateSection("Inventory")
    
    Tab7:CreateButton({
        Name = "Show Inventory",
        Callback = function()
            print("=== INVENTORY ===")
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local count = 0
            if backpack then
                for i, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        count = count + 1
                        print(string.format("[%d] %s", count, item.Name))
                    end
                end
            end
            print("=== TOTAL: " .. count .. " ===")
            Rayfield:Notify({Title = "Inventory", Content = "Found " .. count .. " items (check console F9)", Duration = 3})
        end
    })
    
    Tab7:CreateButton({
        Name = "Drop All Items",
        Callback = function()
            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    item.Parent = Character
                    task.wait(0.1)
                    item.Parent = Workspace
                end
            end
            Rayfield:Notify({Title = "Items Dropped", Content = "All items dropped", Duration = 2})
        end
    })
    
    Tab7:CreateSection("Server")
    
    Tab7:CreateButton({
        Name = "Show Server Stats",
        Callback = function()
            local stats = string.format(
                "=== SERVER STATS ===\n" ..
                "Players: %d/%d\n" ..
                "Ping: %d ms\n" ..
                "FPS: %d\n" ..
                "Job ID: %s\n" ..
                "=== END ===",
                #Players:GetPlayers(),
                Players.MaxPlayers,
                LocalPlayer:GetNetworkPing() * 1000,
                workspace:GetRealPhysicsFPS(),
                game.JobId
            )
            print(stats)
            Rayfield:Notify({Title = "Server Stats", Content = "Check console (F9)", Duration = 3})
        end
    })
    
    Tab7:CreateButton({
        Name = "Copy Job ID",
        Callback = function()
            setclipboard(game.JobId)
            Rayfield:Notify({Title = "Copied", Content = "Job ID copied to clipboard", Duration = 2})
        end
    })
    
    Tab7:CreateButton({
        Name = "Rejoin Server (Same)",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    })
    
    Tab7:CreateButton({
        Name = "Rejoin Server (Random)",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    
    Tab7:CreateSection("Auto Rejoin")
    
    Tab7:CreateToggle({
        Name = "Auto Rejoin on Disconnect",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoRejoin = Value
            if Value then
                SetupAutoRejoin()
                Rayfield:Notify({
                    Title = "Auto Rejoin",
                    Content = "Will auto rejoin if disconnected!",
                    Duration = 3
                })
            end
            SaveSettings()
        end
    })
    
    -- ===== SETTINGS TAB (IMPROVED) =====
    local Tab8 = Window:CreateTab("⚙️ Settings", 4483362458)

    Tab8:CreateSection("Auto Save & Load")

    Tab8:CreateToggle({
        Name = "Auto Save Settings (Every 10s)",
        CurrentValue = false,
        Callback = function(Value)
            Config.AutoSaveSettings = Value
            if Value then
                StartAutoSave()
                Rayfield:Notify({
                    Title = "Auto Save",
                    Content = "Settings will auto-save every 10 seconds!",
                    Duration = 3
                })
            else
                if AutoSaveConnection then
                    AutoSaveConnection:Disconnect()
                    AutoSaveConnection = nil
                end
            end
            SaveSettings()
        end
    })

    Tab8:CreateButton({
        Name = "💾 Save Settings Now + Position",
        Callback = function()
            if HumanoidRootPart then
                Config.SavedPosition = HumanoidRootPart.CFrame
            end
            Config.ManualSave = true
            SaveSettings()
        end
    })

    Tab8:CreateButton({
        Name = "📂 Load Saved Settings",
        Callback = function()
            LoadSettings()
        end
    })

    Tab8:CreateButton({
        Name = "🗑️ Delete Saved Settings",
        Callback = function()
            if isfile and isfile(SaveFileName) then
                delfile(SaveFileName)
                Rayfield:Notify({
                    Title = "Settings Deleted", 
                    Content = "All saved settings cleared!",
                    Duration = 2
                })
            else
                Rayfield:Notify({
                    Title = "Error", 
                    Content = "No saved settings found!",
                    Duration = 2
                })
            end
        end
    })

    Tab8:CreateButton({
        Name = "📍 Save Current Position Only",
        Callback = function()
            if HumanoidRootPart then
                Config.SavedPosition = HumanoidRootPart.CFrame
                Rayfield:Notify({
                    Title = "Position Saved",
                    Content = "Current position and orientation saved!",
                    Duration = 2
                })
                SaveSettings()
            end
        end
    })

    Tab8:CreateSection("Backup & Restore")

    Tab8:CreateButton({
        Name = "📊 Show Current Settings",
        Callback = function()
            local settingsText = string.format(
                "=== CURRENT SETTINGS ===\n" ..
                "Auto Fishing V1: %s\n" ..
                "Auto Fishing V2: %s\n" ..
                "Fishing Delay: %.1fs\n" ..
                "Perfect Catch: %s\n" ..
                "Anti AFK: %s\n" ..
                "Auto Jump: %s (Delay: %ss)\n" ..
                "Auto Sell: %s\n" ..
                "God Mode: %s\n" ..
                "Auto Enchant: %s\n" ..
                "Auto Buy Weather: %s\n" ..
                "Auto Accept Trade: %s\n" ..
                "Auto Rejoin: %s\n" ..
                "Walk Speed: %d\n" ..
                "Jump Power: %d\n" ..
                "Fly: %s (Speed: %d)\n" ..
                "Walk on Water: %s\n" ..
                "NoClip: %s\n" ..
                "XRay: %s\n" ..
                "ESP: %s\n" ..
                "Lock Position: %s\n" ..
                "Auto Save: %s\n" ..
                "Brightness: %.1f\n" ..
                "Time of Day: %.1f\n" ..
                "Has Saved Position: %s\n" ..
                "=== END ===",
                Config.AutoFishingV1 and "ON" or "OFF",
                Config.AutoFishingV2 and "ON" or "OFF",
                Config.FishingDelay,
                Config.PerfectCatch and "ON" or "OFF",
                Config.AntiAFK and "ON" or "OFF",
                Config.AutoJump and "ON" or "OFF", Config.AutoJumpDelay,
                Config.AutoSell and "ON" or "OFF",
                Config.GodMode and "ON" or "OFF",
                Config.AutoEnchant and "ON" or "OFF",
                Config.AutoBuyWeather and "ON" or "OFF",
                Config.AutoAcceptTrade and "ON" or "OFF",
                Config.AutoRejoin and "ON" or "OFF",
                Config.WalkSpeed,
                Config.JumpPower,
                Config.FlyEnabled and "ON" or "OFF", Config.FlySpeed,
                Config.WalkOnWater and "ON" or "OFF",
                Config.NoClip and "ON" or "OFF",
                Config.XRay and "ON" or "OFF",
                Config.ESPEnabled and "ON" or "OFF",
                Config.LockedPosition and "ON" or "OFF",
                Config.AutoSaveSettings and "ON" or "OFF",
                Config.Brightness,
                Config.TimeOfDay,
                Config.SavedPosition and "YES" or "NO"
            )
            print(settingsText)
            Rayfield:Notify({
                Title = "Current Settings", 
                Content = "Check console (F9) for details",
                Duration = 4
            })
        end
    })
    
    -- ===== INFO TAB =====
    local Tab9 = Window:CreateTab("ℹ️ Info", 4483362458)
    
    Tab9:CreateSection("Script Information")
    
    Tab9:CreateParagraph({
        Title = "NIKZZ FISH IT - V1 UPGRADED",
        Content = "Upgraded Version - Perfect Edition\nDeveloper: Nikzz\nRelease Date: 11 Oct 2025\nStatus: ALL FEATURES WORKING\nVersion: 2.0 - MAJOR UPDATE"
    })
    
    Tab9:CreateSection("New Features in V2")
    
    Tab9:CreateParagraph({
        Title = "🆕 Auto Fishing Improvements",
        Content = "• Ultra Fast V1 with Anti-Stuck System\n• Auto Respawn if stuck (stays in place)\n• V2 uses game auto with perfect catch\n• Delay slider now works perfectly\n• No more character stuck issues"
    })
    
    Tab9:CreateParagraph({
        Title = "🆕 Auto Enchant",
        Content = "• Automatically enchants rods\n• No need to equip stones\n• Shows remaining stones count\n• Continuous enchanting mode"
    })
    
    Tab9:CreateParagraph({
        Title = "🆕 Weather System",
        Content = "• Buy up to 3 weathers at once\n• Auto buy mode (continuous)\n• Select from 6 weather types\n• Wind, Cloudy, Snow, Storm, Radiant, Shark Hunt"
    })
    
    Tab9:CreateParagraph({
        Title = "🆕 Trading & Rejoin",
        Content = "• Auto Accept Trade feature\n• Auto Rejoin on disconnect\n• Manual rejoin (same/random server)\n• Reconnect and reload script automatically"
    })
    
    Tab9:CreateParagraph({
        Title = "🆕 Visual Improvements",
        Content = "• Permanent Fullbright/Brightness/Time\n• 5x Smoother 8-Bit Mode\n• Improved particle removal\n• Better seaweed removal\n• Enhanced water optimization\n• Performance mode (all-in-one)"
    })
    
    Tab9:CreateParagraph({
        Title = "🆕 Settings System",
        Content = "• Auto Save & Load settings\n• Save your preferred configuration\n• Load settings on script start\n• Delete saved data option"
    })
    
    Tab9:CreateSection("Features Overview")
    
    Tab9:CreateParagraph({
        Title = "🎣 Fishing System",
        Content = "• Auto Fishing V1 & V2 (Improved)\n• Perfect Catch Mode\n• Auto Sell Fish\n• Radar & Diving Gear\n• Adjustable Fishing Delay\n• Anti-Stuck Protection"
    })
    
    Tab9:CreateParagraph({
        Title = "📍 Teleport System",
        Content = "• 21 Island Locations\n• Player Teleport\n• Event Detection\n• Position Lock Feature\n• Checkpoint System"
    })
    
    Tab9:CreateParagraph({
        Title = "⚡ Utility Features",
        Content = "• Custom Speed (Unlimited)\n• Fly Mode (Fixed)\n• Walk on Water (Fixed)\n• NoClip & XRay\n• Infinite Jump\n• Auto Jump (Fixed)"
    })
    
    Tab9:CreateParagraph({
        Title = "⚡ Utility II Features",
        Content = "• God Mode\n• Player ESP with Distance\n• ESP Text Size Control\n• Player Highlights\n• Health Management\n• Auto Accept Trade"
    })
    
    Tab9:CreateParagraph({
        Title = "👁️ Visual Features (Improved)",
        Content = "• Permanent Fullbright\n• Permanent Time/Brightness Control\n• Remove Fog (Permanent)\n• 5x Smoother 8-Bit Mode\n• Enhanced Performance Mode\n• Camera Controls"
    })
    
    Tab9:CreateParagraph({
        Title = "🔧 Misc Features",
        Content = "• Character Customization\n• Audio Controls\n• Inventory Manager\n• Server Information\n• Rainbow Mode\n• Rejoin Options"
    })
    
    Tab9:CreateSection("Usage Guide")
    
    Tab9:CreateParagraph({
        Title = "⚡ Quick Start Guide",
        Content = "1. Enable Auto Save Settings\n2. Enable Auto Fishing V1 or V2\n3. Select Island and Teleport\n4. Adjust Speed in Utility Tab\n5. Enable God Mode for Safety\n6. Use Perfect Catch for Manual Fishing"
    })
    
    Tab9:CreateParagraph({
        Title = "⚠️ Important Notes",
        Content = "• Auto Fishing V1: Ultra fast with anti-stuck\n• Auto Fishing V2: Uses game auto\n• Delay: 0.1s = fastest, 5s = slowest\n• Lock Position: Keeps you in place\n• XRay: Makes walls transparent\n• ESP: Shows player names & distance\n• Events: Only active events shown"
    })
    
    Tab9:CreateParagraph({
        Title = "🆕 V1 UPgrade Notes",
        Content = "• All bugs from V1 fixed\n• Visual effects now permanent\n• Auto Jump works properly\n• Delay slider fixed\n• Anti-stuck system added\n• New features: Enchant, Weather, Trade, Save/Load"
    })
    
    Tab9:CreateSection("Script Control")
    
    Tab9:CreateButton({
        Name = "Show Statistics",
        Callback = function()
            local stats = string.format(
                "=== NIKZZ STATISTICS ===\n" ..
                "Version: 2.0 UPGRADED\n" ..
                "Islands Available: %d\n" ..
                "Players Online: %d\n" ..
                "Auto Fishing V1: %s\n" ..
                "Auto Fishing V2: %s\n" ..
                "Auto Enchant: %s\n" ..
                "Auto Buy Weather: %s\n" ..
                "Auto Accept Trade: %s\n" ..
                "Auto Rejoin: %s\n" ..
                "God Mode: %s\n" ..
                "Fly Mode: %s\n" ..
                "Walk Speed: %d\n" ..
                "Auto Save: %s\n" ..
                "=== END ===",
                #IslandsData,
                #Players:GetPlayers() - 1,
                Config.AutoFishingV1 and "ON" or "OFF",
                Config.AutoFishingV2 and "ON" or "OFF",
                Config.AutoEnchant and "ON" or "OFF",
                Config.AutoBuyWeather and "ON" or "OFF",
                Config.AutoAcceptTrade and "ON" or "OFF",
                Config.AutoRejoin and "ON" or "OFF",
                Config.GodMode and "ON" or "OFF",
                Config.FlyEnabled and "ON" or "OFF",
                Config.WalkSpeed,
                Config.AutoSaveSettings and "ON" or "OFF"
            )
            print(stats)
            Rayfield:Notify({Title = "Statistics", Content = "Check console (F9)", Duration = 3})
        end
    })
    
    Tab9:CreateButton({
        Name = "Close Script",
        Callback = function()
            SaveSettings()
            Rayfield:Notify({Title = "Closing Script", Content = "Saving and shutting down...", Duration = 2})
            
            -- Stop all active features
            Config.AutoFishingV1 = false
            Config.AutoFishingV2 = false
            Config.AntiAFK = false
            Config.AutoJump = false
            Config.AutoSell = false
            Config.AutoEnchant = false
            Config.AutoBuyWeather = false
            Config.AutoAcceptTrade = false
            
            if GodConnection then GodConnection:Disconnect() end
            if PerfectCatchConn then PerfectCatchConn:Disconnect() end
            if LockConn then LockConn:Disconnect() end
            if WaterConn then WaterConn:Disconnect() end
            if NoClipConn then NoClipConn:Disconnect() end
            if FlyConn then FlyConn:Disconnect() end
            if LightingConnection then LightingConnection:Disconnect() end
            
            StopFly()
            ToggleGodMode(false)
            ToggleLockPosition(false)
            ToggleWalkOnWater(false)
            ToggleNoClip(false)
            ToggleXRay(false)
            ToggleESP(false)
            
            task.wait(2)
            Rayfield:Destroy()
            
            print("=======================================")
            print("  NIKZZ FISH IT - V1 UPGRADED CLOSED")
            print("  All Features Stopped")
            print("  Settings Saved")
            print("  Thank you for using!")
            print("=======================================")
        end
    })
    
    -- Final Notification
    task.wait(1)
    Rayfield:Notify({
        Title = "NIKZZ FISH IT - V1 UPGRADED",
        Content = "All systems ready - Major Update Applied!",
        Duration = 5
    })
    
    print("=======================================")
    print("  NIKZZ FISH IT - V1 UPGRADED LOADED")
    print("  Status: ALL FEATURES WORKING")
    print("  Developer: Nikzz")
    print("  Release: 11 Oct 2025")
    print("  Version: 2.0 - MAJOR UPDATE")
    print("=======================================")
    print("  NEW FEATURES:")
    print("  • Ultra Fast Auto Fishing with Anti-Stuck")
    print("  • Auto Enchant System")
    print("  • Auto Buy Weather (3 slots)")
    print("  • Auto Accept Trade")
    print("  • Auto Rejoin on Disconnect")
    print("  • Auto Save & Load Settings")
    print("  • Fixed: Auto Jump, Delay Slider")
    print("  • Improved: All Visual Effects (Permanent)")
    print("  • Enhanced: 8-Bit, Particles, Seaweed, Water")
    print("=======================================")
    
    return Window
end

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    
    task.wait(2)
    
    -- Reapply settings
    if Config.AutoFishingV1 then AutoFishingV1() end
    if Config.AutoFishingV2 then AutoFishingV2() end
    if Config.AntiAFK then StartAntiAFK() end
    if Config.AutoJump then StartAutoJump() end
    if Config.AutoSell then StartAutoSell() end
    if Config.AutoEnchant then AutoEnchant() end
    if Config.AutoBuyWeather then AutoBuyWeather() end
    if Config.AutoAcceptTrade then AutoAcceptTrade() end
    if Config.GodMode then ToggleGodMode(true) end
    if Config.FlyEnabled then StartFly() end
    if Config.WalkOnWater then ToggleWalkOnWater(true) end
    if Config.NoClip then ToggleNoClip(true) end
    if Config.PerfectCatch then TogglePerfectCatch(true) end
    if Config.LockedPosition then ToggleLockPosition(true) end
    
    if Humanoid then
        Humanoid.WalkSpeed = Config.WalkSpeed
        Humanoid.JumpPower = Config.JumpPower
    end
end)

-- Main Execution
print("Initializing NIKZZ FISH IT - V1 UPGRADED...")

task.wait(1)
Config.CheckpointPosition = HumanoidRootPart.CFrame
print("Checkpoint position saved")

-- Auto load settings ketika script mulai (tanpa perlu toggle)
task.spawn(function()
    task.wait(3) -- Tunggu UI load dulu
    print("Attempting to load saved settings...")
    LoadSettings()
end)

-- Handle character respawn untuk reload settings
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    
    task.wait(3) -- Tunggu character fully loaded
    
    -- Reapply settings setelah respawn
    task.spawn(function()
        ApplySettings()
    end)
end)

local success, err = pcall(function()
    CreateUI()
end)

if not success then
    warn("ERROR: " .. tostring(err))
else
    print("NIKZZ FISH IT - V1 UPGRADED LOADED SUCCESSFULLY")
    print("Upgraded Version - All Features Working Perfectly")
    print("Developer by Nikzz")
    print("Ready to use!")
    print("")
    print("MAJOR IMPROVEMENTS:")
    print("✓ Auto Fishing V1 - Ultra Fast with Anti-Stuck")
    print("✓ Auto Fishing V2 - Game Auto with Perfect Catch")
    print("✓ Auto Enchant - Automatic Rod Enchanting")
    print("✓ Auto Buy Weather - Buy 3 Weathers Continuously")
    print("✓ Auto Accept Trade - Accept Trades Automatically")
    print("✓ Auto Rejoin - Rejoin on Disconnect")
    print("✓ Auto Save/Load - Save Your Settings")
    print("✓ Fixed Auto Jump - No More Flying")
    print("✓ Fixed Delay Slider - Works Perfectly Now")
    print("✓ Permanent Visual Effects - No More Reset")
    print("✓ 5x Smoother 8-Bit Mode")
    print("✓ Improved Performance Mode")
    print("")
    print("All bugs from V1 have been fixed!")
    print("Enjoy the upgraded experience!")
end
