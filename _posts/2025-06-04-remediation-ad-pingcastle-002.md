---
title: "PING CASTLE - Trusts"
description: "Relations d'approbations et connexions entre différents domaines et/ou forêts"
tableOfContent: "remediation-ad-pingcastle-introduction#table-des-matières"
nextLink:
  name: "Privileged Accounts"
  id: "remediation-ad-pingcastle-003"
prevLink:
  name: "Stale Object"
  id: "remediation-ad-pingcastle-001"
---

## Anciens protocoles

### T-Downlevel

### T-AlgsAES

## Filtrage des SID

### T-SIDFiltering

## SIDHistory

### T-SIDHistorySameDomain

### S-Domain$$$

### T-SIDHistoryDangerous

### T-SIDHistoryUnknownDomain

## Imperméabilité des relations d'approbation

### T-FileDeployedOutOfDomain

### T-TGTDelegation

### T-ScriptOutOfDomain

## Relations d'approbation inactives

### T-Inactive

## Relation d'approbation avec Azure

### T-AzureADSSO

J'ai déjà écrit un article technique sur le sujet disponible ici : [Rotation du mot de passe de AZUREADSSOACC](https://www.labouabouate.fr/2024/07/04/azureadssoacc)

{% include risk-score.html impact=1 probability=2 comment="Manipulation avec assez peu de risque au vu du faible impact que cela peut avoir en cas de problème." %}
