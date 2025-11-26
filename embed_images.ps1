Param()

$ErrorActionPreference = 'Stop'

Write-Host 'Gerando index-embedded.html com imagens embutidas...' -ForegroundColor Cyan

$images = @(
    @{ path = 'images\refeitorio-fila.jpg.png'; mime = 'image/png' },
    @{ path = 'images\buffet-close.jpg.png';     mime = 'image/png' },
    @{ path = 'images\conversa-patio.jpg.jpg';   mime = 'image/jpeg' },
    @{ path = 'images\janela-grupo.jpg.jpg';     mime = 'image/jpeg' },
    @{ path = 'images\mesa-discussao.jpg.jpg';   mime = 'image/jpeg' },
    @{ path = 'images\comida.png';               mime = 'image/png' }
)

$indexPath = 'index.html'
if (!(Test-Path $indexPath)) { throw "Arquivo $indexPath não encontrado" }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($indexPath, $utf8NoBom)

foreach ($img in $images) {
    $p = $img.path
    if (!(Test-Path $p)) { Write-Warning "Imagem não encontrada: $p"; continue }
    $bytes  = [System.IO.File]::ReadAllBytes($p)
    $b64    = [System.Convert]::ToBase64String($bytes)
    $data   = "data:$($img.mime);base64,$b64"
    $rel    = ($p -replace '\\','/')

    # src="images/..."
    $patternSrc = 'src="' + $rel + '"'
    $replacementSrc = 'src="' + $data + '"'
    $content = $content -replace [Regex]::Escape($patternSrc), $replacementSrc

    # url('images/...') e url("images/...")
    $patternUrl1 = "url('$rel')"
    $replacementUrl1 = "url('$data')"
    $patternUrl2 = 'url("' + $rel + '")'
    $replacementUrl2 = 'url("' + $data + '")'
    $content = $content -replace [Regex]::Escape($patternUrl1), $replacementUrl1
    $content = $content -replace [Regex]::Escape($patternUrl2), $replacementUrl2
}

$outPath = 'index-embedded.html'
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($outPath, $content, $utf8Bom)

Write-Host "OK: $outPath gerado (UTF-8 BOM)" -ForegroundColor Green
