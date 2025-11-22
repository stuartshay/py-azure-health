@description('Environment name (dev, staging, prod)')
param environment string = 'dev'

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Application name')
param appName string = 'azure-health'

@description('Tags to apply to all resources')
param tags object = {
  application: 'py-azure-health'
  environment: environment
  managedBy: 'bicep'
}

// Generate unique names
var uniqueSuffix = uniqueString(resourceGroup().id)
var functionAppName = 'func-${appName}-${environment}-${uniqueSuffix}'
var storageAccountName = 'st${replace(appName, '-', '')}${environment}${take(uniqueSuffix, 6)}'
var appInsightsName = 'appi-${appName}-${environment}'
var logAnalyticsName = 'log-${appName}-${environment}'

// Reference existing App Service Plan
resource existingAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: 'azurehealth-plan-dev'
  scope: resourceGroup()
}

// Storage Account for Function App
module storage './modules/storage.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
  }
}

// Log Analytics Workspace
module logAnalytics './modules/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
    tags: tags
  }
}

// Application Insights
module appInsights './modules/app-insights.bicep' = {
  name: 'app-insights-deployment'
  params: {
    appInsightsName: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
}

// Function App
module functionApp './modules/function-app.bicep' = {
  name: 'function-app-deployment'
  params: {
    functionAppName: functionAppName
    location: location
    appServicePlanId: existingAppServicePlan.id
    storageAccountName: storage.outputs.storageAccountName
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    tags: tags
  }
}

// Outputs
output functionAppName string = functionApp.outputs.functionAppName
output functionAppHostName string = functionApp.outputs.functionAppHostName
output storageAccountName string = storage.outputs.storageAccountName
output appInsightsName string = appInsights.outputs.appInsightsName
output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName
