function New-Oid {
    param([string]$Prefix = '1.2.840.113556.1.8000.2554')

    $guid = [string]([System.Guid]::NewGuid())
    $oid = 0, 4, 9, 14, 19, 24, 30 | ForEach-Object {
        if ($_ -ge 24) { $l = 6 } else { $l = 4 }
        [UInt64]::Parse($guid.SubString($_, $l), 'AllowHexSpecifier')
    }
    $prefix + ($oid -join '.')
}

function Get-ADAttributeSchemaSyntax {
    param([ValidateSet('bool', 'int', 'string', 'datetime', 'distinguishedName')][string]$Type)

    # Based on the following table: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa
    switch ($Type) {
        'bool'              { $omSyntax = 1   ; $attrSyntax = '2.5.5.8' }
        'int'               { $omSyntax = 2   ; $attrSyntax = '2.5.5.9' }
        'string'            { $omSyntax = 64  ; $attrSyntax = '2.5.5.12' }
        'datetime'          { $omSyntax = 24  ; $attrSyntax = '2.5.5.11' }
        'distinguishedName' { $omSyntax = 127 ; $attrSyntax = '2.5.5.1' }
    }

    [PSCustomObject]@{
        oMSyntax = $omSyntax
        attributeSyntax = $attrSyntax
    }
}

function New-ADAttributeSchema {
    param(
        [string]$Name,
        [string]$LDAPName,
        [string]$Type,
        [string]$OID = (New-Oid),
        [int]$Index = 0,
        [switch]$IsMultiValued
    )

    $Path = (Get-ADRootDSE).schemaNamingContext
    $syntax = Get-ADAttributeSchemaSyntax -Type $Type
    
    $splat = @{
        Name = $Name
        Type = 'AttributeSchema'
        Path = $Path
        OtherAttributes = @{
            LdapDisplayName = $LDAPName
            AdminDescription = $Name
            AttributeID = $OID
            OMSyntax = $syntax.OMSyntax
            AttributeSyntax = $syntax.AttributeSyntax
            SearchFlags = $Index
            IsSingleValued = !$IsMultiValued.IsPresent
        }
    }

    New-ADObject @splat
}

function Add-ADAttributeSchemaToClass {
    param(
        [string]$AttributeName,
        [string]$ObjectClass
    )

    $Path = (Get-ADRootDSE).schemaNamingContext
    $classSchema = Get-ADObject -Filter {Name -eq $ObjectClass} -SearchBase $Path
    Set-ADObject $classSchema -Add @{MayContain = $AttributeName}
}

function Remove-ADAttributeSchemaFromClass {
    param(
        [string]$AttributeName,
        [string]$ObjectClass
    )

    $Path = (Get-ADRootDSE).schemaNamingContext
    $classSchema = Get-ADObject -Filter {Name -eq $ObjectClass} -SearchBase $Path
    Set-ADObject $classSchema -Remove @{MayContain = $AttributeName}
}

function Get-ADAttributeSchema {
    param(
        [scriptblock]$Filter,
        [string[]]$Properties = @('Name','ObjectClass','LdapDisplayName','distinguishedName')
    )

    $splat = @{
        Filter = if ($Filter) { $Filter } else { '*' }
        Properties = $Properties
        SearchBase = (Get-ADRootDSE).schemaNamingContext
    }
    Get-ADObject @splat | Where-Object { $_.objectClass -eq 'attributeSchema' }
}

function Get-ADClassSchema {
    param(
        [scriptblock]$Filter,
        [string[]]$Properties = @('Name','ObjectClass','LdapDisplayName','distinguishedName')
    )

    $splat = @{
        Filter = if ($Filter) { $Filter } else { '*' }
        Properties = $Properties
        SearchBase = (Get-ADRootDSE).schemaNamingContext
    }
    Get-ADObject @splat | Where-Object { $_.objectClass -eq 'classSchema' }
}