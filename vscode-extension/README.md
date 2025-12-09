# IRIS OAS Test Gen

[![VSCode Marketplace](https://img.shields.io/visual-studio-marketplace/v/3musketeers-br.iris-oas-test-generator?style=flat&label=VSCode+Marketplace&logo=visual-studio-code)](https://marketplace.visualstudio.com/items?itemName=3musketeers-br.iris-oas-test-generator)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**IRIS OAS Test Gen** is a Visual Studio Code extension designed to accelerate the development of REST API tests in **InterSystems IRIS**.

It detects **OpenAPI (Swagger)** files in your editor and allows you to generate robust ObjectScript unit test classes with a single click. The extension handles the file upload to your IRIS server, triggers the generation logic, and reports the status back to VSCode.

---

## ✨ Features

* **Context-Aware:** Automatically detects if the active file is an OpenAPI/Swagger JSON specification (`"openapi": "3.x"` or `"swagger": "2.x"`).
* **One-Click Generation:** Adds a convenient "Cloud Upload" button `$(cloud-upload)` to the editor title bar.
* **Seamless Integration:** Uploads the JSON spec directly to the IRIS server (Base64 encoded), eliminating the need for manual file transfers or volume mapping complexities.
* **Immediate Feedback:** Displays success or error notifications directly in VSCode.

---

## ⚙️ Extension Settings

This extension contributes the following settings to your VSCode configuration (`settings.json`):

| Setting | Default | Description |
| :--- | :--- | :--- |
| `irisOasGenerator.url` | `http://localhost:52773/api/oas-gen/generate-upload` | The full URL to the REST service on your IRIS instance. |
| `irisOasGenerator.auth.username` | `_SYSTEM` | The username for Basic Authentication on IRIS. |
| `irisOasGenerator.auth.password` | `SYS` | The password for Basic Authentication on IRIS. |
| `irisOasGenerator.remoteTempDir` | `/tmp/iris-gen-temp` | **Server-side** path where the uploaded JSON will be temporarily saved. |
| `irisOasGenerator.remoteOutputDir` | `/tmp/output` | **Server-side** path where the ObjectScript test classes will be generated. |

---

## 🛠️ Prerequisites (Backend Setup)

⚠️ **Important:** This extension requires a backend service running on your InterSystems IRIS instance to process the files.

### 1. Install the Backend Classes
You need the generator logic installed on your IRIS instance. You can clone the repository and use Docker, or install the classes manually.

**Repository:** [https://github.com/musketeers-br/iris-oas-test-gen](https://github.com/musketeers-br/iris-oas-test-gen)

If installing manually, ensure you have the following classes compiled:
1.  `dc.musketeers.irisOasTestGen.Main` (The generator logic)
2.  `dc.musketeers.irisOasTestGen.Service` (The REST API wrapper)

### 2. Configure the Web Application
You must configure a Web Application in the IRIS Management Portal to expose the functionality:

1.  Go to **System Administration > Security > Applications > Web Applications**.
2.  Create a new application (e.g., `/api/oas-gen`).
3.  **Namespace:** Select the namespace where the classes are installed.
4.  **Dispatch Class:** Set to `dc.musketeers.irisOasTestGen.Service`.
5.  **Security:** Enable "Password" (Basic Auth).

---

## 🚀 How to Use

1.  **Open an OpenAPI File:** Open any `.json` file that contains an OpenAPI or Swagger specification in VSCode.
2.  **Check the Icon:** Look at the top-right corner of the editor (Title Bar). You should see a **Cloud Upload** icon `$(cloud-upload)`.
    * *Note: The icon only appears if the file is recognized as an OpenAPI spec.*
3.  **Generate:** Click the icon.
    * The extension will convert the file content to Base64.
    * It sends the payload to the configured IRIS URL.
    * IRIS processes the file and generates the test classes in the configured `remoteOutputDir`.
4.  **Result:** You will see a notification: `✅ Gerado com sucesso em /tmp/output`.

---

## 🔧 Troubleshooting

* **Icon not appearing?**
    Ensure the file is a valid JSON and contains `"openapi": "..."` or `"swagger": "..."` at the root level.
* **"Connection Refused" or 404 Error:**
    Check if the `irisOasGenerator.url` setting matches your IRIS Web Application configuration and port.
* **"Error Backend":**
    If the server responds with an error, ensure the `remoteTempDir` and `remoteOutputDir` paths exist on the server (or the container) and that the IRIS user (usually `irisowner`) has write permissions.

---

## 👥 Credits

Developed with ❤️ by the **Musketeers Team**:

* [José Roberto Pereira](https://community.intersystems.com/user/jos%C3%A9-roberto-pereira-0)
* [Henry Pereira](https://community.intersystems.com/user/henry-pereira)
* [Henrique Dias](https://community.intersystems.com/user/henrique-dias-2)

![3Musketeers-br](./assets/3musketeers.png)
**Repository:** [GitHub](https://github.com/musketeers-br/iris-oas-test-gen)