# light-installer
A light installer for High Fidelity VR. Built using NSIS.

## Installer Compilation Requirements
- [NSIS 3.01](http://nsis.sourceforge.net/Download)
- [NSIS NsProcess Plugin](http://nsis.sourceforge.net/NsProcess_plugin)
- [NSIS ThreadTimer Plugin](http://nsis.sourceforge.net/ThreadTimer_plug-in)
- [NSIS Nsisunz Plugin](http://nsis.sourceforge.net/Nsisunz_plug-in)
- [NSIS Inetc Plugin](http://nsis.sourceforge.net/Inetc_plug-in)

## Current "High Fidelity Express" Installer Flow
_This section of the README is current as of **2017-06-26 1:30 PM PDT**. It'll be updated as the installer logic matures._

When a user runs `High Fidelity Jaws Event.exe`, the following behavior occurs:
1. We **ask for administrator permissions** so that it can perform various operations (like reading from the registry and creating files).
2. We **copy the Jaws Event installer EXE file to `%AppData%\High Fidelity\Jaws\High Fidelity Jaws Event.exe`, then create shortcuts to that file on the desktop and in the Start menu.
3. We **verify that the "correct" version of High Fidelity Interface is installed** on the user's computer.
    1. We read from the registry at `HKEY_CLASSES_ROOT\hifi\DefaultIcon` to **determine the path of `interface.exe`** that the user installed most recently
        - _(FYI: `HKCR\<protocol>\shell\open\command\(Default)` is where the registry keys go that determine what to do when you click on, say, a `hifi://` or `itunes://` link)_
    2. **If Interface _is found_** at that path:
        1. We **check if Interface or Sandbox is running**, and **kill those processes** if they are
        2. We run that **`interface.exe` with the `--protocolVersion`** command-line switch
        3. **If the version matches** the valid version number hard-coded into the installer (currently dev-download / master):
            1. We set the `$MustInstallHiFi` flag to `false` and move on to the steps below...
        4. If the **version does not match**:
            1. If we determine that the `interface.exe` **_does come_ from Steam**:
                1. We **alert the user** that Interface is out of date. We tell them to update High Fidelity through Steam, then press "Retry" in the installer to continue.
                2. If the user presses "Retry", we **go back to the top-level verification step** above.
            2. If we determine that `interface.exe` **_does not_ come from Steam**:
                1. We set the `$MustInstallHiFi` flag to `true` and move on to the steps below...
4. We **verify that the user has the "correct" custom content** cached on their hard drive.
    1. If the user **_does have_ the "correct" custom content** cached on their hard drive:
        1. We continue to the next step.
    2. If the user **_does not have_ the "correct" custom content** cached on their hard drive:
        1. We will **download the correct set of custom content** from the High Fidelity website and place it in the proper directory.
5. **If the `$MustInstallHiFi` flag is set to `true`**:
    1. We will **start downloading the correct version** of the High Fidelity installer to the user's `TEMP` directory. The installer will display download status.
    2. Once the download is complete, we will **silently run the full High Fidelity Interface installer** while displaying some messaging to the user.
       1. No questions are asked of the user. The values from previous installations are used, if any (for installing sandbox, creating start menus, etc.). However,
       2. If there is no previous installation, we do not install Sandbox. (If there was a previous installation that specifically included Sandbox, we do update it.)
       3. Regardless of whatever was done before, we do **not run Interface or Sandbox at the end of this step**.
    3. Once the full High Fidelity Interface installer completes, **the light installer will re-verify** that the correct version of Interface is installed on the system.
        1. If, at this point, the correct version of Interface is not installed, the light installer will fail and instruct the user to restart the light installer.
        2. If the correct version of Interface _is_ installed, we continue.
6. We, again determine the (possibly new) path of `interface.exe`, then **run `interface.exe` using the following command: `interface.exe --url hifi://dev-playa/event --suppress-settings-reset --skipTutorial --cache <content_set_dir> --scripts <content_set_dir>\scripts`**.
    - _The cache part doesn't work yet, so we're not yet getting that acceleration. But that's Interface issue, not a micro-installer issue._
    - Now that the user has gotten this far in the installer, the path to `interface.exe` _should be_ either the one installed by the installer in the steps above, OR the path the installer verified to be up-to-date enough for the event.

## Cumulative Test Plan
Please see [TESTS.md](TESTS.md) for a cumulative test plan of the High Fidelity Express installer.
