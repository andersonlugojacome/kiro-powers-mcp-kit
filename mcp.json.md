# mcp.json — Guia de configuracion

> JSON no soporta comentarios. Este archivo explica como configurar el `mcp.json`.

## Servidores MCP

### engram
- **command:** `engram` (binary Go, debe estar en PATH)
- **args:** `["mcp"]` inicia el MCP server via stdio
- **Prerequisito:** `brew install gentleman-programming/tap/engram`
- **Sin variables de entorno necesarias**

### context7
- **command:** `npx` ejecuta el package sin instalarlo
- **args:** `["-y", "@upstash/context7-mcp"]`
- **Prerequisito:** Node.js 18+
- **Sin variables de entorno necesarias**

### jira
- **command:** `npx`
- **args:** `["-y", "@aashari/mcp-server-atlassian-jira"]`
- **Package:** https://github.com/aashari/mcp-server-atlassian-jira
- **Prerequisito:** Node.js 18+ y API token de Atlassian

**Variables de entorno requeridas:**

| Variable | Descripcion | Ejemplo |
|---|---|---|
| `ATLASSIAN_SITE_NAME` | Nombre del site (parte antes de .atlassian.net) | `jirasegurosbolivar` |
| `ATLASSIAN_USER_EMAIL` | Tu email de Atlassian | `tu.email@segurosbolivar.com` |
| `ATLASSIAN_API_TOKEN` | API token personal | `abc123...` |

## Como configurar (Windows 11 sin admin)

### Paso 1: Crear API Token

1. Ir a: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Nombre: "Kiro MCP"
4. Copiar el token generado

### Paso 2: Configurar variables de entorno

En PowerShell:

```powershell
# Setear variables a nivel usuario (NO requiere admin)
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_SITE_NAME", "jirasegurosbolivar", "User")
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_USER_EMAIL", "tu.email@segurosbolivar.com", "User")
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_API_TOKEN", "tu-api-token-copiado", "User")
```

O desde la UI (sin admin):
1. Buscar "Variables de entorno" en el menu inicio
2. Click "Editar las variables de entorno de esta cuenta"
3. Nueva → agregar las 3 variables
4. Aceptar

### Paso 3: Reiniciar Kiro

Cerrar y abrir Kiro para que tome las variables nuevas.

### Paso 4: Verificar

En Kiro escribir: "Lista mis proyectos de Jira"

Si funciona, vas a ver tus proyectos. Si da 401, verificar:
- El site name es correcto (sin https://, sin .atlassian.net)
- El email coincide con tu cuenta de Atlassian
- El API token no expiró

## Como configurar (macOS/Linux)

Agregar a `~/.zshrc` o `~/.bashrc`:

```bash
export ATLASSIAN_SITE_NAME="jirasegurosbolivar"
export ATLASSIAN_USER_EMAIL="tu.email@segurosbolivar.com"
export ATLASSIAN_API_TOKEN="tu-api-token"
```

Luego:
```bash
source ~/.zshrc
```

## Verificar credenciales (sin Kiro)

```bash
npx -y @aashari/mcp-server-atlassian-jira get --path "/rest/api/3/myself"
```

Si muestra tu usuario, las credenciales estan bien.

## Troubleshooting

| Error | Causa | Solucion |
|---|---|---|
| 401 Unauthorized | Token invalido o expirado | Crear nuevo token en Atlassian |
| 403 Forbidden | Sin permisos en ese proyecto | Verificar acceso en Jira web |
| ATLASSIAN_SITE_NAME not set | Variable no exportada | Cerrar y abrir terminal, verificar con `echo $ATLASSIAN_SITE_NAME` |
| npx timeout | Sin internet o npm bloqueado | Verificar red/proxy |
