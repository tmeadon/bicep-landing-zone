const fs = require('fs');
const parseJson = require('parse-json');
const yaml = require('js-yaml');
const namingFilePath = './landing-zone/config/name-templates.yaml';
const bicepModulePath = './landing-zone/modules/naming.bicep';
const envSchemaPath = './landing-zone/config/schemas/environments-config-schema.json';

// load the template file
let naming = yaml.load(fs.readFileSync(namingFilePath));

// find all naming tokens and store uniquely in an array
let allTokens = [];

for (resourceType in naming) {
    let tokens = naming[resourceType].match(/{[^{}]*}/g);
    tokens.forEach((token) => {
        token = token.replaceAll(/{|}/g, '');
        if (! allTokens.includes(token)) {
            allTokens.push(token);
        }
    })
}

// build up the lines for the bicep naming module
let bicepModuleLines = [];
bicepModuleLines.push("param namingComponents object\n");

// add an output line for each resource type defined in the naming file
for (resourceType in naming) {
    let outputValue = `'${naming[resourceType]}'`;
    allTokens.forEach((token) => {
        outputValue = `replace(${outputValue}, '{${token}}', namingComponents.${token})`;
    });
    let outputLine = `output ${resourceType} string = ${outputValue}`;
    bicepModuleLines.push(outputLine);
}

// update the naming module file
fs.writeFileSync(bicepModulePath, bicepModuleLines.join("\n"));

// load the environments schema and update the properties of the naming definition
let schema = parseJson(fs.readFileSync(envSchemaPath));
let namingProps = {};

allTokens.forEach((token) => {
    namingProps[token] = { 'type': 'string' };
});

schema.definitions.naming.properties = namingProps;
schema.definitions.naming.required = allTokens;

// update the environments config schema file
fs.writeFileSync(envSchemaPath, JSON.stringify(schema, null, 2));
