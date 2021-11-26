const fs = require('fs');
const color = require('colors');
const parseJson = require('parse-json');
const jsonFilePath = './landing-zone/config/resource-groups.json';

let json = parseJson(fs.readFileSync(jsonFilePath));

const rsgs = json.resourceGroups;
console.log('Listing Resource Groups used in the YAML configuration'.magenta);
rsgs.forEach((rsg) => {
    console.log(`Resource Group `.green + rsg.name + ` SubscriptionId `.green + rsg.subscriptionId);
});


