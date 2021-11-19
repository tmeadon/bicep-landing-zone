const fs = require('fs');
const path = require("path")
const yaml = require('js-yaml');
const parseJson = require('parse-json');
const { matchers } = require('jest-json-schema');
expect.extend(matchers);

// store the paths to the config and schema directories
const configPath = './landing-zone/config';
const schemaPath = path.join(configPath, 'schemas');

// get a list of config files (json or yaml files) and create a map of their file names and extensions
const configFiles = fs.readdirSync(configPath)
                    .filter((fileName) => fileName.match(/json$|yaml$|yml$/))
                    .map(file => ({ 'name': file, 'extension': file.split('.').pop() }));

// get a list of json schema files
const schemaFiles = fs.readdirSync(schemaPath).filter(fileName => fileName.match(/\.json/));

// define a helper function for reading file data depending on the file's extension
const readFileData = (filePath) => {
    let extension = filePath.split('.').pop();
    let fileContents = fs.readFileSync(filePath, 'utf-8');
    if (extension === 'json') {
        return parseJson(fileContents);
    }
    else if (extension.match(/yaml|yml/)) {
        return yaml.load(fileContents);
    }
    else {
        throw `cannot read data from file ${filePath}`;
    }
}

// define a helper function for finding all the config files that have schemas defined
const getConfigFilesWithSchema = () => {
    let configFilesWithSchema = configFiles.map((configFile) => {
        let fileData = readFileData(path.join(configPath, configFile.name));
        if (fileData.hasOwnProperty('$schema')) {
            let schemaFileName = fileData.$schema.split("/").pop();
            let schemaFilePath = path.join(schemaPath, schemaFileName);
            return {
                'filePath': path.join(configPath, configFile.name),
                'extension': configFile.extension,
                'schemaPath': schemaFilePath
            };
        }
    });

    return configFilesWithSchema.filter(item => item !== undefined);
}

// verify all the config files are formatted correctly
test.each(configFiles)('config file is valid $extension ($name)', (configFile) => {
    let filePath = path.join(configPath, configFile.name);
    readFileData(filePath);
});

// verify all the schema files are valid json
test.each(schemaFiles)('schema file is valid json (%s)', (fileName) => {
    let filePath = path.join(schemaPath, fileName);
    readFileData(filePath);    
});

// verify that all config files with schemas defined are valid against their schema
test.each(getConfigFilesWithSchema())('config file ($filePath) is valid against schema ($schemaPath)', ({filePath, schemaPath}) => {
    let configFileContents = fs.readFileSync(filePath);
    let configFileData = yaml.load(configFileContents);
    let schemaFileContents = fs.readFileSync(schemaPath);
    let schemaFileData = parseJson(schemaFileContents);
    expect(configFileData).toMatchSchema(schemaFileData);
})

// verify that all referenced environments exist in environments config file
test.each(configFiles.filter((file) => file.name.match(/yaml$|yml$/)))('config file ($name) references valid environments', (configFile) => {
    let filePath = path.join(configPath, configFile.name);
    let fileContent = fs.readFileSync(filePath, 'utf-8');
    let environmentMatches = fileContent.matchAll(/environment\:\s*"?([^\r\n"]*)"?/gm);
    let validEnvironments = (readFileData(path.join(configPath, 'environments.yaml'))).environments
    for (let match of environmentMatches) {
        let environmentRef = match[1]
        expect(validEnvironments).toHaveProperty(environmentRef);
    }
})