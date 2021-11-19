param namingComponents object

output vnet string = replace(replace(replace('vnet-{env}-{locationShort}-{app}', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output bastion string = replace(replace(replace('bst-{env}-{locationShort}-{app}', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output bastionPip string = replace(replace(replace('bst-{env}-{locationShort}-{app}-pip', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output firewall string = replace(replace(replace('fw-{env}-{locationShort}-{app}', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output firewallPip string = replace(replace(replace('fw-{env}-{locationShort}-{app}-pip', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output keyVault string = replace(replace(replace('kv{env}{locationShort}{app}', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output logAnalyticsWorkspace string = replace(replace(replace('la-{env}-{locationShort}-{app}', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)
output vm string = replace(replace(replace('{env}-{locationShort}-{app}', '{env}', namingComponents.env), '{locationShort}', namingComponents.locationShort), '{app}', namingComponents.app)