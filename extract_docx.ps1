Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('实验方案3.docx')
$entry = $zip.GetEntry('word/document.xml')
$reader = New-Object System.IO.StreamReader($entry.Open())
$xml = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()
$text = [regex]::Matches($xml, '<w:t[^>]*>(.*?)</w:t>') | ForEach-Object { $_.Groups[1].Value }
$result = $text -join ""
Write-Output $result
