<#
 Génère PageHTML\manifest.json (liste des pages HTML, titre lu dans <title>).
 À lancer depuis la racine du dépôt avant chaque commit :  .\generate-manifest.ps1
#>
$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$folder = Join-Path $root 'PageHTML'

$pages = Get-ChildItem -Path $folder -Filter *.html -Recurse -File |
  Where-Object { $_.Name -notlike 'manifest*' } |
  ForEach-Object {
    $rel = $_.FullName.Substring($folder.Length + 1).Replace('\','/')
    $raw = Get-Content -Path $_.FullName -Raw -Encoding UTF8
    $title = $null
    if ($raw -match '(?is)<title[^>]*>\s*(.*?)\s*</title>') { $title = ($Matches[1] -replace '\s+',' ').Trim() }
    if (-not $title) { $title = ($_.BaseName -replace '[_-]+',' ').Trim() }
    [pscustomobject]@{ file = $rel; title = $title }
  } | Sort-Object file

$json = ConvertTo-Json -InputObject @($pages) -Depth 3
[System.IO.File]::WriteAllText((Join-Path $folder 'manifest.json'), $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "manifest.json généré : $(@($pages).Count) page(s)." -ForegroundColor Green
