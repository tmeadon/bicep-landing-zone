# Bicep Landing Zone

## Introduction
Create Landing Zone script in Bicep

## Usage
The package can be used both localy or as part of pipeline.

### For local use
Install NodeJS 16.x or higher.  

Clone or fork the repo.  

Run below in Terminal of choice.  
```bash
# Install the required modules:  

npm install

# Convert the YAML config to JSAON:  
npm start

# Deploy the Landing Zone:  
npm run deploy
```

### For pipeline use  
Use Ubuntu agents to build and deploy the Landing Zone package.

In GitHub Actions:  
Use `.github/workflows/deploy-landingzone.yml` to deploy the Landing Zone package.  

In Azure Pipeline:  
Use `.azure/pipelines.yml` to deploy the Landing Zone package.
