print("Connecting...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local DISCORD_INVITE = "https://discord.gg/T5GPuXwash"
local PUBLIC_LIFETIME_KEY = "FREE-KEY-NOVEMBER-2026"

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	return
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")



local PREFIX = "[ExellieX]"
local MAX_LOG = 240
local logBuffer = {}

local function pushLog(kind, message)
	message = tostring(message)
	logBuffer[#logBuffer + 1] = { kind = kind, message = message, clock = os.clock() }
	if #logBuffer > MAX_LOG then
		table.remove(logBuffer, 1)
	end
	if kind == "error" or kind == "warn" then
		warn(PREFIX .. " [" .. string.upper(kind) .. "] " .. message)
	else
		print(PREFIX .. " " .. message)
	end
end

local function describe(value)
	local valueType = typeof(value)
	if valueType == "Instance" then
		return value:GetFullName()
	end
	if valueType == "table" then
		local ok, encoded = pcall(HttpService.JSONEncode, HttpService, value)
		if ok then
			return encoded
		end
	end
	return tostring(value)
end

local function attempt(label, fn)
	local results = table.pack(xpcall(fn, function(err)
		return err, debug.traceback(tostring(err), 2)
	end))
	if not results[1] then
		pushLog("error", label .. ": " .. describe(results[2]))
		if results[3] then
			pushLog("trace", results[3])
		end
		return nil, results[2]
	end
	return table.unpack(results, 2, results.n)
end



local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
local httpGet = game.HttpGet or game.HttpGetAsync

local function fetch(url)
	url = tostring(url)
	if type(httpRequest) == "function" then
		local ok, response = pcall(httpRequest, {
			Url = url,
			Method = "GET",
			Headers = { ["User-Agent"] = "ExellieX/2.0" },
		})
		if ok and type(response) == "table" and type(response.Body) == "string" and response.Body ~= "" then
			return response.Body
		end
	end
	if type(httpGet) == "function" then
		local ok, body = pcall(httpGet, game, url, true)
		if ok and type(body) == "string" and body ~= "" then
			return body
		end
	end
	return nil, "no HTTP provider accepted the request"
end

local RakNet = nil
do
	local environment = nil
	if type(getgenv) == "function" then
		environment = getgenv()
	elseif type(getfenv) == "function" then
		environment = getfenv()
	end
	local candidate = environment and (environment.raknet or environment.RakNet)
	if type(candidate) == "table" then
		RakNet = candidate
	end
end

local function fireRemote(remote, ...)
	if typeof(remote) ~= "Instance" then
		return false, "remote is not an Instance"
	end
	if RakNet then
		for _, method in ipairs({ "Send", "Fire", "SendRemote", "send" }) do
			local handler = RakNet[method]
			if type(handler) == "function" then
				local ok = pcall(handler, RakNet, remote, ...)
				if ok then
					return true
				end
			end
		end
	end
	local method = remote:IsA("RemoteFunction") and "InvokeServer" or "FireServer"
	local ok, err = pcall(remote[method], remote, ...)
	return ok, err
end



local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local THEME_DEFS = {
	{ id = "Classic",   bg = Color3.fromRGB(8, 9, 13),      text = Color3.fromRGB(240, 241, 250), accent = Color3.fromRGB(104, 119, 138), accentAlt = Color3.fromRGB(158, 205, 218) },
	{ id = "Midnight",  bg = Color3.fromRGB(6, 8, 14),      text = Color3.fromRGB(233, 238, 250), accent = Color3.fromRGB(84, 122, 246),  accentAlt = Color3.fromRGB(122, 218, 255) },
	{ id = "Ocean",     bg = Color3.fromRGB(5, 13, 21),     text = Color3.fromRGB(231, 247, 255), accent = Color3.fromRGB(30, 119, 164),  accentAlt = Color3.fromRGB(86, 220, 232) },
	{ id = "Cyber",     bg = Color3.fromRGB(10, 6, 18),     text = Color3.fromRGB(248, 233, 255), accent = Color3.fromRGB(255, 60, 172),  accentAlt = Color3.fromRGB(40, 235, 235) },
	{ id = "Rose",      bg = Color3.fromRGB(18, 9, 15),     text = Color3.fromRGB(255, 239, 246), accent = Color3.fromRGB(155, 64, 103),  accentAlt = Color3.fromRGB(255, 143, 183) },
	{ id = "Amethyst",  bg = Color3.fromRGB(14, 8, 20),     text = Color3.fromRGB(243, 236, 255), accent = Color3.fromRGB(168, 85, 247),  accentAlt = Color3.fromRGB(240, 171, 252) },
	{ id = "Forest",    bg = Color3.fromRGB(8, 14, 10),     text = Color3.fromRGB(238, 250, 241), accent = Color3.fromRGB(74, 180, 110),  accentAlt = Color3.fromRGB(183, 228, 127) },
	{ id = "Spring",    bg = Color3.fromRGB(9, 16, 14),     text = Color3.fromRGB(242, 250, 239), accent = Color3.fromRGB(78, 139, 104),  accentAlt = Color3.fromRGB(187, 224, 130) },
	{ id = "Christmas", bg = Color3.fromRGB(8, 16, 14),     text = Color3.fromRGB(244, 249, 239), accent = Color3.fromRGB(150, 42, 49),   accentAlt = Color3.fromRGB(112, 203, 139) },
	{ id = "Halloween", bg = Color3.fromRGB(13, 9, 17),     text = Color3.fromRGB(250, 240, 230), accent = Color3.fromRGB(118, 61, 157),  accentAlt = Color3.fromRGB(255, 155, 64) },
	{ id = "Autumn",    bg = Color3.fromRGB(18, 12, 8),     text = Color3.fromRGB(252, 243, 231), accent = Color3.fromRGB(226, 112, 44),  accentAlt = Color3.fromRGB(245, 200, 90) },
	{ id = "Crimson",   bg = Color3.fromRGB(14, 7, 9),      text = Color3.fromRGB(255, 238, 238), accent = Color3.fromRGB(220, 60, 60),   accentAlt = Color3.fromRGB(255, 150, 120) },
	{ id = "Arctic",    bg = Color3.fromRGB(10, 14, 18),    text = Color3.fromRGB(235, 246, 252), accent = Color3.fromRGB(130, 200, 230), accentAlt = Color3.fromRGB(230, 245, 255) },
	{ id = "Sand",      bg = Color3.fromRGB(22, 19, 14),    text = Color3.fromRGB(248, 242, 230), accent = Color3.fromRGB(200, 166, 110), accentAlt = Color3.fromRGB(240, 220, 180) },
	{ id = "Mono",      bg = Color3.fromRGB(12, 12, 13),    text = Color3.fromRGB(245, 245, 247), accent = Color3.fromRGB(176, 176, 184), accentAlt = Color3.fromRGB(255, 255, 255) },
	{ id = "Paper",     bg = Color3.fromRGB(233, 235, 240), text = Color3.fromRGB(28, 31, 38),   accent = Color3.fromRGB(64, 84, 168),  accentAlt = Color3.fromRGB(200, 64, 96),
		panel = Color3.fromRGB(245, 246, 250), raised = Color3.fromRGB(255, 255, 255), sunken = Color3.fromRGB(223, 226, 234),
		bgTop = Color3.fromRGB(240, 242, 248), bgBottom = Color3.fromRGB(222, 225, 234), border = Color3.fromRGB(196, 201, 214) },
}

local function derive(definition)
	local palette = {
		bg = definition.bg,
		bgTop = definition.bg:Lerp(definition.accent, 0.07),
		bgBottom = definition.bg:Lerp(BLACK, 0.5),
		panel = definition.bg:Lerp(WHITE, 0.04),
		raised = definition.bg:Lerp(WHITE, 0.085),
		sunken = definition.bg:Lerp(BLACK, 0.35),
		text = definition.text,
		muted = definition.text:Lerp(definition.bg, 0.5),
		accent = definition.accent,
		accentAlt = definition.accentAlt,
		danger = Color3.fromRGB(255, 92, 122),
		success = Color3.fromRGB(94, 226, 160),
		border = definition.bg:Lerp(definition.accent, 0.28),
	}
	for key, value in pairs(definition) do
		palette[key] = value
	end
	return palette
end

local ThemeOrder = {}
local ThemeById = {}
for _, definition in ipairs(THEME_DEFS) do
	ThemeById[definition.id] = derive(definition)
	ThemeOrder[#ThemeOrder + 1] = definition.id
end

local Theme = ThemeById[ThemeOrder[1]]
local activeThemeId = ThemeOrder[1]


local function create(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function round(object, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, object)
end

local function outline(object, color, transparency, thickness)
	return create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	}, object)
end

local themeHooks = {}

local function onTheme(fn)
	themeHooks[#themeHooks + 1] = fn
end

local connections = {}

local function track(connection)
	connections[#connections + 1] = connection
	return connection
end



for _, object in pairs({
	PlayerGui:FindFirstChild("ExellieX_Hub"),
	PlayerGui:FindFirstChild("ExellieX_Loader"),
	Lighting:FindFirstChild("ExellieXBlur"),
}) do
	if object then
		object:Destroy()
	end
end

-- Access control -------------------------------------------------------------
--
-- Two tiers:
--   owner  the master key. Gets the console tab: rotate the master key, mint
--          free keys, sign out.
--   key    a minted key with its expiry baked into the string, so it validates
--          on any client with no server round trip.
--
-- The gate runs before the loader, so nothing is built until a key is accepted.
-- This is a client-side check: whoever unpacks this file can read the signing
-- secret and mint their own keys. It keeps casual sharing out, nothing more.

local KeySys = {}
KeySys.tier = nil
KeySys.session = nil

-- Key server ---------------------------------------------------------------
-- Deploy lootlabs-key-worker.js to Cloudflare, then paste its URL below (no
-- trailing slash, no path). Empty disables the LootLabs button: the gate stays
-- key-only and nothing ever calls out.
local KEY_SERVER = ""
local KEY_TAG = "exelliex.hub.v2"
local KEY_HOURS = 24

local KEY_SECRET = "x9Q~2u!Lm#7Rz$4pW&8k^"
local KEY_PREFIX = "EX"
local OWNER_SALT = "exelliex.owner."
local OWNER_DEFAULT = "7ccf9a8c"
local STORE_FOLDER = "ExellieX"
local SESSION_FILE = "session.key"
local OWNER_FILE = "owner.hash"

local HEX = "0123456789abcdef"
local BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function hexOf(number)
	local out = {}
	for shift = 28, 0, -4 do
		local digit = math.floor(number / 2 ^ shift) % 16
		out[#out + 1] = HEX:sub(digit + 1, digit + 1)
	end
	return table.concat(out)
end

-- Two small rolling hashes; both stay far below 2^53 so the result is exact
-- on doubles. No bit32, no integer overflow surprises.
local function hash(text)
	local a, b = 5381, 52711
	for index = 1, #text do
		local byte = text:byte(index)
		a = (a * 33 + byte) % 2147483647
		b = (b * 31 + byte * index) % 2147483647
	end
	return hexOf((a * 65599 + b) % 4294967296)
end

local function compact(text)
	return (string.lower(tostring(text or "")):gsub("%s+", ""))
end

local function toBase36(number)
	number = math.floor(number)
	if number < 1 then
		return "0"
	end
	local out = ""
	while number > 0 do
		local digit = math.floor(number % 36) + 1
		out = BASE36:sub(digit, digit) .. out
		number = math.floor(number / 36)
	end
	return out
end

local function fromBase36(text)
	local value = 0
	for index = 1, #text do
		local digit = BASE36:find(text:sub(index, index), 1, true)
		if not digit then
			return nil
		end
		value = value * 36 + (digit - 1)
	end
	return value
end

local function canStore()
	return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
end

local function readStore(name)
	if not canStore() then
		return nil
	end
	local path = STORE_FOLDER .. "/" .. name
	if not isfile(path) then
		return nil
	end
	local ok, data = pcall(readfile, path)
	if ok and type(data) == "string" and data ~= "" then
		return data
	end
	return nil
end

local function writeStore(name, data)
	if not canStore() then
		return false
	end
	if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(STORE_FOLDER) then
		pcall(makefolder, STORE_FOLDER)
	end
	return (pcall(writefile, STORE_FOLDER .. "/" .. name, data))
end

local function clearStore(name)
	if not canStore() then
		return
	end
	local path = STORE_FOLDER .. "/" .. name
	if not isfile(path) then
		return
	end
	if type(delfile) == "function" then
		pcall(delfile, path)
	else
		pcall(writefile, path, "")
	end
end

local function ownerHash()
	local stored = readStore(OWNER_FILE)
	if stored and #stored == 8 and string.match(stored, "^%x+$") then
		return stored
	end
	return OWNER_DEFAULT
end

local function sign(expiry, nonce)
	return string.upper(string.sub(hash(KEY_SECRET .. "|" .. KEY_TAG .. "|" .. expiry .. "|" .. nonce), 1, 6))
end

function KeySys.mint(hours)
	local duration = tonumber(hours) or 24
	duration = math.max(1 / 60, math.min(duration * 3600, 10 * 365 * 86400))
	local expiry = os.time() + math.floor(duration + 0.5)
	local nonce = string.upper(toBase36((math.floor(os.clock() * 1000000) + math.random(0, 46655)) % 1679616))
	nonce = string.rep("0", 4 - #nonce) .. nonce
	return string.format("%s-%s-%s-%s", KEY_PREFIX, toBase36(expiry), nonce, sign(expiry, nonce)), expiry
end

function KeySys.validate(input)
	local raw = tostring(input or "")
	if raw == "" then
		return false, "enter a key"
	end
	if hash(OWNER_SALT .. compact(raw)) == ownerHash() then
		return true, nil, { tier = "owner", key = compact(raw) }
	end
	-- INDSÆT DISSE 3 LINJER HER:
	if compact(raw) == compact(PUBLIC_LIFETIME_KEY) then
		return true, nil, { tier = "key", key = string.upper(raw) }
	end
	-- RESTEN FORBLIVER HELT UÆNDRET:
	local cleaned = string.upper((string.gsub(raw, "%s+", "")))
	local expiryText, nonce, signature = string.match(cleaned, "^EX%-([%u%d]+)%-([%u%d][%u%d][%u%d][%u%d])%-(%x%x%x%x%x%x)$")
	if not expiryText then
		return false, "not a valid key"
	end
	local expiry = fromBase36(expiryText)
	if not expiry then
		return false, "not a valid key"
	end
	if sign(expiry, nonce) ~= signature then
		return false, "key signature is invalid"
	end
	if expiry <= os.time() then
		return false, "key expired " .. os.date("%Y-%m-%d %H:%M", expiry), { expiry = expiry }
	end
	return true, nil, { tier = "key", key = cleaned, expiry = expiry }
end


function KeySys.setOwnerKey(newKey)
	local value = compact(newKey)
	if #value < 4 then
		return false, "Denied"
	end
	if not writeStore(OWNER_FILE, hash(OWNER_SALT .. value)) then
		return false, "this executor cannot store files"
	end
	return true
end

function KeySys.resetOwnerKey()
	clearStore(OWNER_FILE)
	return true
end

function KeySys.ownerIsCustom()
	return readStore(OWNER_FILE) ~= nil
end

function KeySys.savedKey()
	return readStore(SESSION_FILE)
end

function KeySys.clearSession()
	clearStore(SESSION_FILE)
end

local gatePalette = {
	back = Color3.fromRGB(5, 6, 9),
	card = Color3.fromRGB(13, 14, 20),
	line = Color3.fromRGB(38, 42, 52),
	text = Color3.fromRGB(238, 240, 248),
	muted = Color3.fromRGB(128, 134, 152),
	accent = Color3.fromRGB(126, 150, 190),
	success = Color3.fromRGB(94, 226, 160),
	danger = Color3.fromRGB(255, 92, 122),
}

function KeySys.authenticate()
	local stale = PlayerGui:FindFirstChild("ExellieX_KeyGate")
	if stale then
		stale:Destroy()
	end
	local staleBlur = Lighting:FindFirstChild("ExellieXGateBlur")
	if staleBlur then
		staleBlur:Destroy()
	end

	local stored = KeySys.savedKey()
	if stored then
		local ok, _, info = KeySys.validate(stored)
		if ok then
			KeySys.session = info
			KeySys.tier = info.tier
			return info
		end
	end

	local gateGui = create("ScreenGui", {
		Name = "ExellieX_KeyGate",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 950,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, PlayerGui)
	local gateBlur = create("BlurEffect", { Name = "ExellieXGateBlur", Size = 18 }, Lighting)

	create("Frame", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = gatePalette.back,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
	}, gateGui)

	local card = create("Frame", {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(440, 282),
		BackgroundColor3 = gatePalette.card,
		BorderSizePixel = 0,
	}, gateGui)
	round(card, 14)
	local cardStroke = outline(card, gatePalette.line, 0.3, 1)
	create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(16, 17, 24), Color3.fromRGB(10, 11, 16)),
		Rotation = 90,
	}, card)

	create("Frame", {
		Position = UDim2.fromOffset(24, 22),
		Size = UDim2.fromOffset(3, 22),
		BackgroundColor3 = gatePalette.accent,
		BorderSizePixel = 0,
	}, card)

	local title = create("TextLabel", {
		Position = UDim2.fromOffset(38, 20),
		Size = UDim2.fromOffset(378, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "EXELLIEX KEY ACCESS",
		TextSize = 15,
		TextColor3 = gatePalette.text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local subtitle = create("TextLabel", {
		Position = UDim2.fromOffset(38, 44),
		Size = UDim2.fromOffset(378, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "ENTER YOUR KEY TO CONTINUE",
		TextSize = 8,
		TextColor3 = gatePalette.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local label = create("TextLabel", {
		Position = UDim2.fromOffset(28, 82),
		Size = UDim2.fromOffset(200, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "KEY",
		TextSize = 7,
		TextColor3 = gatePalette.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local box = create("TextBox", {
		Name = "KeyInput",
		Position = UDim2.fromOffset(28, 98),
		Size = UDim2.fromOffset(384, 38),
		BackgroundColor3 = Color3.fromRGB(8, 9, 13),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderText = "Enter key...",
		PlaceholderColor3 = gatePalette.muted,
		Text = "",
		TextColor3 = gatePalette.text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)
	round(box, 9)
	outline(box, gatePalette.line, 0.55, 1)
	create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, box)

		local hasServer = KEY_SERVER ~= nil and KEY_SERVER ~= ""
	local unlockWidth = hasServer and 186 or 384

	local unlock = create("TextButton", {
		Name = "Unlock",
		Position = UDim2.fromOffset(28, 148),
		Size = UDim2.fromOffset(unlockWidth, 36),
		BackgroundColor3 = gatePalette.accent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "UNLOCK",
		TextSize = 9,
		TextColor3 = gatePalette.back,
	}, card)
	round(unlock, 9)

	local getKeyBtn = nil
	if hasServer then
		getKeyBtn = create("TextButton", {
			Name = "GetKey",
			Position = UDim2.fromOffset(226, 148),
			Size = UDim2.fromOffset(186, 36),
			BackgroundColor3 = Color3.fromRGB(22, 25, 34),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = "GET KEY",
			TextSize = 9,
			TextColor3 = gatePalette.text,
		}, card)
		round(getKeyBtn, 9)
		outline(getKeyBtn, gatePalette.line, 0.4, 1)
	end

	local status = create("TextLabel", {
		Name = "Status",
		Position = UDim2.fromOffset(28, 196),
		Size = UDim2.fromOffset(384, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextSize = 8,
		TextColor3 = gatePalette.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	create("Frame", {
		Position = UDim2.fromOffset(28, 224),
		Size = UDim2.fromOffset(384, 1),
		BackgroundColor3 = gatePalette.line,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
	}, card)

	local footer = create("TextLabel", {
		Position = UDim2.fromOffset(28, 236),
		Size = UDim2.fromOffset(384, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = hasServer and "Click GET KEY to copy the key link, open it in your browser, and paste your key." or "Keys are checked offline. Ask the owner if yours expired.",
		TextSize = 8,
		TextColor3 = gatePalette.muted,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	if stored then
		box.Text = stored
		status.Text = "saved key no longer works - enter a new one"
		status.TextColor3 = gatePalette.danger
	end

	local result = nil

	local function shake()
		local home = UDim2.fromScale(0.5, 0.5)
		for step = 1, 3 do
			card.Position = home + UDim2.fromOffset(step % 2 == 0 and 7 or -7, 0)
			task.wait(0.04)
		end
		card.Position = home
	end

	local function submit()
		if result then
			return
		end
		local ok, reason, info = KeySys.validate(box.Text)
		if ok then
			result = info
			return
		end
		status.Text = string.upper(tostring(reason or "invalid key"))
		status.TextColor3 = gatePalette.danger
		shake()
	end

	if getKeyBtn then
		getKeyBtn.Activated:Connect(function()
			if type(setclipboard) == "function" then
				setclipboard(KEY_SERVER)
				status.Text = "KEY LINK COPIED TO CLIPBOARD - PASTE IN BROWSER"
				status.TextColor3 = gatePalette.success
			else
				box.Text = KEY_SERVER
				status.Text = "COPY THE URL FROM THE BOX ABOVE"
				status.TextColor3 = gatePalette.accent
			end
		end)
		getKeyBtn.MouseEnter:Connect(function()
			TweenService:Create(getKeyBtn, TweenInfo.new(0.14), { BackgroundColor3 = Color3.fromRGB(30, 34, 46) }):Play()
		end)
		getKeyBtn.MouseLeave:Connect(function()
			TweenService:Create(getKeyBtn, TweenInfo.new(0.16), { BackgroundColor3 = Color3.fromRGB(22, 25, 34) }):Play()
		end)
	end

	unlock.Activated:Connect(submit)

	box.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			submit()
		end
	end)
	box.Focused:Connect(function()
		cardStroke.Color = gatePalette.accent
		cardStroke.Transparency = 0.2
	end)
	box.FocusLost:Connect(function()
		cardStroke.Color = gatePalette.line
		cardStroke.Transparency = 0.3
	end)
	unlock.MouseEnter:Connect(function()
		TweenService:Create(unlock, TweenInfo.new(0.14), { BackgroundColor3 = gatePalette.accent:Lerp(Color3.new(1, 1, 1), 0.12) }):Play()
	end)
	unlock.MouseLeave:Connect(function()
		TweenService:Create(unlock, TweenInfo.new(0.16), { BackgroundColor3 = gatePalette.accent }):Play()
	end)

	while not result do
		task.wait(0.05)
	end

	status.Text = result.tier == "owner" and "OWNER SESSION" or "KEY ACCEPTED"
	status.TextColor3 = gatePalette.success
	writeStore(SESSION_FILE, result.key)
	TweenService:Create(card, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(title, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
	TweenService:Create(subtitle, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
	TweenService:Create(footer, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
	TweenService:Create(gateBlur, TweenInfo.new(0.25), { Size = 0 }):Play()
	task.wait(0.22)
	gateGui:Destroy()
	gateBlur:Destroy()

	KeySys.session = result
	KeySys.tier = result.tier
	return result
end

local SESSION = { tier = "key", key = "KEYLESS" }
local OWNER_MODE = false

local L = {
	bg = Color3.fromRGB(7, 8, 12),
	card = Color3.fromRGB(13, 14, 20),
	line = Color3.fromRGB(38, 42, 52),
	text = Color3.fromRGB(238, 240, 248),
	muted = Color3.fromRGB(128, 134, 152),
	accent = Color3.fromRGB(126, 150, 190),
	accentAlt = Color3.fromRGB(158, 205, 218),
	success = Color3.fromRGB(94, 226, 160),
	danger = Color3.fromRGB(255, 92, 122),
}

local loaderGui = create("ScreenGui", {
	Name = "ExellieX_Loader",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	DisplayOrder = 900,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local loaderBlur = create("BlurEffect", { Name = "ExellieXBlur", Size = 0 }, Lighting)
TweenService:Create(loaderBlur, TweenInfo.new(0.5), { Size = 18 }):Play()


local bootComplete = false
task.delay(15, function()
	if bootComplete or not loaderGui.Parent then
		return
	end
	pushLog("error", "boot watchdog: setup did not reach the reveal stage")
	pcall(function()
		local staleHub = PlayerGui:FindFirstChild("ExellieX_Hub")
		if not staleHub then
			return
		end
		local staleWindow = staleHub:FindFirstChild("Window")
		if staleWindow then
			staleWindow.Visible = true
		end
		local staleShadow = staleHub:FindFirstChild("Shadow")
		if staleShadow then
			staleShadow.Visible = true
		end
	end)
	pcall(function()
		loaderGui:Destroy()
	end)
	pcall(function()
		if loaderBlur.Parent then
			loaderBlur.Size = 14
		end
	end)
end)

local loaderRoot = create("Frame", {
	Name = "Root",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = L.bg,
	BorderSizePixel = 0,
}, loaderGui)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 14, 20)),
		ColorSequenceKeypoint.new(0.55, L.bg),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 5, 8)),
	}),
	Rotation = 90,
}, loaderRoot)

local loaderCard = create("Frame", {
	Name = "Card",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(500, 330),
	BackgroundColor3 = L.card,
	BorderSizePixel = 0,
}, loaderRoot)
round(loaderCard, 16)
local loaderCardStroke = outline(loaderCard, L.line, 0.65, 1)
local loaderCardScale = create("UIScale", { Scale = 0.97 }, loaderCard)
TweenService:Create(loaderCardScale, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Scale = 1 }):Play()

create("TextLabel", {
	Position = UDim2.fromOffset(28, 26),
	Size = UDim2.fromOffset(300, 26),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "ExellieX ScriptHub",
	TextSize = 20,
	TextColor3 = L.text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, loaderCard)

local loaderChip = create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -28, 0, 31),
	Size = UDim2.fromOffset(54, 20),
	BackgroundColor3 = Color3.fromRGB(20, 22, 29),
	Font = Enum.Font.GothamBold,
	Text = "v2.0",
	TextSize = 9,
	TextColor3 = L.accentAlt,
}, loaderCard)
round(loaderChip, 6)
outline(loaderChip, L.accentAlt, 0.75, 1)

local loaderStage = create("TextLabel", {
	Position = UDim2.fromOffset(28, 52),
	Size = UDim2.fromOffset(400, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Loading environment.",
	TextSize = 11,
	TextColor3 = L.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, loaderCard)

local loaderPercent = create("TextLabel", {
	Position = UDim2.fromOffset(28, 94),
	Size = UDim2.new(1, -56, 0, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "*",
	TextSize = 10,
	TextColor3 = L.accentAlt,
	TextXAlignment = Enum.TextXAlignment.Right,
}, loaderCard)

local loaderTrack = create("Frame", {
	Position = UDim2.fromOffset(28, 114),
	Size = UDim2.new(1, -56, 0, 6),
	BackgroundColor3 = Color3.fromRGB(24, 26, 33),
	BorderSizePixel = 0,
}, loaderCard)
round(loaderTrack, 3)

local loaderFill = create("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = L.accent,
	BorderSizePixel = 0,
}, loaderTrack)
round(loaderFill, 3)
create("UIGradient", { Color = ColorSequence.new(L.accent, L.accentAlt) }, loaderFill)
local loaderFillStroke = outline(loaderFill, L.accentAlt, 0.45, 1)

task.spawn(function()
	while loaderFillStroke.Parent do
		local ok = pcall(function()
			TweenService:Create(loaderFillStroke, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.85 }):Play()
		end)
		if not ok then
			break
		end
		task.wait(1.1)
		pcall(function()
			TweenService:Create(loaderFillStroke, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.35 }):Play()
		end)
		task.wait(1.1)
	end
end)

local loaderRowsFrame = create("Frame", {
	Position = UDim2.fromOffset(28, 140),
	Size = UDim2.new(1, -56, 0, 126),
	BackgroundTransparency = 1,
}, loaderCard)
create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, loaderRowsFrame)

create("TextLabel", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 28, 1, -14),
	Size = UDim2.new(1, -164, 0, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "SECURE LOCAL EXECUTION  -  " .. (RakNet and "RAKNET ONLINE" or "STD REMOTE"),
	TextSize = 8,
	TextColor3 = Color3.fromRGB(86, 92, 108),
	TextXAlignment = Enum.TextXAlignment.Left,
}, loaderCard)

local loaderProgress = Instance.new("NumberValue")
loaderProgress.Value = 0

local loaderTween
local function setLoaderProgress(target)
	if loaderTween then
		loaderTween:Cancel()
	end
	loaderTween = TweenService:Create(loaderProgress, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Value = target })
	loaderTween:Play()
end

loaderProgress.Changed:Connect(function(value)
	local clamped = math.clamp(value, 0, 100)
	loaderPercent.Text = string.format("%d%%", math.floor(clamped + 0.5))
	loaderFill.Size = UDim2.fromScale(clamped / 100, 1)
end)

local loaderRows = {}
local loaderRowIndex = 0

-- Skip control. The loader is cosmetic; the real build happens on the caller
-- thread, so skipping marks every remaining step as already done and reveals
-- the hub as soon as the build finishes (instantly if it already finished).
local skipRequested = false
local reveal

local skipButton = create("TextButton", {
	Name = "Skip",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -24, 1, -10),
	Size = UDim2.fromOffset(92, 24),
	BackgroundColor3 = Color3.fromRGB(20, 22, 29),
	AutoButtonColor = false,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "SKIP  >>",
	TextSize = 9,
	TextColor3 = L.accentAlt,
	ZIndex = 5,
}, loaderCard)
round(skipButton, 7)
local skipStroke = outline(skipButton, L.accentAlt, 0.55, 1)

skipButton.MouseEnter:Connect(function()
	TweenService:Create(skipButton, TweenInfo.new(0.14), { BackgroundColor3 = L.accent }):Play()
	TweenService:Create(skipStroke, TweenInfo.new(0.14), { Transparency = 0.1 }):Play()
end)
skipButton.MouseLeave:Connect(function()
	TweenService:Create(skipButton, TweenInfo.new(0.16), { BackgroundColor3 = Color3.fromRGB(20, 22, 29) }):Play()
	TweenService:Create(skipStroke, TweenInfo.new(0.16), { Transparency = 0.55 }):Play()
end)
skipButton.Activated:Connect(function()
	if skipRequested then
		return
	end
	skipRequested = true
	pcall(function()
		if loaderTween then
			loaderTween:Cancel()
		end
		loaderProgress.Value = 100
		loaderStage.Text = "Skipping load."
	end)
	pcall(function()
		skipButton.Visible = false
		skipStroke.Transparency = 1
	end)
	pushLog("info", "loader skipped by user")
	if reveal then
		reveal()
	end
end)

local function loaderStep(caption, target)
	if skipRequested then
		return
	end
	for _, row in ipairs(loaderRows) do
		if row.active then
			row.active = false
			row.dot.BackgroundColor3 = L.success
			row.dot.Text = "*"
			row.text.TextColor3 = Color3.fromRGB(96, 104, 120)
		end
	end
	loaderRowIndex += 1
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 27),
		BackgroundTransparency = 1,
		LayoutOrder = loaderRowIndex,
	}, loaderRowsFrame)
	local dot = create("TextLabel", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(0, 5),
		BackgroundColor3 = L.accent,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextSize = 10,
		TextColor3 = Color3.new(1, 1, 1),
	}, row)
	round(dot, 8)
	local text = create("TextLabel", {
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.new(1, -26, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = caption,
		TextSize = 10,
		TextColor3 = L.text,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	TweenService:Create(text, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
	if #loaderRows >= 4 then
		local oldest = table.remove(loaderRows, 1)
		TweenService:Create(oldest.text, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		TweenService:Create(oldest.dot, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		task.delay(0.22, function()
			if oldest.frame then
				oldest.frame:Destroy()
			end
		end)
	end
	loaderRows[#loaderRows + 1] = { frame = row, dot = dot, text = text, active = true }
	loaderStage.Text = "Loading " .. caption .. "."
	setLoaderProgress(target)
	if not skipRequested then
		task.wait(0.16)
	end
end

local function fadeLoader()
	local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local function fade(object, properties)
		if not object or not object.Parent then
			return
		end
		pcall(function()
			local tween = TweenService:Create(object, info, properties)
			tween:Play()
			return tween
		end)
	end
	fade(loaderRoot, { BackgroundTransparency = 1 })
	fade(loaderCard, { BackgroundTransparency = 1 })
	fade(loaderCardStroke, { Transparency = 1 })
	fade(loaderCardScale, { Scale = 0.96 })
	for _, object in ipairs(loaderRoot:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			fade(object, { TextTransparency = 1, BackgroundTransparency = 1 })
		elseif object:IsA("Frame") then
			fade(object, { BackgroundTransparency = 1 })
		elseif object:IsA("UIStroke") then
			fade(object, { Transparency = 1 })
		end
	end
	task.delay(0.45, function()
		pcall(function()
			loaderGui:Destroy()
		end)
	end)
end
loaderStep("service bindings", 8)



local WINDOW_W, WINDOW_H = 760, 600

local hubGui = create("ScreenGui", {
	Name = "ExellieX_Hub",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	DisplayOrder = 800,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local shadow = create("ImageLabel", {
	Name = "Shadow",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(WINDOW_W + 60, WINDOW_H + 56),
	BackgroundTransparency = 1,
	Image = "rbxassetid://6014261993",
	ImageColor3 = BLACK,
	ImageTransparency = 1,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(49, 49, 450, 450),
}, hubGui)

local window = create("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
	BackgroundColor3 = Theme.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
}, hubGui)
round(window, 16)

local windowScale = create("UIScale", { Scale = 1 }, window)
local windowStroke = outline(window, Theme.border, 0.35, 1.2)
local windowGradient = create("UIGradient", {
	Color = ColorSequence.new(Theme.bgTop, Theme.bgBottom),
	Rotation = 90,
}, window)

local topBar = create("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 58),
	BackgroundTransparency = 1,
	-- Active is what makes a plain Frame receive InputBegan; without it the
	-- drag handler never fires because the hit test walks past the frame.
	Active = true,
}, window)

local topLine = create("Frame", {
	Position = UDim2.new(0, 14, 0, 57),
	Size = UDim2.new(1, -28, 0, 1),
	BackgroundColor3 = Theme.border,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
}, topBar)

local brandTitle = create("TextLabel", {
	Position = UDim2.fromOffset(20, 12),
	Size = UDim2.fromOffset(260, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "ExellieX ScriptHub",
	TextSize = 15,
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topBar)

local brandSub = create("TextLabel", {
	Position = UDim2.fromOffset(20, 32),
	Size = UDim2.fromOffset(260, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "SCRIPT HUB  -  CLIENT EDITION",
	TextSize = 8,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topBar)

local transportChip = create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -112, 0, 19),
	Size = UDim2.fromOffset(96, 20),
	BackgroundColor3 = Theme.sunken,
	Font = Enum.Font.GothamBold,
	Text = RakNet and "RAKNET LINKED" or "STD REMOTES",
	TextSize = 8,
	TextColor3 = RakNet and Theme.success or Theme.muted,
}, topBar)
round(transportChip, 6)
local transportStroke = outline(transportChip, RakNet and Theme.success or Theme.border, 0.7, 1)

local ownerChip = nil
if OWNER_MODE then
	ownerChip = create("TextLabel", {
		Name = "OwnerChip",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -216, 0, 19),
		Size = UDim2.fromOffset(96, 20),
		BackgroundColor3 = Theme.sunken,
		Font = Enum.Font.GothamBold,
		Text = "OWNER ACCESS",
		TextSize = 8,
		TextColor3 = Theme.accentAlt,
	}, topBar)
	round(ownerChip, 6)
	local ownerStroke = outline(ownerChip, Theme.accentAlt, 0.7, 1)
	onTheme(function(palette)
		ownerChip.BackgroundColor3 = palette.sunken
		ownerChip.TextColor3 = palette.accentAlt
		ownerStroke.Color = palette.accentAlt
	end)
	brandSub.Text = "SCRIPT HUB  -  OWNER EDITION"
end

local function chromeButton(glyph, xOffset, key)
	local button = create("TextButton", {
		Size = UDim2.fromOffset(28, 26),
		Position = UDim2.new(1, xOffset, 0, 16),
		BackgroundColor3 = Theme.raised,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = glyph,
		TextSize = 14,
		TextColor3 = Theme[key],
	}, topBar)
	round(button, 7)
	local buttonStroke = outline(button, Theme[key], 0.7, 1)
	onTheme(function(palette)
		button.BackgroundColor3 = palette.raised
		button.TextColor3 = palette[key]
		buttonStroke.Color = palette[key]
	end)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.14), { BackgroundColor3 = Theme.raised:Lerp(WHITE, 0.06) }):Play()
		TweenService:Create(buttonStroke, TweenInfo.new(0.14), { Transparency = 0.2 }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.18), { BackgroundColor3 = Theme.raised }):Play()
		TweenService:Create(buttonStroke, TweenInfo.new(0.18), { Transparency = 0.7 }):Play()
	end)
	return button
end

local themeToggle = chromeButton("", -104, "accent")
for index = 1, 3 do
	local dotKey = ({ "accent", "accentAlt", "text" })[index]
	local dot = create("Frame", {
		Position = UDim2.fromOffset(6 + (index - 1) * 6, 11),
		Size = UDim2.fromOffset(5, 5),
		BackgroundColor3 = Theme[dotKey],
		BorderSizePixel = 0,
	}, themeToggle)
	round(dot, 3)
	onTheme(function(palette)
		dot.BackgroundColor3 = palette[dotKey]
	end)
end

local minimizeButton = chromeButton("-", -70, "accent")
local closeButton = chromeButton("x", -36, "danger")

onTheme(function(palette)
	window.BackgroundColor3 = palette.bg
	windowGradient.Color = ColorSequence.new(palette.bgTop, palette.bgBottom)
	windowStroke.Color = palette.border
	topLine.BackgroundColor3 = palette.border
	brandTitle.TextColor3 = palette.text
	brandSub.TextColor3 = palette.muted
	transportChip.BackgroundColor3 = palette.sunken
	transportChip.TextColor3 = RakNet and palette.success or palette.muted
	transportStroke.Color = RakNet and palette.success or palette.border
end)



local rail = create("Frame", {
	Name = "Rail",
	Position = UDim2.fromOffset(14, 72),
	Size = UDim2.new(0, 172, 1, -118),
	BackgroundColor3 = Theme.panel,
	BorderSizePixel = 0,
}, window)
round(rail, 12)
local railStroke = outline(rail, Theme.border, 0.55, 1)

create("TextLabel", {
	Position = UDim2.fromOffset(14, 12),
	Size = UDim2.new(1, -28, 0, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "NAVIGATION",
	TextSize = 8,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
}, rail)

local railList = create("ScrollingFrame", {
	Name = "Categories",
	Position = UDim2.fromOffset(10, 30),
	Size = UDim2.new(1, -20, 1, -86),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Theme.accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
}, rail)
create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, railList)
create("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2) }, railList)

create("TextLabel", {
	Position = UDim2.new(0, 14, 1, -44),
	Size = UDim2.new(1, -28, 0, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "TOGGLE INTERFACE",
	TextSize = 7,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
}, rail)

local hotkeyChip = create("TextLabel", {
	Position = UDim2.new(0, 14, 1, -28),
	Size = UDim2.fromOffset(58, 18),
	BackgroundColor3 = Theme.sunken,
	Font = Enum.Font.GothamBold,
	Text = "R CTRL",
	TextSize = 8,
	TextColor3 = Theme.text,
}, rail)
round(hotkeyChip, 5)
outline(hotkeyChip, Theme.border, 0.45, 1)

onTheme(function(palette)
	rail.BackgroundColor3 = palette.panel
	railStroke.Color = palette.border
	railList.ScrollBarImageColor3 = palette.accent
	hotkeyChip.BackgroundColor3 = palette.sunken
	hotkeyChip.TextColor3 = palette.text
end)



local content = create("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(198, 72),
	Size = UDim2.new(1, -212, 1, -118),
	BackgroundTransparency = 1,
}, window)

local searchBar = create("Frame", {
	Name = "Search",
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundColor3 = Theme.sunken,
	BorderSizePixel = 0,
}, content)
round(searchBar, 10)
local searchStroke = outline(searchBar, Theme.border, 0.55, 1)

local lens = create("Frame", {
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.fromOffset(11, 11),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, searchBar)
round(lens, 6)
local lensStroke = outline(lens, Theme.muted, 0.25, 1.5)

local lensHandle = create("Frame", {
	Position = UDim2.fromOffset(23, 24),
	Size = UDim2.fromOffset(2, 6),
	BackgroundColor3 = Theme.muted,
	BorderSizePixel = 0,
	Rotation = 45,
}, searchBar)

local searchBox = create("TextBox", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(36, 0),
	Size = UDim2.new(1, -50, 1, 0),
	ClearTextOnFocus = false,
	Font = Enum.Font.GothamMedium,
	PlaceholderText = "Search utilities",
	PlaceholderColor3 = Theme.muted,
	Text = "",
	TextColor3 = Theme.text,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, searchBar)

searchBox.Focused:Connect(function()
	TweenService:Create(searchStroke, TweenInfo.new(0.16), { Color = Theme.accent, Transparency = 0.15 }):Play()
end)
searchBox.FocusLost:Connect(function()
	TweenService:Create(searchStroke, TweenInfo.new(0.16), { Color = Theme.border, Transparency = 0.55 }):Play()
end)

local scroll = create("ScrollingFrame", {
	Name = "Utilities",
	Position = UDim2.fromOffset(0, 50),
	Size = UDim2.new(1, 0, 1, -50),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
}, content)
create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
create("UIPadding", { PaddingBottom = UDim.new(0, 10), PaddingRight = UDim.new(0, 8) }, scroll)

local emptyState = create("TextLabel", {
	Position = UDim2.fromOffset(0, 150),
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "NO UTILITIES MATCH",
	TextSize = 9,
	TextColor3 = Theme.muted,
	Visible = false,
}, content)

local statusBar = create("Frame", {
	Name = "StatusBar",
	Position = UDim2.new(0, 14, 1, -36),
	Size = UDim2.new(1, -28, 0, 22),
	BackgroundTransparency = 1,
}, window)

local statusDot = create("Frame", {
	Position = UDim2.fromOffset(2, 8),
	Size = UDim2.fromOffset(6, 6),
	BackgroundColor3 = Theme.success,
	BorderSizePixel = 0,
}, statusBar)
round(statusDot, 3)

local statusText = create("TextLabel", {
	Position = UDim2.fromOffset(16, 0),
	Size = UDim2.fromOffset(300, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "READY",
	TextSize = 9,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
}, statusBar)

local gameText = create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -2, 0, 0),
	Size = UDim2.fromOffset(280, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = game.Name,
	TextSize = 9,
	TextColor3 = Theme.muted,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Right,
}, statusBar)

onTheme(function(palette)
	searchBar.BackgroundColor3 = palette.sunken
	searchStroke.Color = palette.border
	lensStroke.Color = palette.muted
	lensHandle.BackgroundColor3 = palette.muted
	searchBox.TextColor3 = palette.text
	searchBox.PlaceholderColor3 = palette.muted
	scroll.ScrollBarImageColor3 = palette.accent
	emptyState.TextColor3 = palette.muted
	gameText.TextColor3 = palette.muted
	statusDot.BackgroundColor3 = palette.success
	statusText.TextColor3 = palette.muted
end)

task.spawn(function()
	local ok, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	end)
	if ok and info and info.Name and gameText.Parent then
		gameText.Text = info.Name
	end
end)

local toastHolder = create("Frame", {
	Name = "Toasts",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -14, 1, -42),
	Size = UDim2.fromOffset(270, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
}, window)
create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, toastHolder)

local toastCount = 0
local function toast(title, body, kind)
	toastCount += 1
	local accentColor = kind == "error" and Theme.danger or (kind == "busy" and Theme.accent or Theme.success)
	local item = create("Frame", {
		Name = "Toast",
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = -toastCount,
	}, toastHolder)
	round(item, 9)
	local itemStroke = outline(item, accentColor, 1, 1)
	local strip = create("Frame", {
		Size = UDim2.new(0, 3, 0, 16),
		Position = UDim2.fromOffset(0, 15),
		BackgroundColor3 = accentColor,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, item)
	round(strip, 2)
	local titleLabel = create("TextLabel", {
		Position = UDim2.fromOffset(14, 7),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextSize = 10,
		TextColor3 = Theme.text,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, item)
	local bodyLabel = create("TextLabel", {
		Position = UDim2.fromOffset(14, 23),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = body,
		TextSize = 9,
		TextColor3 = Theme.muted,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, item)
	local fade = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(item, fade, { BackgroundTransparency = 0.03 }):Play()
	TweenService:Create(itemStroke, fade, { Transparency = 0.55 }):Play()
	TweenService:Create(strip, fade, { BackgroundTransparency = 0 }):Play()
	TweenService:Create(titleLabel, fade, { TextTransparency = 0 }):Play()
	TweenService:Create(bodyLabel, fade, { TextTransparency = 0.15 }):Play()
	task.delay(4, function()
		if not item.Parent then
			return
		end
		local out = TweenInfo.new(0.25)
		TweenService:Create(item, out, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(itemStroke, out, { Transparency = 1 }):Play()
		TweenService:Create(strip, out, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(titleLabel, out, { TextTransparency = 1 }):Play()
		TweenService:Create(bodyLabel, out, { TextTransparency = 1 }):Play()
		task.delay(0.28, function()
			item:Destroy()
		end)
	end)
end
loaderStep("content shell", 38)
loaderStep("navigation rail", 46)



local registry = {}
local activeCategory = OWNER_MODE and "Owner" or "All"
local categoryHeaders = {}

local refreshRail
local refreshList
local applyTheme
local ownerPage

local statusToken = 0
local function setStatus(message, kind)
	statusToken += 1
	local token = statusToken
	statusDot.BackgroundColor3 = kind == "error" and Theme.danger or (kind == "busy" and Theme.accent or Theme.success)
	statusText.Text = string.upper(message)
	statusText.TextColor3 = kind == "error" and Theme.danger or Theme.muted
	if kind ~= "idle" then
		task.delay(3.5, function()
			if token ~= statusToken then
				return
			end
			statusDot.BackgroundColor3 = Theme.success
			statusText.Text = "READY"
			statusText.TextColor3 = Theme.muted
		end)
	end
end

local function runUtility(record)
	setStatus("loading " .. record.name, "busy")
	local started = os.clock()
	local results = table.pack(xpcall(function()
		if record.onClick then
			return record.onClick()
		end
		local payload = record.source
		if record.url then
			local body, fetchError = fetch(record.url)
			if not body then
				error("download failed: " .. tostring(fetchError), 0)
			end
			payload = body
		end
		if type(payload) ~= "string" or payload == "" then
			error("utility has no source", 0)
		end
		local chunk, compileError = loadstring(payload, "=ExellieX/" .. record.name)
		if not chunk then
			error("compile failed: " .. tostring(compileError), 0)
		end
		return chunk()
	end, function(err)
		return err, debug.traceback(tostring(err), 2)
	end))
	local elapsed = string.format("%dms", math.floor((os.clock() - started) * 1000))
	if results[1] then
		if results[2] ~= nil then
			pushLog("info", record.name .. " -> " .. describe(results[2]))
		end
		pushLog("info", string.format("loaded %s in %s", record.name, elapsed))
		setStatus("ready", "idle")
		toast(record.name, "Loaded in " .. elapsed, "success")
	else
		pushLog("error", record.name .. ": " .. describe(results[2]))
		if results[3] then
			pushLog("trace", results[3])
		end
		setStatus("error", "error")
		toast(record.name, describe(results[2]), "error")
	end
end

local function createCard(record)
	local card = create("TextButton", {
		Name = "Utility_" .. string.gsub(record.name, "[^%w]", ""),
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Theme.sunken,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		Visible = false,
	}, scroll)
	round(card, 10)
	local cardStroke = outline(card, Theme.border, 0.6, 1)
	local accent = create("Frame", {
		Size = UDim2.new(0, 3, 0, 18),
		Position = UDim2.fromOffset(0, 23),
		BackgroundColor3 = Theme.accent,
		BorderSizePixel = 0,
	}, card)
	round(accent, 2)
	local cardScale = create("UIScale", { Scale = 1 }, card)
	local nameLabel = create("TextLabel", {
		Position = UDim2.fromOffset(18, 12),
		Size = UDim2.new(1, -60, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = record.name,
		TextSize = 13,
		TextColor3 = Theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, card)
	local metaLabel = create("TextLabel", {
		Position = UDim2.fromOffset(18, 32),
		Size = UDim2.new(1, -60, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = record.meta,
		TextSize = 9,
		TextColor3 = Theme.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, card)
	local arrow = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(18, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = ">",
		TextSize = 21,
		TextColor3 = Theme.muted,
	}, card)

	onTheme(function(palette)
		card.BackgroundColor3 = palette.sunken
		cardStroke.Color = palette.border
		accent.BackgroundColor3 = palette.accent
		nameLabel.TextColor3 = palette.text
		metaLabel.TextColor3 = palette.muted
		arrow.TextColor3 = palette.muted
	end)

	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.16), { BackgroundColor3 = Theme.raised }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.16), { Color = Theme.accent, Transparency = 0.15 }):Play()
		TweenService:Create(accent, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, 4, 0, 34),
			Position = UDim2.fromOffset(0, 15),
		}):Play()
		TweenService:Create(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			Position = UDim2.new(1, -10, 0.5, 0),
			TextColor3 = Theme.accent,
		}):Play()
		TweenService:Create(cardScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Scale = 1.008 }):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.18), { BackgroundColor3 = Theme.sunken }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.18), { Color = Theme.border, Transparency = 0.6 }):Play()
		TweenService:Create(accent, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, 3, 0, 18),
			Position = UDim2.fromOffset(0, 23),
		}):Play()
		TweenService:Create(arrow, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
			Position = UDim2.new(1, -16, 0.5, 0),
			TextColor3 = Theme.muted,
		}):Play()
		TweenService:Create(cardScale, TweenInfo.new(0.22, Enum.EasingStyle.Quint), { Scale = 1 }):Play()
	end)
	card.MouseButton1Down:Connect(function()
		TweenService:Create(cardScale, TweenInfo.new(0.08), { Scale = 0.994 }):Play()
	end)
	card.MouseButton1Up:Connect(function()
		TweenService:Create(cardScale, TweenInfo.new(0.14), { Scale = 1.008 }):Play()
	end)
	card.Activated:Connect(function()
		task.spawn(runUtility, record)
	end)
	return card
end

local function createCategoryHeader(name)
	local header = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = string.upper(name),
		TextSize = 8,
		TextColor3 = Theme.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = false,
	}, scroll)
	create("UIPadding", { PaddingLeft = UDim.new(0, 4) }, header)
	header.Position = UDim2.fromOffset(4, 0)
	onTheme(function(palette)
		header.TextColor3 = palette.muted
	end)
	return header
