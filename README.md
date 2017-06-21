# light-installer
A light installer for High Fidelity VR. Built using NSIS.

## Installer Compilation Requirements
- [NSIS 3.01](http://nsis.sourceforge.net/Download)
- [NSIS NsProcess Plugin](http://nsis.sourceforge.net/NsProcess_plugin)
- [NSIS ThreadTimer Plugin](http://nsis.sourceforge.net/ThreadTimer_plug-in)

## Current "High Fidelity Express" Installer Flow
_This section of the README is current as of **2017-06-21 11:00 AM**. It'll be updated as the installer logic matures._

When a user runs `High_Fidelity_Express.exe`, the following behavior occurs:
1. We **ask for administrator permissions** so that it can perform various operations (like reading from the registry and creating files).
2. We **verify that the "correct" version of High Fidelity Interface is installed** on the user's computer.
  1. We read from the registry at `HKEY_CLASSES_ROOT\hifi\DefaultIcon` to **determine the path of `interface.exe`** that the user installed most recently
        - _(FYI: `HKCR\<protocol>\shell\open\command\(Default)` is where the registry keys go that determine what to do when you click on, say, a `hifi://` or `itunes://` link)_
    2. **If Interface _is found_** at that path:
        1. We **check if Interface or Sandbox is running**, and **kill those processes** if they are
        2. We run that **`interface.exe` with the `--version`** command-line switch
        3. **If the version matches** the valid version number hard-coded into the installer:
            1. We move on to the steps below...
        4. If the **version does not match**:
            1. If we determine that the `interface.exe` **_does come_ from Steam**:
                1. We **alert the user** that Interface is out of date and will be updated the next time it runs from Steam
            2. If we determine that `interface.exe` **_does not_ come from Steam**:
                1. We will **download** the correct version of the High Fidelity installer. See _"If Interface _is not found_ at that path:_ below.
    3. **If Interface _is not found_** at that path:
        1. We will **start downloading the correct version** of the High Fidelity installer to the user's `TEMP` directory. The installer will display download status.
        2. Once the download is complete, we will **run the full High Fidelity Interface installe**. As of right now, the user has to go through the install process manually.
        3. Once the full High Fidelity Interface installer completes, we will jump back to step (2) above; **the light installer will verify** that the correct version of Interface is installed on the system.
3. We **verify that the user has the "correct" custom content** cached on their hard drive. Right now, this is a "dummy" step, and does nothing.
    1. If the user **_does have_ the "correct" custom content** cached on their hard drive:
        1. We continue to the next step.
    2. If the user **_does not have_ the "correct" custom content** cached on their hard drive:
        1. We will **download the correct set of custom content** from the High Fidelity website and place it in the proper directory.
4. We, again, read from the registry at `HKEY_CLASSES_ROOT\hifi\DefaultIcon` to determine the path of `interface.exe`, then **run `interface.exe` using the following command: `interface.exe --url hifi://zaru`**
    - Now that the user has gotten this far in the installer, the path to `interface.exe` _should be_ either the one installed by the installer in the steps above, OR the path the installer verified to be up-to-date enough for the event.

## Cumulative Test Plan

Reference the Initial States below when performing these tests.

### Initial States
#### Initial State A - Completely Clean Slate
- There exists no "High Fidelity" entires in Windows' "Add or Remove Programs" list.
- There exists no folders related to "High Fidelity" in `%AppData%` (i.e. `C:\Users\<Username>\AppData\Roaming`)
- There exists no folders related to "High Fidelity" in `%LocalAppData%` (i.e. `C:\Users\<Username>\AppData\Local`)
- The registry key `HKEY_CLASSES_ROOT\hifi` doesn't exist

#### Initial State B - Old Interface Installed
- Install the latest version of High Fidelity from https://highfidelity.com/download
- Ensure that version of High Fidelity is **not running**

#### Initial State C - Old Interface Running
- Install the latest version of High Fidelity from https://highfidelity.com/download
- Run Sandbox and Interface

#### Initial State D - Correct Interface Installed
- Install the version of High Fidelity from [here](https://deployment.highfidelity.com/jobs/pr-build/label%3Dwindows/934/HighFidelity-Beta-PR10758-fea8a95fc7ab9f8e4c09313f5d72b167d928bcd9.exe).
- Ensure that neither Sandbox nor Interface are running

#### Initial State E - Correct Interface Running
- Install the version of High Fidelity from [here](https://deployment.highfidelity.com/jobs/pr-build/label%3Dwindows/934/HighFidelity-Beta-PR10758-fea8a95fc7ab9f8e4c09313f5d72b167d928bcd9.exe).
- Run that version of Interface
- Ensure your Sandbox isn't running

### Tests
<table>
    <tbody>
        <tr>
            <th>#</th>
            <th>Initial State</th>
            <th>Test Procedure</th>
        </tr>
            <tr>
            <td>1</td>
            <td>State A</td>
            <td>
                <ol>
                    <li>Run `High_Fidelity_Express.exe`</li>
                    <li>The High Fidelity Express Installer window appears</li>
                    <li>The installer starts downloading a file.</li>
                    <li>When the download finishes, the normal High Fidelity installer opens.<br><i>The following steps are necessary for now, but won't be necessary once the `/silent` option is implemented in the installer:</i><br>Go through the normal installer, making sure to install only Interface (not Sandbox) and unchecking the option to run Interface after installation.</li>
                    <li>A few seconds after the normal installer completes, Interface opens. You are in Zaru. You weren't forced into the tutorial.</li>
                </ol>
            </td>
        </tr>
        </tr>
            <tr>
            <td>2</td>
            <td>State A</td>
            <td>
                <ol>
                    <li>Run `High_Fidelity_Express.exe`</li>
                    <li>The High Fidelity Express Installer window appears</li>
                    <li>The installer starts downloading a file. Cancel the download.</li>
                    <li>The installer quits. No changes have been made to your system.</li>
                </ol>
            </td>
        </tr>
        </tr>
            <tr>
            <td>3</td>
            <td>State B</td>
            <td>
                <ol>
                    <li>Run `High_Fidelity_Express.exe`</li>
                    <li>The High Fidelity Express Installer window appears. You may briefly see an Interface window appear, then disappear.</li>
                    <li>The installer starts downloading a file.</li>
                    <li>When the download finishes, the normal High Fidelity installer opens.<br><i>The following steps are necessary for now, but won't be necessary once the `/silent` option is implemented in the installer:</i><br>Go through the normal installer, making sure to install only Interface (not Sandbox) and unchecking the option to run Interface after installation.</li>
                    <li>A few seconds after the normal installer completes, Interface opens. You are in Zaru. You weren't forced into the tutorial.</li>
                </ol>
            </td>
        </tr>
        </tr>
            <tr>
            <td>4</td>
            <td>State C</td>
            <td>
                <ol>
                    <li>Run `High_Fidelity_Express.exe`</li>
                    <li>The High Fidelity Express Installer window appears.</li>
                    <li>A popup appears, notifying you that the installation cannot continue while Interface is running.</li>
                    <li>Press "Retry". Interface automatically closes.</li>
                    <li>A couple more popups appear, notifying you that the installation cannot continue while some other components are running. Press "Retry". The other components automatically close.</li>
                    <li>The installer starts downloading a file.</li>
                    <li>When the download finishes, the normal High Fidelity installer opens.<br><i>The following steps are necessary for now, but won't be necessary once the `/silent` option is implemented in the installer:</i><br>Go through the normal installer, making sure to install only Interface (not Sandbox) and unchecking the option to run Interface after installation.</li>
                    <li>A few seconds after the normal installer completes, Interface opens. You are in Zaru. You weren't forced into the tutorial.</li>
                </ol>
            </td>
        </tr>
        </tr>
            <tr>
            <td>5</td>
            <td>State D</td>
            <td>
                <ol>
                    <li>Run `High_Fidelity_Express.exe`</li>
                    <li>The High Fidelity Express Installer window appears.</li>
                    <li>A few seconds later, Interface opens and the Express installer window disappears.</li>
                    <li>You are in Zaru. You weren't forced into the tutorial.</li>
                </ol>
            </td>
        </tr>
        </tr>
            <tr>
            <td>6</td>
            <td>State E</td>
            <td>
                <ol>
                    <li>Run `High_Fidelity_Express.exe`</li>
                    <li>The High Fidelity Express Installer window appears.</li>
                    <li>A popup appears, notifying you that the installation cannot continue while Interface is running.</li>
                    <li>Press "Retry". Interface automatically closes.</li>
                    <li>A few seconds later, Interface opens and the Express installer window disappears.</li>
                    <li>You are in Zaru. You weren't forced into the tutorial.</li>
                </ol>
            </td>
        </tr>
    </tbody>
</table>
