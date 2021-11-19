const { execSync } = require('child_process');

execSync("npm run update-naming");
execSync("npm run config-to-json");