end

local function registerUtility(config)
	if type(config) ~= "table" or type(config.name) ~= "string" or config.name == "" then
		pushLog("error", "Hub:Button rejected an invalid utility definition")
		return nil
	end

	local tags = config.tags
	if tags == nil then
		tags = {}
	elseif type(tags) == "string" then
		tags = { tags }
	elseif type(tags) ~= "table" then
		tags = { tostring(tags) }
	end
	local record = {
		name = config.name,
		description = tostring(config.description or ""),
		category = tostring(config.category or "Scripts"),
		tags = tags,
		url = config.url,
		source = config.source,
		onClick = config.onClick,
	}
	local metaParts = {}
	if record.description ~= "" then
		metaParts[#metaParts + 1] = record.description
	end
	for _, tag in ipairs(tags) do
		metaParts[#metaParts + 1] = string.upper(tostring(tag))
	end
	record.meta = #metaParts > 0 and table.concat(metaParts, "   -   ") or "Ready"
	record.card = createCard(record)
	registry[#registry + 1] = record
	refreshRail()
	refreshList()
	return record
end

local Hub = {}
Hub.Version = "2.0"
Hub.Utilities = registry
Hub.KeySystem = KeySys
Hub.Owner = OWNER_MODE

function Hub:Button(config)
	local ok, result = pcall(registerUtility, config)
	if not ok then
		pushLog("error", "Hub:Button failed: " .. describe(result))
		return nil
	end
	return result
end

function Hub:Toast(title, body, kind)
	toast(title, body, kind)
end

function Hub:Fire(remote, ...)
	return fireRemote(remote, ...)
end

function Hub:Log(message)
	pushLog("info", message)
end

function Hub:SetTheme(themeId)
	applyTheme(themeId)
end



refreshList = function()
	if OWNER_MODE and activeCategory == "Owner" then
		searchBar.Visible = false
		scroll.Visible = false
		emptyState.Visible = false
		for _, record in ipairs(registry) do
			record.card.Visible = false
		end
		for _, header in pairs(categoryHeaders) do
			header.Visible = false
		end
		if ownerPage then
			ownerPage.Visible = true
		end
		return
	end
	if ownerPage then
		ownerPage.Visible = false
	end
	searchBar.Visible = true
	scroll.Visible = true
	local query = string.lower(searchBox.Text)
	local order = 0
	local shown = 0
	local used = {}
	for _, record in ipairs(registry) do
		local matchesCategory = activeCategory == "All" or record.category == activeCategory
		local haystack = string.lower(record.name .. " " .. record.meta .. " " .. record.category)
		local matchesQuery = query == "" or string.find(haystack, query, 1, true) ~= nil
		local visible = matchesCategory and matchesQuery
		record.card.Visible = visible
		if visible then
			shown += 1
			if activeCategory == "All" then
				local header = categoryHeaders[record.category]
				if not header then
					header = createCategoryHeader(record.category)
					categoryHeaders[record.category] = header
				end
				if not used[record.category] then
					used[record.category] = true
					header.Visible = true
					header.LayoutOrder = order
					order += 1
				end
			end
			record.card.LayoutOrder = order
			order += 1
		end
	end
	for name, header in pairs(categoryHeaders) do
		if not used[name] then
			header.Visible = false
		end
	end
	emptyState.Visible = shown == 0
end

refreshRail = function()
	for _, child in ipairs(railList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	local categories = { "All" }
	local seen = { All = true }
	local counts = { All = #registry }
	for _, record in ipairs(registry) do
		counts[record.category] = (counts[record.category] or 0) + 1
		if not seen[record.category] then
			seen[record.category] = true
			categories[#categories + 1] = record.category
		end
	end
	if OWNER_MODE then
		categories[#categories + 1] = "Owner"
		seen.Owner = true
	end
	for index, name in ipairs(categories) do
		local selected = name == activeCategory
		local button = create("TextButton", {
			Name = "Nav_" .. string.gsub(name, "[^%w]", ""),
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = selected and Theme.raised or Theme.panel,
			BackgroundTransparency = selected and 0 or 1,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Text = "",
			LayoutOrder = index,
		}, railList)
		round(button, 8)
		local navStroke = outline(button, selected and Theme.accent or Theme.border, selected and 0.35 or 1, 1)
		local bar = create("Frame", {
			Size = UDim2.new(0, 3, 0, selected and 16 or 0),
			Position = UDim2.fromOffset(0, 9),
			BackgroundColor3 = Theme.accent,
			BorderSizePixel = 0,
		}, button)
		round(bar, 2)
		local label = create("TextLabel", {
			Position = UDim2.fromOffset(13, 0),
			Size = UDim2.new(1, -44, 1, 0),
			BackgroundTransparency = 1,
			Font = selected and Enum.Font.GothamBold or Enum.Font.GothamMedium,
			Text = name == "Owner" and "OWNER CONSOLE" or name,
			TextSize = 10,
			TextColor3 = selected and Theme.text or Theme.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, button)
		create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(26, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = name == "Owner" and "" or tostring(counts[name] or 0),
			TextSize = 8,
			TextColor3 = Theme.muted,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, button)
		button.MouseEnter:Connect(function()
			if name == activeCategory then
				return
			end
			TweenService:Create(button, TweenInfo.new(0.14), {
				BackgroundColor3 = Theme.raised,
				BackgroundTransparency = 0,
			}):Play()
			TweenService:Create(navStroke, TweenInfo.new(0.14), { Color = Theme.border, Transparency = 0.4 }):Play()
			TweenService:Create(label, TweenInfo.new(0.14), { TextColor3 = Theme.text }):Play()
		end)
		button.MouseLeave:Connect(function()
			if name == activeCategory then
				return
			end
			TweenService:Create(button, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(navStroke, TweenInfo.new(0.16), { Color = Theme.border, Transparency = 1 }):Play()
			TweenService:Create(label, TweenInfo.new(0.16), { TextColor3 = Theme.muted }):Play()
		end)
		button.Activated:Connect(function()
			activeCategory = name
			refreshRail()
			refreshList()
		end)
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	refreshList()
end)

loaderStep("utility registry", 66)
loaderStep("theme hooks", 82)



-- Owner console -------------------------------------------------------------
-- Only the owner tier builds these widgets, so a normal key session never gets
-- minting code in its GUI tree at all.

if OWNER_MODE then
	ownerPage = create("ScrollingFrame", {
		Name = "OwnerConsole",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.accent,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	}, content)
	create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, ownerPage)
	create("UIPadding", {
		PaddingRight = UDim.new(0, 6),
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 14),
	}, ownerPage)

	local tinted = {}
	local function tint(object, property, key)
		object[property] = Theme[key]
		tinted[#tinted + 1] = { object = object, property = property, key = key }
		return object
	end
	onTheme(function(palette)
		for _, entry in ipairs(tinted) do
			entry.object[entry.property] = palette[entry.key]
		end
		ownerPage.ScrollBarImageColor3 = palette.accent
	end)

	local function card(order, height, title, subtitle)
		local frame = create("Frame", {
			Name = "Panel_" .. string.gsub(title, "[^%w]", ""),
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = Theme.panel,
			BorderSizePixel = 0,
			LayoutOrder = order,
		}, ownerPage)
		round(frame, 10)
		local stroke = create("UIStroke", { Thickness = 1, Transparency = 0.55 }, frame)
		tint(frame, "BackgroundColor3", "panel")
		tint(stroke, "Color", "border")
		local strip = create("Frame", {
			Position = UDim2.fromOffset(0, 16),
			Size = UDim2.fromOffset(3, 17),
			BackgroundColor3 = Theme.accent,
			BorderSizePixel = 0,
		}, frame)
		round(strip, 2)
		tint(strip, "BackgroundColor3", "accent")
		local heading = create("TextLabel", {
			Position = UDim2.fromOffset(16, 13),
			Size = UDim2.new(1, -32, 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = title,
			TextSize = 9,
			TextColor3 = Theme.text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, frame)
		tint(heading, "TextColor3", "text")
		local note = create("TextLabel", {
			Position = UDim2.fromOffset(16, 29),
			Size = UDim2.new(1, -32, 0, 12),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = subtitle,
			TextSize = 7,
			TextColor3 = Theme.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, frame)
		tint(note, "TextColor3", "muted")
		return frame
	end

	local function label(parent, position, size, value, textSize, key, font)
		local object = create("TextLabel", {
			Position = position,
			Size = size,
			BackgroundTransparency = 1,
			Font = font or Enum.Font.GothamMedium,
			Text = value,
			TextSize = textSize,
			TextColor3 = Theme[key or "muted"],
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, parent)
		tint(object, "TextColor3", key or "muted")
		return object
	end

	local function button(parent, position, size, value, filled)
		local object = create("TextButton", {
			Position = position,
			Size = size,
			BackgroundColor3 = filled and Theme.accent or Theme.sunken,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = value,
			TextSize = 8,
			TextColor3 = filled and Theme.bg or Theme.text,
		}, parent)
		round(object, 7)
		local stroke = create("UIStroke", { Thickness = 1, Transparency = filled and 1 or 0.55 }, object)
		tint(object, "BackgroundColor3", filled and "accent" or "sunken")
		tint(object, "TextColor3", filled and "bg" or "text")
		tint(stroke, "Color", filled and "accent" or "border")
		object.MouseEnter:Connect(function()
			TweenService:Create(object, TweenInfo.new(0.12), {
				BackgroundColor3 = filled and Theme.accentAlt or Theme.raised,
			}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.12), { Transparency = 0.25 }):Play()
		end)
		object.MouseLeave:Connect(function()
			TweenService:Create(object, TweenInfo.new(0.16), {
				BackgroundColor3 = filled and Theme.accent or Theme.sunken,
			}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.16), { Transparency = filled and 1 or 0.55 }):Play()
		end)
		return object
	end

	local function field(parent, position, size, placeholder, code)
		local object = create("TextBox", {
			Position = position,
			Size = size,
			BackgroundColor3 = Theme.sunken,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = code and Enum.Font.Code or Enum.Font.GothamMedium,
			PlaceholderText = placeholder,
			PlaceholderColor3 = Theme.muted,
			Text = "",
			TextColor3 = Theme.text,
			TextSize = code and 10 or 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, parent)
		round(object, 7)
		local stroke = create("UIStroke", { Thickness = 1, Transparency = 0.55 }, object)
		tint(object, "BackgroundColor3", "sunken")
		tint(object, "TextColor3", "text")
		tint(stroke, "Color", "border")
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}, object)
		object.Focused:Connect(function()
			stroke.Color = Theme.accent
			stroke.Transparency = 0.2
		end)
		object.FocusLost:Connect(function()
			stroke.Color = Theme.border
			stroke.Transparency = 0.55
		end)
		return object
	end

	local function copy(raw)
		local value = tostring(raw or "")
		if value == "" then
			return false
		end
		if type(setclipboard) == "function" then
			return (pcall(setclipboard, value))
		end
		if type(toclipboard) == "function" then
			return (pcall(toclipboard, value))
		end
		return false
	end

	local function describeDuration(hours)
		hours = tonumber(hours) or 1
		if hours >= 24 and math.abs(hours % 24) < 1e-6 then
			return string.format("%d DAYS", math.floor(hours / 24 + 0.5))
		end
		if hours >= 1 then
			return string.format("%s HOURS", tostring(math.floor(hours * 100 + 0.5) / 100))
		end
		return string.format("%d MINUTES", math.max(1, math.floor(hours * 60 + 0.5)))
	end

	-- session ---------------------------------------------------------------
	local sessionCard = card(1, 96, "SESSION", "AUTHENTICATED AS OWNER - FULL CONSOLE ACCESS")
	local keyStateLabel = label(sessionCard, UDim2.fromOffset(16, 50), UDim2.new(1, -180, 0, 13),
		"MASTER KEY  DEFAULT", 8, "accentAlt", Enum.Font.GothamBold)
	label(sessionCard, UDim2.fromOffset(16, 66), UDim2.new(1, -180, 0, 13),
		"MINTED KEYS ARE SIGNED LOCALLY - NO HOSTING NEEDED", 7, "muted")
	local signOut = button(sessionCard, UDim2.new(1, -152, 0, 54), UDim2.fromOffset(136, 28), "SIGN OUT", false)

	-- master key ------------------------------------------------------------
	local masterCard = card(2, 190, "MASTER KEY", "FORGOT A NEW KEY? DELETE ExellieX/owner.hash")
	local masterState = label(masterCard, UDim2.fromOffset(16, 50), UDim2.new(1, -32, 0, 13),
		"CURRENT  DEFAULT MASTER KEY", 8, "muted", Enum.Font.GothamBold)
	local masterBox = field(masterCard, UDim2.fromOffset(16, 68), UDim2.new(1, -32, 0, 34), "new master key")
	local saveKey = button(masterCard, UDim2.fromOffset(16, 110), UDim2.fromOffset(168, 30), "SAVE MASTER KEY", true)
	local resetKey = button(masterCard, UDim2.fromOffset(194, 110), UDim2.fromOffset(168, 30), "RESET TO DEFAULT", false)
	local masterStatus = label(masterCard, UDim2.fromOffset(16, 150), UDim2.new(1, -32, 0, 14), "", 8, "muted")

	-- mint ------------------------------------------------------------------
	local mintCard = card(3, 306, "MINT KEYS", "PICK A DURATION - THE KEY STOPS WORKING EXACTLY THEN")
	local presetRow = create("Frame", {
		Position = UDim2.fromOffset(16, 50),
		Size = UDim2.new(1, -32, 0, 28),
		BackgroundTransparency = 1,
	}, mintCard)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, presetRow)
	local presets = {
		{ text = "1 HOUR", hours = 1 },
		{ text = "6 HOURS", hours = 6 },
		{ text = "24 HOURS", hours = 24 },
		{ text = "7 DAYS", hours = 168 },
		{ text = "30 DAYS", hours = 720 },
	}
	local presetChips = {}
	for index, preset in ipairs(presets) do
		local chip = button(presetRow, UDim2.fromOffset(0, 0), UDim2.fromOffset(98, 28), preset.text, false)
		chip.LayoutOrder = index
		presetChips[index] = { button = chip, hours = preset.hours }
	end

	local customBox = field(mintCard, UDim2.fromOffset(16, 88), UDim2.fromOffset(150, 32), "custom hours")
	local customMint = button(mintCard, UDim2.fromOffset(174, 88), UDim2.fromOffset(150, 32), "MINT CUSTOM", true)
	local copyKey = button(mintCard, UDim2.fromOffset(332, 88), UDim2.fromOffset(120, 32), "COPY KEY", false)
	local output = field(mintCard, UDim2.fromOffset(16, 130), UDim2.new(1, -32, 0, 38), "minted key appears here", true)
	pcall(function()
		output.TextEditable = false
	end)
	local mintStatus = label(mintCard, UDim2.fromOffset(16, 174), UDim2.new(1, -32, 0, 14), "", 8, "muted")
	label(mintCard, UDim2.fromOffset(16, 198), UDim2.new(1, -32, 0, 12),
		"MINTED THIS SESSION  -  CLICK A ROW TO COPY", 7, "muted", Enum.Font.GothamBold)
	local mintList = create("ScrollingFrame", {
		Position = UDim2.fromOffset(16, 214),
		Size = UDim2.new(1, -32, 0, 78),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.accent,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, mintCard)
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, mintList)
	local emptyList = label(mintList, UDim2.fromOffset(0, 2), UDim2.new(1, 0, 0, 16), "no keys minted yet", 8, "muted")

	local mintCount = 0
	local function addMintRow(key, expiry)
		mintCount += 1
		emptyList.Visible = false
		local row = create("TextButton", {
			Name = "Minted_" .. mintCount,
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundColor3 = Theme.sunken,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Text = "",
			LayoutOrder = mintCount,
		}, mintList)
		round(row, 5)
		tint(row, "BackgroundColor3", "sunken")
		label(row, UDim2.fromOffset(8, 0), UDim2.new(1, -196, 1, 0), key, 9, "text", Enum.Font.Code)
		local stamp = label(row, UDim2.new(1, -182, 0, 0), UDim2.fromOffset(174, 22),
			os.date("%Y-%m-%d %H:%M", expiry), 8, "muted")
		stamp.TextXAlignment = Enum.TextXAlignment.Right
		row.Activated:Connect(function()
			if copy(key) then
				mintStatus.Text = "COPIED  " .. key
				mintStatus.TextColor3 = Theme.success
			else
				mintStatus.Text = "CLIPBOARD UNAVAILABLE - SELECT THE KEY IN THE BOX ABOVE"
				mintStatus.TextColor3 = Theme.danger
			end
		end)
	end

	local function mint(hours)
		hours = tonumber(hours) or 24
		local key, expiry = KeySys.mint(hours)
		output.Text = key
		mintStatus.Text = string.format("VALID UNTIL %s  -  %s", os.date("%Y-%m-%d %H:%M", expiry), describeDuration(hours))
		mintStatus.TextColor3 = Theme.success
		addMintRow(key, expiry)
		pushLog("info", "minted key until " .. os.date("%Y-%m-%d %H:%M", expiry))
	end

	local function mintCustom()
		local hours = tonumber(customBox.Text)
		if not hours or hours <= 0 then
			mintStatus.Text = "ENTER A NUMBER OF HOURS ABOVE 0"
			mintStatus.TextColor3 = Theme.danger
			return
		end
		mint(hours)
	end

	for _, entry in ipairs(presetChips) do
		entry.button.Activated:Connect(function()
			mint(entry.hours)
		end)
	end
	customMint.Activated:Connect(mintCustom)
	customBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			mintCustom()
		end
	end)
	copyKey.Activated:Connect(function()
		if copy(output.Text) then
			mintStatus.Text = "KEY COPIED TO CLIPBOARD"
			mintStatus.TextColor3 = Theme.success
		else
			mintStatus.Text = "CLIPBOARD UNAVAILABLE - COPY THE TEXT MANUALLY"
			mintStatus.TextColor3 = Theme.danger
		end
	end)

	-- actions ---------------------------------------------------------------
	local function refreshMasterState()
		masterState.Text = KeySys.ownerIsCustom() and "CURRENT  CUSTOM MASTER KEY" or "CURRENT  DEFAULT MASTER KEY"
		keyStateLabel.Text = "MASTER KEY  " .. (KeySys.ownerIsCustom() and "CUSTOM" or "DEFAULT")
	end
	refreshMasterState()

	local function saveMaster()
		local ok, reason = KeySys.setOwnerKey(masterBox.Text)
		if not ok then
			masterStatus.Text = string.upper(tostring(reason or "could not save"))
			masterStatus.TextColor3 = Theme.danger
			return
		end
		masterBox.Text = ""
		masterStatus.Text = "MASTER KEY UPDATED - USE IT ON THE NEXT LAUNCH"
		masterStatus.TextColor3 = Theme.success
		KeySys.clearSession()
		refreshMasterState()
		pushLog("info", "owner master key rotated")
	end

	saveKey.Activated:Connect(saveMaster)
	masterBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			saveMaster()
		end
	end)

	resetKey.Activated:Connect(function()
		KeySys.resetOwnerKey()
		masterBox.Text = ""
		masterStatus.Text = "DEFAULT MASTER KEY RESTORED"
		masterStatus.TextColor3 = Theme.success
		KeySys.clearSession()
		refreshMasterState()
		pushLog("info", "owner master key reset to default")
	end)

	signOut.Activated:Connect(function()
		KeySys.clearSession()
		KeySys.session = nil
		KeySys.tier = nil
		pushLog("info", "owner session signed out")
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = "ExellieX ScriptHub",
				Text = "Signed out - execute the hub again to enter a key",
				Duration = 5,
			})
		end)
		if Hub.Unload then
			Hub:Unload()
		end
	end)
end



local themePanel = create("Frame", {
	Name = "Appearance",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 56),
	Size = UDim2.fromOffset(300, 404),
	BackgroundColor3 = Theme.panel,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 30,
}, window)
round(themePanel, 12)
local themePanelStroke = outline(themePanel, Theme.border, 0.3, 1)

create("TextLabel", {
	Position = UDim2.fromOffset(16, 14),
	Size = UDim2.new(1, -100, 0, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "APPEARANCE",
	TextSize = 9,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
}, themePanel)

local themeCountLabel = create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -16, 0, 14),
	Size = UDim2.fromOffset(80, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = #ThemeOrder .. " THEMES",
	TextSize = 8,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Right,
}, themePanel)

