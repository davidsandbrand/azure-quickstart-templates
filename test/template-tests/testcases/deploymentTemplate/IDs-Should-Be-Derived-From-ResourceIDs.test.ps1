<#
.Synopsis
    Ensures that all IDs use the resourceID() function.
.Description
    Ensures that all IDs use the resourceID() function, or resolve to parameters or variables that use the ResourceID() function.
.Example
    Test-AzureRMTemplate -TemplatePath .\100-marketplace-sample\ -Test IDs-Should-Be-Derived-From-ResourceIDs
.Example
    .\IDs-Should-Be-Derived-From-ResourceIDs.test.ps1 -TemplateObject (Get-Content ..\..\..\..\100-marketplace-sample\azureDeploy.json | ConvertFrom-Json) 
#>
param(
# The template object (the contents of azureDeploy.json, converted from JSON)
[Parameter(Mandatory=$true,Position=0)]
$TemplateObject)

# First, find all objects with an ID property in the MainTemplate.
$ids = $TemplateObject  | Find-JsonContent -Key id -Value * -Like

foreach ($id in $ids) { # Then loop over each object with an ID
    $myId = "$($id.id)".Trim() # Grab the actual ID,
    $expandedId = Expand-AzureRMTemplate -Expression $myId -InputObject $TemplateObject # then expand it.
    # Check that it uses the ResourceID or a param or var - can remove variables once Expand-Template does full eval of nested vars
    # REGEX
    # - 0 or more whitespace
    # - [ to make sure it's an expression
    # - expression must be parameters|variables|resourceId
    # - 0 or more whitespace
    # - opening paren (
    # - 0 or more whitepace
    # - single quote
    #
    if ($expandedId -notmatch "\s{0,}\[\s{0,}(resourceId|parameters|variables)\s{0,}\(\s{0,}'"){
        Write-Error "Property: `"$($id.propertyName)`" must use one of the following expressions for an resourceId property (resourceId(), parameters(), variables())" -TargetObject $id
    }
}
