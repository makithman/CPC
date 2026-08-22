# 🎮 <font color="#2EA44F">𝕮𝕻𝕮 𝕯𝖗𝖎𝖛𝖊 𝕾𝖚𝖎𝖙𝖊</font>

<div align="center">

<font color="#0969DA"><strong>A modular Custom Shaders Patch (CSP) Lua app for Assetto Corsa that brings drivetrain assists, dynamic camera control, and live telemetry into one unified in-game suite.</strong></font>

![Assetto Corsa](https://img.shields.io/badge/Assetto_Corsa-Supported-F39C12?style=for-the-badge)
![CSP Lua](https://img.shields.io/badge/CSP-Lua_App-00B8D9?style=for-the-badge)
![NeckFX](https://img.shields.io/badge/NeckFX-Backend-2EA44F?style=for-the-badge)
![Release](https://img.shields.io/badge/Release-3.9.2-7B2CBF?style=for-the-badge)

</div>

---

# 📸 <font color="#2EA44F">𝕲𝖆𝖑𝖑𝖊𝖗𝖞</font>

<div align="center">

## 🔵 <font color="#2EA44F">𝕸𝖊𝖓𝖚 𝕯𝖎𝖘𝖕𝖑𝖆𝖞 & 𝕯𝖞𝖓𝖆𝖒𝖎𝖈 𝕮𝖔𝖓𝖙𝖗𝖔𝖑𝖘</font>
![Menu Display Dynamic](menu%20display%20dynamic.png)

## 🟣 <font color="#2EA44F">𝕷𝖎𝖛𝖊 𝕿𝖊𝖑𝖊𝖒𝖊𝖙𝖗𝖞 𝕳𝖀𝕯</font>
![HUD Display](hud%20display.png)

</div>

---

# ✨ <font color="#2EA44F">𝕶𝖊𝖞 𝕱𝖊𝖆𝖙𝖚𝖗𝖊𝖘</font>

<table>
  <tr>
    <td width="50%">
      
## 🟢 <font color="#2EA44F">𝕬𝖉𝖆𝖕𝖙𝖎𝖛𝖊 𝕯𝖗𝖎𝖛𝖊𝖙𝖗𝖆𝖎𝖓 𝕮𝖔𝖓𝖙𝖗𝖔𝖑</font>
- <font color="#0969DA"><strong>Clutch Control - Launch assist, anti-stall, shift support, and turn awareness</strong></font>
- <font color="#0969DA"><strong>Handbrake Support - Configurable clutch kicks</strong></font>
- <font color="#0969DA"><strong>Automatic Gearing - RPM targets, per-gear tuning, and downshift protection</strong></font>
- <font color="#0969DA"><strong>NOS Control - Configurable torque and throttle requirements</strong></font>

    </td>
    <td width="50%">
      
## 🔵 <font color="#2EA44F">𝕮𝖔𝖈𝖐𝖕𝖎𝖙 & 𝕮𝖆𝖒𝖊𝖗𝖆 𝕯𝖞𝖓𝖆𝖒𝖎𝖈𝖘</font>
- <font color="#0969DA"><strong>Dynamic Cockpit Camera - Throttle, braking, speed, and cornering effects</strong></font>
- <font color="#0969DA"><strong>CSP NeckFX Integration - Six-axis DOF with movement, yaw, pitch, and roll</strong></font>
- <font color="#0969DA"><strong>Advanced Effects - Steering follow, drift dynamics, and road banking</strong></font>
- <font color="#0969DA"><strong>Live Telemetry HUD - Real-time vehicle, pedal, G-force, and RPM data</strong></font>

    </td>
  </tr>
</table>

---

# 📋 <font color="#2EA44F">𝕽𝖊𝖖𝖚𝖎𝖗𝖊𝖒𝖊𝖓𝖙𝖘</font>

- <font color="#0969DA"><strong>Assetto Corsa</strong></font>
- <font color="#0969DA"><strong>Content Manager</strong></font>
- <font color="#0969DA"><strong>Custom Shaders Patch with Lua apps and scripted cockpit-camera/NeckFX support enabled</strong></font>

---

# 🚀 <font color="#2EA44F">𝕼𝖚𝖎𝖈𝖐 𝕴𝖓𝖘𝖙𝖆𝖑𝖑𝖆𝖙𝖎𝖔𝖓</font>

> [!IMPORTANT]
> 🟠 **Install both the `apps` and `extension` folders so the in-game app and NeckFX backend can communicate.**

## <font color="#2EA44F">𝕾𝖙𝖊𝖕-𝖇𝖞-𝕾𝖙𝖊𝖕</font>

1. <font color="#0969DA"><strong>Close Assetto Corsa and Content Manager.</strong></font>
2. <font color="#0969DA"><strong>Extract `cpc_drive_suite_apps_extension/cpc_drive_suite_apps_extension/` into your Assetto Corsa installation directory.</strong></font>
3. <font color="#0969DA"><strong>Merge the `apps` and `extension` folders when prompted.</strong></font>
4. <font color="#0969DA"><strong>In Content Manager, open CSP NeckFX or scripted cockpit-camera settings.</strong></font>
5. <font color="#0969DA"><strong>Select `CPC Drive Suite - NeckFX Backend` as the cockpit-camera script.</strong></font>
6. <font color="#0969DA"><strong>Reload the session and open the CPC Drive Suite app from the in-game menu.</strong></font>
7. <font color="#0969DA"><strong>Verify that the NeckFX page reports ✅ BACKEND ONLINE.</strong></font>

## <font color="#2EA44F">𝕯𝖎𝖗𝖊𝖈𝖙𝖔𝖗𝖞 𝕾𝖙𝖗𝖚𝖈𝖙𝖚𝖗𝖊</font>

```
Assetto Corsa/
├── apps/lua/cpc_drive_suite/
│   ├── cpc_drive_suite.lua
│   ├── cpc_drive_suite_core.lua
│   ├── cpc_drive_suite_ui.lua
│   ├── cpc_drive_suite_hud.lua
│   └── CPC_DRIVE_SUITE_*.JSON
│
└── extension/lua/cockpit-camera/default/
    └── [NeckFX backend files]
```

---

# ⚙️ <font color="#2EA44F">𝕮𝖔𝖓𝖋𝖎𝖌𝖚𝖗𝖆𝖙𝖎𝖔𝖓</font>

## <font color="#2EA44F">𝕾𝖊𝖙𝖙𝖎𝖓𝖌𝖘 𝕻𝖗𝖔𝖋𝖎𝖑𝖊𝖘</font>

<div align="center">

<font color="#0969DA"><strong>All settings are stored and managed through JSON profiles.</strong></font>

</div>

| File | Purpose |
|------|---------|
| `CPC_DRIVE_SUITE_DEFAULTS.JSON` | <font color="#0969DA">📦 Shipped defaults (never modified automatically)</font> |
| `CPC_DRIVE_SUITE_SETTINGS.JSON` | <font color="#0969DA">👤 Active user profile (auto-saved on app close)</font> |

## <font color="#2EA44F">𝕼𝖚𝖎𝖈𝖐 𝕮𝖔𝖓𝖙𝖗𝖔𝖑𝖘</font>

- 🎚️ <font color="#0969DA"><strong>Right-click any slider to restore its default value.</strong></font>
- 🔄 <font color="#0969DA"><strong>System reset buttons restore individual systems.</strong></font>
- 🏁 <font color="#0969DA"><strong>Full reset restores the shipped profile.</strong></font>

## <font color="#2EA44F">𝕻𝖗𝖊𝖘𝖊𝖙 𝕺𝖕𝖙𝖎𝖔𝖓𝖘</font>

<div align="center">

<font color="#0969DA"><strong>The suite includes three pre-configured presets to get you started.</strong></font>

</div>
- 💚 <font color="#0969DA"><strong>Light - Subtle assistance and effects</strong></font>
- 💙 <font color="#0969DA"><strong>Balanced - Moderate, versatile setup</strong></font>
- 💪 <font color="#0969DA"><strong>Strong - Maximum features and responsiveness</strong></font>

---

# 🛠️ <font color="#2EA44F">𝕿𝖗𝖔𝖚𝖇𝖑𝖊𝖘𝖍𝖔𝖔𝖙𝖎𝖓𝖌</font>

> [!WARNING]
> 🔴 **A missing backend or unwritable settings file prevents the suite from saving or reporting NeckFX status correctly.**

## ❌ <font color="#2EA44F">𝕹𝖊𝖈𝖐𝕱𝖃 𝕭𝖆𝖈𝖐𝖊𝖓𝖉 𝕺𝖋𝖋𝖑𝖎𝖓𝖊</font>
```
✓ Confirm backend installed at: extension/lua/cockpit-camera/default/
✓ Select "CPC Drive Suite - NeckFX Backend" in CSP NeckFX settings
✓ Reload the current session
```

## ❌ <font color="#2EA44F">𝕾𝖊𝖙𝖙𝖎𝖓𝖌𝖘 𝕮𝖆𝖓𝖓𝖔𝖙 𝕭𝖊 𝕾𝖆𝖛𝖊𝖉</font>
```
✓ Verify app is under: Assetto Corsa/apps/lua/
✓ Ensure CPC_DRIVE_SUITE_SETTINGS.JSON is writable
✓ Do NOT install only in Windows Roaming folder
✓ Check folder permissions for the Assetto Corsa directory
```

---

# 📁 <font color="#2EA44F">𝕻𝖗𝖔𝖏𝖊𝖈𝖙 𝕾𝖙𝖗𝖚𝖈𝖙𝖚𝖗𝖊</font>

```
cpc_drive_suite_apps_extension/
└── cpc_drive_suite_apps_extension/
    ├── apps/lua/cpc_drive_suite/
    │   ├── cpc_drive_suite.lua                 # App loader
    │   ├── cpc_drive_suite_core.lua            # Module orchestrator
    │   ├── cpc_drive_suite_ui.lua              # Dashboard & UI
    │   ├── cpc_drive_suite_hud.lua             # Telemetry HUD
    │   ├── CPC_DRIVE_SUITE_DEFAULTS.JSON       # Default profile
    │   └── CPC_DRIVE_SUITE_SETTINGS.JSON       # User profile
    │
    └── extension/lua/cockpit-camera/default/   # NeckFX backend
```

---

# 🎯 <font color="#2EA44F">𝕲𝖊𝖙𝖙𝖎𝖓𝖌 𝕾𝖙𝖆𝖗𝖙𝖊𝖉</font>

> [!TIP]
> 🟢 **Start with a Light or Balanced preset, then fine-tune each system after verifying the backend is online.**

1. <font color="#0969DA"><strong>Launch Assetto Corsa.</strong></font>
2. <font color="#0969DA"><strong>Open the CPC Drive Suite app from the in-game menu.</strong></font>
3. <font color="#0969DA"><strong>Configure systems based on your driving style and car setup.</strong></font>
4. <font color="#0969DA"><strong>Try presets to find your baseline.</strong></font>
5. <font color="#0969DA"><strong>Fine-tune individual sliders for your preferences.</strong></font>
6. <font color="#0969DA"><strong>Save your profile for future sessions.</strong></font>

<div align="center">

💡 <font color="#0969DA"><strong>Tip: Manually edit JSON profiles for advanced configurations. Always maintain valid JSON syntax and preserve each setting's original data type.</strong></font>

</div>

---

# 📚 <font color="#2EA44F">𝕯𝖔𝖈𝖚𝖒𝖊𝖓𝖙𝖆𝖙𝖎𝖔𝖓</font>

<div align="center">

<font color="#0969DA"><strong>For detailed installation guidance, see the included installation tutorial.</strong></font>

</div>
- [`CPC_DRIVE_SUITE_INSTALL_TUTORIAL.txt`](cpc_drive_suite_apps_extension/cpc_drive_suite_apps_extension/apps/lua/cpc_drive_suite/CPC_DRIVE_SUITE_INSTALL_TUTORIAL.txt)

---

# 📝 <font color="#2EA44F">𝕷𝖎𝖈𝖊𝖓𝖘𝖊 & 𝕮𝖗𝖊𝖉𝖎𝖙𝖘</font>

<div align="center">

<font color="#0969DA"><strong>CPC Drive Suite - Modular CSP Lua app for Assetto Corsa</strong></font>

<font color="#0969DA"><strong>Built for: Assetto Corsa | Custom Shaders Patch | Content Manager</strong></font>

</div>

---

<div align="center">

**[Report Issue](../../issues)** • **[Discussions](../../discussions)** • **[Releases](../../releases)**

</div>
