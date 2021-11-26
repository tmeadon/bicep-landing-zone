const fs = require('fs');
const parseJson = require('parse-json');
const jsonFilePath = './landing-zone/config/resource-groups.json';

let json = parseJson(fs.readFileSync(jsonFilePath));

console.log(json.resourceGroups);
