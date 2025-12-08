"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
const vscode = require("vscode");
const axios_1 = require("axios");
function activate(context) {
    context.subscriptions.push(vscode.window.onDidChangeActiveTextEditor(updateContext), vscode.workspace.onDidChangeTextDocument(e => {
        if (vscode.window.activeTextEditor && e.document === vscode.window.activeTextEditor.document) {
            updateContext();
        }
    }));
    updateContext();
    let command = vscode.commands.registerCommand('iris-oas-generator.uploadAndGen', () => __awaiter(this, void 0, void 0, function* () {
        const editor = vscode.window.activeTextEditor;
        if (!editor)
            return;
        const config = vscode.workspace.getConfiguration('irisOasGenerator');
        const url = config.get('url');
        const remoteTempDir = config.get('remoteTempDir');
        const outputDir = config.get('remoteOutputDir');
        const username = config.get('auth.username');
        const password = config.get('auth.password');
        if (!url || !remoteTempDir || !outputDir) {
            vscode.window.showErrorMessage("Configurações incompletas (URL ou Dirs).");
            return;
        }
        const fileContent = editor.document.getText();
        const base64Content = Buffer.from(fileContent).toString('base64');
        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: "Enviando OAS para IRIS e Gerando...",
            cancellable: false
        }, () => __awaiter(this, void 0, void 0, function* () {
            try {
                const response = yield axios_1.default.post(url, {
                    base64: base64Content,
                    remoteTempDir: remoteTempDir,
                    outputDir: outputDir
                }, {
                    auth: { username: username || '', password: password || '' }
                });
                if (response.data.status === 'success') {
                    vscode.window.showInformationMessage(`✅ ${response.data.message}`);
                }
                else {
                    vscode.window.showErrorMessage(`❌ Erro Backend: ${response.data.message}`);
                }
            }
            catch (err) {
                vscode.window.showErrorMessage(`❌ Erro de Conexão: ${err.message}`);
            }
        }));
    }));
    context.subscriptions.push(command);
}
exports.activate = activate;
function updateContext() {
    const editor = vscode.window.activeTextEditor;
    let isOas = false;
    if (editor && editor.document.languageId === 'json') {
        const text = editor.document.getText();
        if (text.includes('"openapi"') || text.includes('"swagger"')) {
            try {
                const json = JSON.parse(text);
                if (json.openapi || json.swagger) {
                    isOas = true;
                }
            }
            catch (e) {
                // invalid JSON 
                // TODO: What we could do?
            }
        }
    }
    vscode.commands.executeCommand('setContext', 'irisOasGenerator:isOpenApi', isOas);
}
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map