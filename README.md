# WinSDK

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

WinSDK is a Windows SDK manager that allows you to install, manage, and switch between multiple versions of development tools seamlessly. Starting with support for Java, WinSDK is designed to be easily extendable to manage other SDKs like Gradle, Maven, Git Bash, Node.js, and more in the future.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
    - [Install an SDK](#install-an-sdk)
    - [Switch SDK Version](#switch-sdk-version)
    - [List Installed SDK Versions](#list-installed-sdk-versions)
    - [Uninstall an SDK](#uninstall-an-sdk)
- [Supported SDKs](#supported-sdks)
- [Extending WinSDK](#extending-winsdk)
- [Contributing](#contributing)
- [License](#license)
- [Authors](#authors)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)
- [Disclaimer](#disclaimer)
- [Notes](#notes)

---

## Features

- **Install Multiple SDK Versions**: Easily install different versions of supported SDKs.
- **Switch Between Versions**: Switch the active version of an SDK with a simple command.
- **Manage Environment Variables**: Automatically updates `JAVA_HOME` and `Path` variables.
- **System-Wide Installation**: Installs SDKs globally, making them available to all users.
- **Extensible Architecture**: Designed to support additional SDKs in the future.

---

## Prerequisites

- **Operating System**: Windows 10 or later.
- **PowerShell**: Version 5.1 or later (included by default on Windows 10).
- **Administrative Privileges**: Required for installation and actions that modify system environment variables.

---

## Installation

### Step 1: Open PowerShell as Administrator

- Click on the **Start** menu.
- Type `PowerShell`.
- Right-click on **Windows PowerShell** and select **Run as administrator**.

### Step 2: Run the Installer Script

Execute the following command to install WinSDK:

```bash
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/u-verma/winsdk/refs/heads/main/install.ps1'))
```

### Step 3: Restart Your Command Prompt or PowerShell

After installation, close and reopen your command prompt or PowerShell to apply the PATH changes.

---

### Usage

- WinSDK provides a simple command-line interface. The general syntax is:

```bash
winsdk <action> <sdk> [version]
```

- `<action>`: `install`, `use`, `list`, or `uninstall`.

- `<sdk>`: The name of the SDK (e.g., `java`).

- `[version]`: The version of the SDK to manage (required for `install`, `use`, and `uninstall`).


### Install an SDK  

- To install a specific version of an SDK:

```bash
winsdk install java 17
```
- Installs Java version 17.

### Switch SDK Version
- To switch to a specific version of an SDK:

```bash
winsdk use java 17
```
- Sets Java version 17 as the active version.
- Updates `JAVA_HOME` and `Path` environment variables.
- `<Note>`: The specified version must be installed.

### List Installed SDK Versions
- To list all installed versions of an SDK:

```bash
winsdk list java
```
- Displays all installed Java versions.

### Uninstall an SDK
- To uninstall a specific version of an SDK:

```bash
winsdk uninstall java 17
```
- Uninstalls Java version 17.
- If the version is currently in use, prompts to switch to another installed version.

---

### Supported SDKs
Currently, WinSDK supports the following SDKs:

- Java 
  - Install multiple versions of Java (e.g., 8, 11, 17).
  - Switch between installed Java versions.
  - Automatically manages JAVA_HOME and Path.
  - Note: Support for additional SDKs like Gradle, Maven, Git Bash, and Node.js will be added in future releases.

---

### Extending WinSDK
WinSDK is designed with extensibility in mind. Developers can add support for new SDKs by following these steps:

#### 1. Create a New Module Directory
   
- For example, to add support for Node.js:


```bash
modules/
├── NodeJS/
    ├── Install-NodeJS.psm1
    ├── Switch-NodeJS.psm1
    ├── List-NodeJS.psm1
    └── Uninstall-NodeJS.psm1
```
#### 2. Implement Functions

- Write functions for installing, switching, listing, and uninstalling the SDK.
- Follow the structure and conventions used in existing modules.
#### 3. Update the Main Script

- Modify winsdk.ps1 to include the new SDK.
- Import the new modules and update the command parsing logic.

#### 4. Test Your Changes

- Ensure that all commands work as expected.
- Verify that environment variables are managed correctly.

### Contributing
Contributions are welcome! If you'd like to contribute to WinSDK, please follow these steps:

#### 1. Fork the Repository

Click the Fork button on the top-right corner of the repository page.

#### 2. Clone Your Fork

```bash
git clone https://github.com/u-verma/winsdk.git
```
#### 3. Create a New Branch

```bash
git checkout -b feature/new-sdk-support
```

#### 4. Make Your Changes
- Add new features or fix bugs.
- Follow the coding conventions used in the project.

#### 5. Commit and Push

```bash
git commit -am "Add support for new SDK"

git push origin feature/new-sdk-support
```
#### 6. Create a Pull Request

- Go to your forked repository on GitHub.
- Click on Compare & pull request.
- Provide a descriptive title and description for your PR.

#### Please ensure that your contributions adhere to the following guidelines:

- Write clean, modular code with comments.
- Update documentation and examples as needed.
- Test your changes thoroughly.

---

### License
WinSDK is licensed under the  Apache 2.0 License. You are free to use, modify, and distribute this software as per the terms of the license.

### Authors
- Umesh Verma
  - GitHub: u-verma

---

### Contact
  If you have any questions, suggestions, or issues, please feel free to:

- Open an issue on GitHub Issues.

### Acknowledgments
- Adoptium: For providing the API and resources to download Java binaries.
- Community Contributors: Thanks to everyone who has contributed to the development and improvement of WinSDK.

---

### Disclaimer
This project is provided "as is" without warranty of any kind. Use at your own risk.

### Notes
- Security Considerations: Always verify scripts and commands before execution, especially when running with administrative privileges.
- Execution Policy: The installer script uses -ExecutionPolicy Bypass to allow script execution. You can set your PowerShell execution policy to a more restrictive setting if desired.