local themeGrid = create("ScrollingFrame", {
	Position = UDim2.fromOffset(16, 38),
	Size = UDim2.new(1, -32, 1, -54),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.accent,
	ScrollingDirection = Enum.ScrollingDirection.Y,
}, themePanel)
create("UIGridLayout", {
	CellSize = UDim2.fromOffset(128, 54),
	CellPadding = UDim2.fromOffset(8, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, themeGrid)

onTheme(function(palette)
	themePanel.BackgroundColor3 = palette.panel
	themePanelStroke.Color = palette.border
	themePanelStroke.Transparency = 0.3
	themeCountLabel.TextColor3 = palette.muted
	themeGrid.ScrollBarImageColor3 = palette.accent
end)

local themeSwatches = {}

local refreshThemeSelection

applyTheme = function(themeId)
	local palette = ThemeById[themeId]
	if not palette then
		return
	end
	Theme = palette
	activeThemeId = themeId
	for _, hook in ipairs(themeHooks) do
		pcall(hook, palette)
	end
	refreshRail()
	refreshThemeSelection()
	pushLog("info", "palette -> " .. themeId)
end

refreshThemeSelection = function()
	for id, swatch in pairs(themeSwatches) do
		local selected = id == activeThemeId
		swatch.stroke.Color = selected and Theme.accentAlt or Theme.border
		swatch.stroke.Transparency = selected and 0.1 or 0.65
		swatch.label.TextColor3 = selected and Theme.accentAlt or Theme.muted
		swatch.tick.Visible = selected
	end
end

for index, id in ipairs(ThemeOrder) do
	local palette = ThemeById[id]
	local swatch = create("TextButton", {
		Name = "Theme_" .. id,
		Size = UDim2.fromOffset(128, 54),
		BackgroundColor3 = palette.bg,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		LayoutOrder = index,
	}, themeGrid)
	round(swatch, 8)
	local swatchStroke = outline(swatch, Theme.border, 0.65, 1)
	swatchStroke.Color = id == activeThemeId and Theme.accentAlt or Theme.border
	for dotIndex, dotKey in ipairs({ "bg", "accent", "accentAlt" }) do
		local dot = create("Frame", {
			Position = UDim2.fromOffset(10 + (dotIndex - 1) * 12, 12),
			Size = UDim2.fromOffset(9, 9),
			BackgroundColor3 = palette[dotKey],
			BorderSizePixel = 0,
		}, swatch)
		round(dot, 5)
		if dotKey == "bg" then
			outline(dot, palette.text, 0.6, 1)
		end
	end
	local label = create("TextLabel", {
		Position = UDim2.fromOffset(10, 31),
		Size = UDim2.new(1, -24, 0, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = id,
		TextSize = 9,
		TextColor3 = palette.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, swatch)
	local tick = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -7, 0, 7),
		Size = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "*",
		TextSize = 10,
		TextColor3 = palette.accentAlt,
		Visible = false,
	}, swatch)
	swatch.MouseEnter:Connect(function()
		swatchStroke.Transparency = 0.1
	end)
	swatch.MouseLeave:Connect(function()
		if id ~= activeThemeId then
			swatchStroke.Transparency = 0.65
		end
	end)
	swatch.Activated:Connect(function()
		applyTheme(id)
		themePanel.Visible = false
	end)
	themeSwatches[id] = { stroke = swatchStroke, label = label, tick = tick, button = swatch }
end

themeToggle.Activated:Connect(function()
	themePanel.Visible = not themePanel.Visible
end)


Hub:Button({
	name = "Infinite Yield",
	description = "Administrative command bar",
	category = "Scripts",
	tags = { "Admin" },
	url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
})

Hub:Button({
	name = "ExellieX Self Test",
	description = "Validates the loader pipeline locally",
	category = "Diagnostics",
	tags = { "Local", "Debug" },
	source = table.concat({
		'local name = "ExellieX ScriptHub"',
		'print(string.format("[ExellieX] %s self test ok", name))',
		"return name",
	}, "\n"),
})

Hub:Button({
	name = "Transport Report",
	description = "Prints the active remote transport",
	category = "Diagnostics",
	tags = { RakNet and "RakNet" or "Standard" },
	onClick = function()
		local message = RakNet and "raknet transport attached" or "standard remote transport"
		print(PREFIX .. " " .. message)
		return message
	end,
})

Hub:Button({
	name = "Rejoin Server",
	description = "Reconnects to the current place",
	category = "Session",
	tags = { "Teleport" },
	onClick = function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
		return "rejoin requested"
	end,
})

Hub:Button({
	name = "Copy Job ID",
	description = "Places the server JobId on the clipboard",
	category = "Session",
	tags = { "Clipboard" },
	onClick = function()
		if type(setclipboard) ~= "function" then
			error("setclipboard is unavailable", 0)
		end
		setclipboard(tostring(game.JobId))
		return game.JobId
	end,
})

-------------------------------------------------------------------------------
-- ADD NEW BUTTONS HERE
-- Drop a Hub:Button block anywhere below this line and above the
-- "scale, input, lifecycle" banner. Category text creates a nav entry.
--   Hub:Button({
--       name = "My Script",
--       description = "What it does",
--       category = "Scripts",
--       tags = { "Combat" },              -- table; a plain string also works
--       url = "https://example.com/script.lua",
--   })
-------------------------------------------------------------------------------

Hub:Button({
    name = "Snowy Hub",
    description = "I love xmas",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://scriptblox.com/raw/Universal-Script-Snowy-Hub-237438",
})

Hub:Button({
    name = "Overflow",
    description = "It is Overflowing",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://scriptblox.com/raw/Universal-Script-Overflow-12-Supported-Games-240679",
})

Hub:Button({
    name = "Exoz",
    description = "Best Tower of Hell Script",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://raw.githubusercontent.com/EzWinsV4/Exoz/refs/heads/main/Exoz/Main.lua",
})

Hub:Button({
    name = "7yd7 Emotes",
    description = "Recommended Emote Script",
    category = "Player",
    tags = { "Emotes" },
    url = "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua",
})

Hub:Button({
    name = "No Lag Hub",
    description = "Ultimate Script For Bloxfruits",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://nolag.wtf/script.lua",
})

Hub:Button({
    name = "Project Stark",
    description = "Owned by urbanstorm.uk",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://raw.githubusercontent.com/Urbanstormm/Project-Stark/main/Main.lua",
})

Hub:Button({
    name = "YARHM",
    description = "Yet Another Random Hub Menu",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://scriptblox.com/raw/Universal-Script-YARHM-12403",
})

Hub:Button({
    name = "Lumin Hub",
    description = "Insta Steal",
    category = "Scripts",
    tags = { "Scripts" },
    url = "http://luminon.top/loader.lua",
})

Hub:Button({
    name = "CoolKid Clan GUI V1",
    description = "The OG of CoolKid Clan GUI",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://raw.githubusercontent.com/cfsmi2/c00lguiv1/refs/heads/main/Main.lua",
})

Hub:Button({
    name = "CoolKid Clan GUI V2",
    description = "The NEW Coolkid Clan GUI",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://gist.githubusercontent.com/wateringcancan-eng/209697b404ddee53bac61f2dca1237fc/raw/690217aa6cf7e4d5717b4caa285f2236b1dcde26/C00lcl4n_2_0.lua",
})

Hub:Button({
    name = "Voidware",
    description = "Best 99 Keyless Script",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://files.vapevoidware.xyz/VapeVoidware/VW-Add/main/loader.lua",
})

Hub:Button({
    name = "ExellieX Rivals Hub",
    description = "Aimbot, ESP, Fly, Infjump",
    category = "Scripts",
    tags = { "Scripts" },
    url = "https://raw.githubusercontent.com/ZeisScripts/special-fishstick/refs/heads/main/Aimbot.lua",
})

Hub:Button({
	name = "Bladeball AutoParry",
	description = "Never Die in Bladeball",
	category = "Scripts",
	tags = { "Scripts" },
	url = "https://raw.githubusercontent.com/Akash1al/Blade-Ball-Updated-Script/refs/heads/main/Blade-Ball-Script",
})

Hub:Button({
	name = "Moondiety",
	description = "Remote hub loader",
	category = "Scripts",
	tags = { "Hub" },
	url = "https://raw.githubusercontent.com/ZeisScripts/ExellieX/refs/heads/main/Moondiety.lua",
})

Hub:Button({
	name = "SanderXY",
	description = "Panel interface",
	category = "Scripts",
	tags = { "Panel" },
	url = "https://raw.githubusercontent.com/kigredns/testUIDK/refs/heads/main/panel.lua",
})

Hub:Button({
	name = "Mystrix Hub",
	description = "Multi-feature script hub",
	category = "Scripts",
	tags = { "Hub" },
	url = "https://raw.githubusercontent.com/ummarxfarooq/mystrix-hub/refs/heads/main/loader",
})

Hub:Button({
	name = "DEX Explorer",
	description = "Instance explorer and property editor",
	category = "Tools",
	tags = { "Dex", "Explorer" },
	url = "https://raw.githubusercontent.com/ZeisScripts/ExellieX/refs/heads/main/Dex.lua",
})

Hub:Button({
	name = "Hexagon Client",
	description = "Brookhaven feature client",
	category = "Scripts",
	tags = { "Client" },
	url = "https://raw.githubusercontent.com/nxvap/hexagon/main/brookhaven",
})

Hub:Button({
	name = "Quantum Onyx Cracked",
	description = "Quantum Onyx build",
	category = "Scripts",
	tags = { "Onyx" },
	url = "https://raw.githubusercontent.com/ZeisScripts/ExellieX/refs/heads/main/Quantum%20Onyx%20Cracked.lua",
})

Hub:Button({
	name = "Emote Player",
	description = "Play any emote on demand",
	category = "Player",
	tags = { "Emotes" },
	url = "https://raw.githubusercontent.com/ZeisScripts/ExellieX/refs/heads/main/Emote%20Player.lua",
})



local function computeScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return 1
	end
	local viewport = camera.ViewportSize
	return math.clamp(math.min(viewport.X / (WINDOW_W + 80), viewport.Y / (WINDOW_H + 80)), 0.7, 1)
end

local visible = true
local closing = false
local minimized = false


local function clampToScreen(position)
	local camera = workspace.CurrentCamera
	if not camera or not window.Parent then
		return position
	end
	local viewport = camera.ViewportSize
	local absolute = window.AbsoluteSize
	local halfW = absolute.X * 0.5
	local halfH = absolute.Y * 0.5
	local margin = 4
	local minX = margin + halfW
	local maxX = viewport.X - margin - halfW
	local minY = margin + halfH
	local maxY = viewport.Y - margin - halfH
	if maxX < minX then
		minX, maxX = viewport.X * 0.5, viewport.X * 0.5
	end
	if maxY < minY then
		minY, maxY = viewport.Y * 0.5, viewport.Y * 0.5
	end
	local centreX = position.X.Scale * viewport.X + position.X.Offset
	local centreY = position.Y.Scale * viewport.Y + position.Y.Offset
	centreX = math.clamp(centreX, minX, maxX)
	centreY = math.clamp(centreY, minY, maxY)
	return UDim2.fromOffset(centreX, centreY)
end

local function applyPosition(position)
	local clamped = clampToScreen(position)
	window.Position = clamped
	shadow.Position = clamped
end

local function enforceBlur()
	if closing or not visible then
		return
	end
	if not loaderBlur then
		return
	end
	
	local target = minimized and 0 or 14
	if not loaderBlur.Parent then
		
		loaderBlur = create("BlurEffect", { Name = "ExellieXBlur", Size = target }, Lighting)
		return
	end
	if math.abs(loaderBlur.Size - target) > 0.5 then
		loaderBlur.Size = target
	end
end

local function setVisible(state)
	visible = state
	if state then
		window.Visible = true
		shadow.Visible = true
		applyPosition(window.Position)
		TweenService:Create(windowScale, TweenInfo.new(0.22, Enum.EasingStyle.Quint), { Scale = computeScale() }):Play()
		TweenService:Create(shadow, TweenInfo.new(0.22), { ImageTransparency = 0.35 }):Play()
		TweenService:Create(loaderBlur, TweenInfo.new(0.25), { Size = minimized and 0 or 14 }):Play()
	else
		themePanel.Visible = false
		TweenService:Create(windowScale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = computeScale() * 0.94 }):Play()
		TweenService:Create(shadow, TweenInfo.new(0.18), { ImageTransparency = 1 }):Play()
		TweenService:Create(loaderBlur, TweenInfo.new(0.18), { Size = 0 }):Play()
		task.delay(0.18, function()
			if not visible and not closing then
				window.Visible = false
				shadow.Visible = false
			end
		end)
	end
