import ora from "ora";
import color from 'colors';
import { spawn } from 'child_process';
import inquirer from "./inquirer.js";

let vmAdminPassword = '';

// define a function to confirm the Azure subscription
async function confirmAzureSub() {
    const answers = await inquirer.askConfirm();
    if (answers.confirm) {
        //console.log('The deployment will goahead'.green);
    } else {
        console.log('The deployment has been cancelled!'.red);
        process.exit(1);
    }
}


// define a function to check the user has logged in to the Azure CLI
function azureChk() {
    const loading = ora({
        text: 'Checking Azure Connection...\n',
        color: 'green',
    });
    loading.start();

    const child = spawn('powershell', ['az account show']);
    child.stdout.on('data', (data) => {
        console.log(`Powershell Data:\n ${data}`);
    });
    child.stderr.on('data', (data) => {
        loading.fail(`Powershell Error:\n ${data}`);
        process.exit(1);
    });
    child.on('close', async () => {
        loading.succeed(`Azure Connection is Ok`);

        if (vmAdminPassword) {
            azureResourceGroups();
        }
        else {
            await confirmAzureSub();
            let vmpass = await inquirer.askQuestions();
            vmAdminPassword = vmpass.password;
            azureResourceGroups();
        }
    });
}

// define a function to deploy the Azure resource groups
function azureResourceGroups() {
    const loading = ora({
        text: 'Deploying Resource Groups..\n',
        color: 'green',
    });
    loading.start();

    const child = spawn('powershell', ['az deployment sub create --location uksouth --template-file landing-zone\\resource-groups.bicep']);
    child.stderr.on('data', (data) => {
        loading.fail(`Powershell Error:\n ${data}`);
        process.exit(1);
    });
    child.on('close', () => {
        loading.succeed(`Resource Group Deployment Finished`);
        azureNetwork()
    });
}

// define a function to deploy the Azure networks
function azureNetwork() {
    const loading = ora({
        text: 'Deploying Networks..\n',
        color: 'green',
    });
    loading.start();

    const child = spawn('powershell', ['az deployment sub create --location uksouth --template-file landing-zone\\networks.bicep']);
    child.stderr.on('data', (data) => {
        loading.fail(`Powershell Error:\n ${data}`);
        process.exit(1);
    });
    child.on('close', () => {
        loading.succeed(`Network Deployment Finished`);
        azureCore()
    });
}

// define a function to deploy the Azure core resources
function azureCore() {
    const loading = ora({
        text: 'Deploying Core..\n',
        color: 'green',
    });
    loading.start();

    const child = spawn('powershell', [`az deployment sub create --location uksouth --template-file landing-zone\\core.bicep -p vmAdminPassword=${vmAdminPassword}`]);
    child.stderr.on('data', (data) => {
        loading.fail(`Powershell Error:\n ${data}`);
        process.exit(1);
    });
    child.on('close', () => {
        loading.succeed(`Core Deployment Finished`);
        process.exit(1);
    });
}

azureChk();

