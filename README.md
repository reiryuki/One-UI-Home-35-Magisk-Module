# One UI Home 35 Magisk Module

## DISCLAIMER
- One UI apps and blobs are owned by Samsung™.
- The MIT license specified here is for the Magisk Module only, not for One UI apps and blobs.

## Descriptions
Home launcher app by Samsung Electronics Co., Ltd. ported and integrated as a Magisk Module for all supported and rooted devices with Magisk

## Sources
- https://apkmirror.com com.sec.android.app.launcher (target SDK 35) & com.sec.android.provider.badge by Samsung Electronics Co., Ltd.
- BadgeSettings.apk by @KaldirimMuhendisi
- libmagiskpolicy.so: Magisk (stable) 30.7 (30700)

## Changelog

v1.7
- Update libmagiskpolicy.so from Magisk (stable) 30.7 (30700)
- Fix crash

v1.6
- Re-fix a method

v1.5
- Fix wrong target in latest KernelSU
- Fix denial if executing default.sh

v1.4
- Fix a crash in foldable mode
- Re-fix some methods
- Set secondary launcher

v1.3
- Fix some methods
- Add a warning if root is not granted in KernelSU

v1.2
- Revert layout params alpha to 1
- Fix selinux denial

v1.1
- Re-fix conflict with PixelConfigOverlayCommon.apk

v1.0
- Does not use root to swipe up to home in full gesture

v0.9
- Fix crash AbstractMethodError setHandoffHandler
- Removes conflicted overlay PixelConfigOverlayCommon.apk systemlessly if oneui.recents=1

v0.8
- Android 15 QPR2 (BP1A) support

## Screenshots
https://t.me/ryukimodsscreenshots/57

## Requirements
- NOT in One UI nor Touchwiz ROM
- Android 15 (SDK 35) and up
- Magisk or Kitsune Mask or KernelSU or Apatch installed
- One UI Core Magisk Module installed https://github.com/reiryuki/One-UI-Core-Magisk-Module
- Add media page to Home screen option requires Google app installed https://play.google.com/store/apps/details?id=com.google.android.googlequicksearchbox or ported Samsung News/Free/Daily/Bixby Home app (com.samsung.android.app.spage) if it's exist.
- Full gesture navigation and double tap to sleep requires root permission

## Installation Guide & Download Link
- Remove any other else One UI Home Magisk module with different name (no need to remove if it's the same name)
- Reboot
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs or https://github.com/KernelSU-Modules-Repo/magic_mount_rs or https://github.com/KernelSU-Modules-Repo/hybrid_mount first depending on ROM compatibility
- Install One UI Core Magisk Module first: https://github.com/reiryuki/One-UI-Core-Magisk-Module
- If you want to activate the recents provider, READ Optionals bellow!
- Install this module https://devuploads.com/umue2h603uw4 via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (enable show system apps) and reboot afterwards
- Change your default home to this launcher via Settings app (or you can copy the content of default.sh and paste it to Terminal/Termux app. Type su and grant root first!)
- If you want to use Add media page to Home screen option, you need to install Google app https://play.google.com/store/apps/details?id=com.google.android.googlequicksearchbox or ported Samsung News/Free/Daily/Bixby Home app (com.samsung.android.app.spage) if it's exist.
- If you want to change some configurations, read Troubleshootings bellow!
- If you are using multi user or Work Profile, don't forget to allow "Display over other apps" manually at the App Info or you can run this terminal command instead:

`su`

`appops set com.sec.android.app.launcher SYSTEM_ALERT_WINDOW allow`

## Optionals
- https://t.me/ryukinotes/33
- Global: https://t.me/ryukinotes/35

## Troubleshootings
- https://t.me/ryukinotes/33
- Global: https://t.me/ryukinotes/34

## Known Issues
- Edge panels doesn't work
- Recents provider doesn't launch sometimes
- Recents tumbnails are blacked out in some ROMs. If your device supports vulkan, this module https://github.com/reiryuki/SKIA-UI-Renderer-Enabler-Magisk-Module may fix that.
- Does not support navbar overlay in QPR2 ROMs and up if recents provider is activated

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- @KaldirimMuhendisi
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
https://t.me/ryukinotes/25