end

local function unload()
	if closing then
		return
	end
	closing = true
	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	connections = {}
	TweenService:Create(windowScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Scale = computeScale() * 0.92 }):Play()
	TweenService:Create(shadow, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
	TweenService:Create(loaderBlur, TweenInfo.new(0.2), { Size = 0 }):Play()
	task.delay(0.22, function()
		pcall(function()
			hubGui:Destroy()
		end)
		pcall(function()
			loaderGui:Destroy()
		end)
		pcall(function()
			loaderBlur:Destroy()
		end)
		pushLog("info", "hub unloaded")
	end)
end

function Hub:Unload()
	unload()
end

local function setMinimized(state)
	minimized = state
	minimizeButton.Text = state and "+" or "-"
	if state then
		themePanel.Visible = false
		content.Visible = false
		rail.Visible = false
		statusBar.Visible = false
		TweenService:Create(window, TweenInfo.new(0.26, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(WINDOW_W, 58),
		}):Play()
		TweenService:Create(shadow, TweenInfo.new(0.26, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(WINDOW_W + 60, 118),
		}):Play()
	else
		TweenService:Create(window, TweenInfo.new(0.26, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
		}):Play()
		TweenService:Create(shadow, TweenInfo.new(0.26, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(WINDOW_W + 60, WINDOW_H + 56),
		}):Play()
		task.delay(0.12, function()
			if not minimized then
				content.Visible = true
				rail.Visible = true
				statusBar.Visible = true
			end
		end)
	end
	
	if loaderBlur and loaderBlur.Parent then
		loaderBlur.Size = state and 0 or 14
	end
	enforceBlur()
	task.delay(0.3, function()
		if closing then
			return
		end
		enforceBlur()
		applyPosition(window.Position)
	end)
end

minimizeButton.Activated:Connect(function()
	setMinimized(not minimized)
end)
-- Close hides the hub instead of destroying it, so Right Control (or the
-- notification) can bring it straight back. Use Hub:Unload() to remove it.
closeButton.Activated:Connect(function()
	if closing then
		return
	end
	if minimized then
		setMinimized(false)
	end
	setVisible(false)
	pushLog("info", "hub hidden - press Right Control to reopen")
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "ExellieX ScriptHub",
			Text = "Hidden - press Right Control to reopen",
			Duration = 4,
		})
	end)
