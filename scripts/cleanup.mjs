import fs, { exists } from'fs';
import ora from "ora";
import color from 'colors';
import { spawn } from 'child_process';
import yaml from 'js-yaml';
import inquirer from "./inquirer.js";
const yamlFilePath = './landing-zone/config/resource-groups.yaml';

let ymlfile = yaml.load(fs.readFileSync(yamlFilePath, 'utf8'));
const ymldata = ymlfile.resourceGroups.reverse();

const loading = ora({
    text: 'Processing..\n',
    color: 'yellow',
});

async function deleteRSG(rsg) {
    const child = spawn('powershell', [`az group delete --name ${rsg.name} --subscription ${rsg.subscriptionId} --yes`]);
    child.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });
}

async function cleanup() {
    console.log('Listing Resource Groups used in the configuration file'.yellow);
    console.log('========================================================='.yellow);
    console.log(ymldata);
    console.log('========================================================='.yellow);
    console.log('\nAbove Resource Groups will be deleted!\n'.red);

    const answers = await inquirer.askConfirm();
    loading.start();
    if (answers.confirm) {
        
        for (var i = 0; i < ymldata.length; i++) {
            let rsg = { 'name': ymldata[i].name, 'subscriptionId': ymldata[i].subscriptionId }
            const child = spawn('powershell', [`az group exists --name ${rsg.name} --subscription ${rsg.subscriptionId}`]);
            child.stdout.on('data', (data) => {
                const rsgExists = `${data}`.replace(/(\r?\n)/g, '')

                if (rsgExists == 'true') {
                    deleteRSG(rsg)
                    loading.succeed(`Resource Group ${rsg.name} Deleted`);
                } else {
                    loading.fail(`${rsg.name} Not Found!`);
                }

            });
            child.stderr.on('data', (data) => {
                console.error(`stderr: ${data}`);
            });

        }

    } else {
        console.log('The action was cancelled!'.yellow);
        process.exit(1);
    }
}

cleanup()