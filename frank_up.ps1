# PowerShell bootstrap for Windows
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$LogDir  = Join-Path $Root 'logs'
$LogFile = Join-Path $LogDir 'frank_up.log'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path $LogFile -Append
Write-Output ("=== frank_up.ps1 started at {0} ===" -f (Get-Date))

function Need-Cmd ($cmd) { Get-Command $cmd -ErrorAction SilentlyContinue }

function Install-IfMissing ($cmd, $wingetId, $chocoPkg) {
  if (-not (Need-Cmd $cmd)) {
    if (Need-Cmd 'winget') {
      winget install --id $wingetId -e --silent
    } elseif (Need-Cmd 'choco') {
      choco install $chocoPkg -y
    } else {
      Write-Error ("Missing {0} and no package manager found" -f $cmd)
      exit 1
    }
  }
}

Install-IfMissing git 'Git.Git' 'git'
Install-IfMissing python 'Python.Python.3' 'python'
Install-IfMissing node 'OpenJS.NodeJS.LTS' 'nodejs'
Install-IfMissing redis-server 'Microsoft.OpenSource.Redis' 'redis-64'
Install-IfMissing ollama 'Ollama.Ollama' 'ollama'

if (Get-Service redis -ErrorAction SilentlyContinue) {
  Start-Service redis
} elseif (Need-Cmd 'redis-server') {
  $redisOut = Join-Path $LogDir 'redis.out.log'
  $redisErr = Join-Path $LogDir 'redis.err.log'
  Start-Process redis-server -WindowStyle Hidden -RedirectStandardOutput $redisOut -RedirectStandardError $redisErr

}

if (Get-Service ollama -ErrorAction SilentlyContinue) {
  Start-Service ollama
} elseif (Need-Cmd 'ollama') {
  $ollamaOut = Join-Path $LogDir 'ollama.out.log'
  $ollamaErr = Join-Path $LogDir 'ollama.err.log'
  Start-Process ollama -ArgumentList 'serve' -WindowStyle Hidden -RedirectStandardOutput $ollamaOut -RedirectStandardError $ollamaErr

}

python -m venv .venv
$activate = [IO.Path]::Combine($Root,'.venv','Scripts','Activate.ps1')
. $activate
python -m pip install --upgrade pip
python -m pip install -r backend/requirements.txt

$envPath = Join-Path $Root '.env'
if (-not (Test-Path $envPath)) {
@'
PORT=8000
REDIS_URL=redis://localhost:6379/0
DATABASE_URL=sqlite:///./app.db
MODEL=llama3
DEBUG=false
'@ | Set-Content $envPath
}

Get-Content $envPath | ForEach-Object {
  $pair = $_.Split('=',2)
  [Environment]::SetEnvironmentVariable($pair[0], $pair[1])
}

$backendOut = Join-Path $LogDir 'backend.out.log'
$backendErr = Join-Path $LogDir 'backend.err.log'
$backend = Start-Process python -ArgumentList '-m backend.app.main' -RedirectStandardOutput $backendOut -RedirectStandardError $backendErr -WindowStyle Hidden -PassThru

$backend.Id | Out-File (Join-Path $LogDir 'backend.pid')

for ($i=0; $i -lt 30; $i++) {
  try {
    Invoke-WebRequest -UseBasicParsing ("http://localhost:{0}/api/hello" -f $env:PORT) | Out-Null
    break
  } catch {
    Start-Sleep -Seconds 1
  }
}

$celeryOut = Join-Path $LogDir 'celery.out.log'
$celeryErr = Join-Path $LogDir 'celery.err.log'
$celery = Start-Process celery -ArgumentList '-A backend.app.tasks worker --beat' -RedirectStandardOutput $celeryOut -RedirectStandardError $celeryErr -WindowStyle Hidden -PassThru

$celery.Id | Out-File (Join-Path $LogDir 'celery.pid')

$frontDir = if (Test-Path (Join-Path $Root 'vue')) { Join-Path $Root 'vue' } elseif (Test-Path (Join-Path $Root 'app')) { Join-Path $Root 'app' } else { '' }
if ($frontDir -eq '') { Write-Error 'No frontend directory (vue/ or app/) found.'; exit 1 }
$frontendOut = Join-Path $LogDir 'frontend.out.log'
$frontendErr = Join-Path $LogDir 'frontend.err.log'
$frontend = Start-Process python -ArgumentList '-m http.server 8080' -WorkingDirectory $frontDir -RedirectStandardOutput $frontendOut -RedirectStandardError $frontendErr -WindowStyle Hidden -PassThru

$frontend.Id | Out-File (Join-Path $LogDir 'frontend.pid')

Write-Output 'OS            : Windows'
Write-Output ("Backend URL   : http://localhost:{0}/api" -f $env:PORT)
Write-Output 'Frontend URL  : http://localhost:8080'

Stop-Transcript
