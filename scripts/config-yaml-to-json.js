const fs = require('fs');
const yaml = require('js-yaml');
const configPath = './landing-zone/config';

let files = fs.readdirSync(configPath);

files.forEach((file) => {
    const extension = file.split('.').pop();
    if (extension === "yml" || extension === "yaml") {
        let fileContents = fs.readFileSync(configPath + '/' + file, 'utf8');
        let data = yaml.load(fileContents);
        const outputJson = JSON.stringify(data, null, "\t");
        var outfile = configPath + '/' + file.replace(extension, 'json')
        fs.writeFile(outfile, outputJson, function (err) {
            if (err) return console.log(err);
        });
    };
});