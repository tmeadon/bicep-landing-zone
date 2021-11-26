# Bicep Landing Zone

## Introduction
Create Landing Zone script in Bicep

## Usage
The package can be used both localy or as part of pipeline.

Start with cloning the repo.  

Amend the config files with your own values.  
Amend `./landing-zone/environments.yaml` to add your own environments.  
Amend `./landing-zone/networking.yaml` for your VNET needs.  
Amend `./landing-zone/core.yaml` to amend core resources.  Note that supported resources are limited to existing resources used in this file.  

### For local use
Install NodeJS 16.x or higher.  

Run below in Terminal of choice.  
```bash
# Install the required modules:  

npm install

# Convert the YAML config to JSON:  
npm start

# Deploy the Landing Zone:  
npm run deploy
```  
![console](.attachments/console.png)  


### For pipeline use  
Clone the repo.

In GitHub Actions:  
Use `.github/workflows/deploy-landingzone.yml` to deploy the Landing Zone package.  

In Azure Pipeline:  
Use `.azure/pipelines.yml` to deploy the Landing Zone package.


## Deployed Resources  
See below resources deployed as base core deployment into two subscriptions (not limited to two).

![resources](.attachments/resources.png)  