end)

local dragging = false
local dragStart
local dragOrigin = window.Position
local dragTarget = window.Position

local function canDragFrom(position)
	local relative = position.X - topBar.AbsolutePosition.X
	return relative < topBar.AbsoluteSize.X - 130
end

track(topBar.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if not canDragFrom(input.Position) then
		return
	end
	dragging = true
	dragStart = input.Position
	dragOrigin = window.Position
	dragTarget = dragOrigin
	track(input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End and dragging then
			-- Release can land right after the final move; snap so the window
			-- never stops short of where it was dropped.
			dragging = false
			applyPosition(dragTarget)
		end
	end))
end))

track(UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local delta = input.Position - dragStart
	dragTarget = clampToScreen(UDim2.new(
		dragOrigin.X.Scale,
		dragOrigin.X.Offset + delta.X,
		dragOrigin.Y.Scale,
		dragOrigin.Y.Offset + delta.Y
	))
end))

track(RunService.RenderStepped:Connect(function()
	if not window.Parent or not window.Visible then
		return
	end
	if dragging then
		applyPosition(window.Position:Lerp(dragTarget, 0.45))
		return
	end
	
	local clamped = clampToScreen(window.Position)
	if clamped ~= window.Position then
		applyPosition(clamped)
	end
end))

track(UserInputService.InputBegan:Connect(function(input, processed)
	-- The toggle is handled before the "processed" guard so it still works
	-- while the search box has focus or a game GUI is eating the key.
	if input.KeyCode == Enum.KeyCode.RightControl then
		if closing then
			return
		end
		setVisible(not visible)
		return
	end
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Slash and visible and not UserInputService:GetFocusedTextBox() then
		searchBox:CaptureFocus()
	end
end))

