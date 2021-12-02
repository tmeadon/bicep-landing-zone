import fs from'fs';
import ora from "ora";
import color from 'colors';
import parseJson from 'parse-json';
import { spawn } from 'child_process';
import inquirer from "./inquirer.js";
const jsonFilePath = './landing-zone/config/resource-groups.json';

let json = parseJson(fs.readFileSync(jsonFilePath));
const rsgs = json.resourceGroups.reverse();
let groupFound = true;

async function rsgChk(rsg) {
    const child = spawn('powershell', [`az group exists --name ${rsg.name} --subscription ${rsg.subscriptionId}`]);
    child.stdout.on('data', (data) => {
        deleteRSG(rsg);
    });
}

async function deleteRSG(rsg) {
    const loading = ora({
        text: 'Processing..',
        color: 'yellow',
    });
    loading.start();
    const child = spawn('powershell', [`az group delete --name ${rsg.name} --subscription ${rsg.subscriptionId} --yes`]);
    child.stderr.on('data', (data) => {
        groupFound = false;
    });
    child.on('close', () => {
        if (groupFound) {
            loading.succeed(`Resource Group ${rsg.name} Deleted`);
        } else {
            loading.fail(`${rsg.name} Not Found!`);
        }
    });
}

async function cleanup() {
    console.log('Listing Resource Groups used in the configuration file'.yellow);
    console.log('========================================================='.yellow);
    console.log(rsgs);
    console.log('========================================================='.yellow);
    console.log('\nAbove Resource Groups will be deleted!\n'.red);

    const answers = await inquirer.askConfirm();

    if (answers.confirm) {
        await rsgs.forEach((rsg) => {
            rsgChk(rsg);
        });
    } else {
        console.log('The action was cancelled!'.yellow);
        process.exit(1);
    }
}

cleanup()
