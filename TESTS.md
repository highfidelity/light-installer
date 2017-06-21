## HiFi Light Installer - Cumulative Test Plan

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
