$port = 8080
$dir = $PSScriptRoot

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".json" = "application/json"
}

Write-Host "Starting HTTP server on port $port..." -ForegroundColor Green
Write-Host "Open: http://localhost:$port" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow

Start-Process "http://localhost:$port"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$listener.Start()

while ($true) {
    try {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $false

        $requestLine = $reader.ReadLine()
        if (-not $requestLine) {
            $client.Close()
            continue
        }

        $parts = $requestLine -split ' '
        $method = $parts[0]
        $path = $parts[1]

        if ($path -eq '/') {
            $path = '/index.html'
        }

        $filePath = $dir + ($path -replace '/', '\')
        $filePath = $filePath -replace '\?.*$', ''

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath)
            $contentType = $mime[$ext]
            if (-not $contentType) {
                $contentType = "application/octet-stream"
            }
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $len = $bytes.Length

            $headers = @"
HTTP/1.1 200 OK
Content-Type: $contentType
Content-Length: $len
Connection: close

"@
            $writer.Write($headers)
            $writer.Flush()
            $stream.Write($bytes, 0, $len)
            $stream.Flush()
        } else {
            $body = "404 Not Found: $path"
            $headers = @"
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=utf-8
Content-Length: $($body.Length)
Connection: close

$body
"@
            $writer.Write($headers)
            $writer.Flush()
        }

        $client.Close()
    } catch {
        # Handle client disconnection gracefully
    }
}