local viewportCamera = workspace.CurrentCamera
if viewportCamera then
	track(viewportCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		windowScale.Scale = computeScale()
		applyPosition(window.Position)
		task.delay(0.1, function()
			if not closing then
				applyPosition(window.Position)
			end
		end)
	end))
end


task.spawn(function()
	while not closing and hubGui.Parent do
		pcall(enforceBlur)
		task.wait(0.5)
	end
end)



loaderStep("input layer", 94)

refreshRail()
refreshList()
applyTheme("Classic")

loaderStep("final checks", 100)
task.wait(0.7)


local revealed = false
reveal = function()
	if revealed then
		return
	end
	revealed = true
	bootComplete = true
	local ok, err = pcall(function()
		local fit = computeScale()
		window.Visible = true
		shadow.Visible = true
		windowScale.Scale = fit
		shadow.ImageTransparency = 0.35
		TweenService:Create(windowScale, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { Scale = fit }):Play()
		TweenService:Create(shadow, TweenInfo.new(0.5), { ImageTransparency = 0.35 }):Play()
		TweenService:Create(loaderBlur, TweenInfo.new(0.45), { Size = 14 }):Play()
	end)
	if not ok then
		pushLog("error", "reveal: " .. describe(err))
	end
	if skipRequested then
		-- Skipping must feel instant: kill the overlay now, no fade queue.
		pcall(function()
			if loaderGui then
				loaderGui:Destroy()
			end
		end)
		return
	end
	local fadeOk, fadeErr = pcall(fadeLoader)
	if not fadeOk then
		pushLog("error", "fadeLoader: " .. describe(fadeErr))
	end
	task.delay(1.2, function()
		pcall(function()
			if loaderGui.Parent then
				loaderGui:Destroy()
			end
		end)
		pcall(function()
			if not window.Visible then
				window.Visible = true
				shadow.Visible = true
			end
		end)
	end)
end

local bootOk, bootErr = pcall(function()
	refreshRail()
	refreshList()
	applyTheme("Classic")
end)
if not bootOk then
	pushLog("error", "boot: " .. describe(bootErr))
end

reveal()
task.delay(3, function()
	if not revealed then
		reveal()
	end
end)

pushLog("info", string.format(
	"ExellieX ScriptHub %s online | %d utilities | %s | palette %s | %s",
	Hub.Version,
	#registry,
	RakNet and "raknet" or "standard",
	activeThemeId,
	OWNER_MODE and "owner session" or "key session"
))

pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "ExellieX ScriptHub",
		Text = "Loaded " .. #registry .. " utilities",
		Duration = 4,
	})
end)

return Hub
