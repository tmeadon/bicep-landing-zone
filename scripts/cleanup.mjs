import fs from'fs';
import ora from "ora";
import color from 'colors';
import parseJson from 'parse-json';
import { spawn } from 'child_process';
import inquirer from "./inquirer.js";
const jsonFilePath = './landing-zone/config/resource-groups.json';

let json = parseJson(fs.readFileSync(jsonFilePath));
const rsgs = json.resourceGroups.reverse();

function rsgChk(rsg) {
    const loading = ora({
        text: 'Checking Resource Group...\n',
        color: 'cyan',
    });
    loading.start();

    const child = spawn('powershell', [`az group exists --name ${rsg.name} --subscription ${rsg.subscriptionId}`]);
    child.stdout.on('data', (data) => {
        console.log(`Powershell Data:\n ${data}`);
    });
    child.stderr.on('data', (data) => {
        loading.fail(`Powershell Error:\n ${data}`);
        process.exit(1);
    });
    child.on('close', async () => {
        loading.succeed(`RSG Found`);
        deleteRSG(rsg);
    });
}

function deleteRSG(rsg) {
    const loading = ora({
        text: 'Deleting Resource Group..\n',
        color: 'yellow',
    });
    loading.start();

    console.log(rsg.name + ` in Subscription `.yellow + rsg.subscriptionId);
    const child = spawn('powershell', [`az group delete --name ${rsg.name} --subscription ${rsg.subscriptionId} --yes`]);
    child.stderr.on('data', (data) => {
        loading.fail(`Powershell Error:\n ${data}`);
        process.exit(1);
    });
    child.on('close', () => {
        loading.succeed(`Resource Group ${rsg.name} Deleted`);
    });
}


async function cleanup() {
    console.log('Listing Resource Groups used in the YAML configuration'.magenta);
    console.log('========================================================='.magenta);
    console.log(rsgs);
    console.log('========================================================='.magenta);
    console.log('Above Resource Groups will be deleted!'.red);
    const answers = await inquirer.askConfirm();
    if (answers.confirm) {
        rsgs.forEach((rsg) => {
            //console.log(`Resource Group `.green + rsg.name + ` SubscriptionId `.green + rsg.subscriptionId);
            rsgChk(rsg);
        });
    } else {
        console.log('The action was cancelled!'.red);
        process.exit(1);
    }
}

cleanup()
