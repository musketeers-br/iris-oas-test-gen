import * as vscode from 'vscode';
import axios from 'axios';

export function activate(context: vscode.ExtensionContext) {

    context.subscriptions.push(
        vscode.window.onDidChangeActiveTextEditor(updateContext),
        vscode.workspace.onDidChangeTextDocument(e => {
            if (vscode.window.activeTextEditor && e.document === vscode.window.activeTextEditor.document) {
                updateContext();
            }
        })
    );

    updateContext();

    let command = vscode.commands.registerCommand('iris-oas-generator.uploadAndGen', async () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const config = vscode.workspace.getConfiguration('irisOasGenerator');
        const url = config.get<string>('url');
        const remoteTempDir = config.get<string>('remoteTempDir');
        const outputDir = config.get<string>('remoteOutputDir');
        const username = config.get<string>('auth.username');
        const password = config.get<string>('auth.password');

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
        }, async () => {
            try {
                const response = await axios.post(url, {
                    base64: base64Content,
                    remoteTempDir: remoteTempDir,
                    outputDir: outputDir
                }, {
                    auth: { username: username || '', password: password || '' }
                });

                if (response.data.status === 'success') {
                    vscode.window.showInformationMessage(`✅ ${response.data.message}`);
                } else {
                    vscode.window.showErrorMessage(`❌ Erro Backend: ${response.data.message}`);
                }
            } catch (err: any) {
                vscode.window.showErrorMessage(`❌ Erro de Conexão: ${err.message}`);
            }
        });
    });

    context.subscriptions.push(command);
}

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
            } catch (e) {
                // invalid JSON 
                // TODO: What we could do?
            }
        }
    }

    vscode.commands.executeCommand('setContext', 'irisOasGenerator:isOpenApi', isOas);
}

export function deactivate() { }