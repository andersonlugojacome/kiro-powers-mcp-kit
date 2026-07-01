# mcp.json — Guia de configuracion

> JSON no soporta comentarios. Este archivo explica como configurar el `mcp.json`.

## Servidores MCP

### engram
- **command:** `engram` (binary Go, debe estar en PATH)
- **args:** `["mcp"]` inicia el MCP server via stdio
- **Prerequisito:** `brew install gentleman-programming/tap/engram`
- **Sin variables de entorno necesarias**

### context7
- **command:** `npx` ejecuta el package sin instalarlo globalmente
- **args:** `["-y", "@upstash/context7-mcp"]`
- **Prerequisito:** Node.js 18+
- **Sin variables de entorno necesarias**

### atlassian
- **url:** Endpoint remoto del MCP server de Atlassian
- **headers.Authorization:** `Basic ${ATLASSIAN_AUTH_TOKEN}`
- **`${ATLASSIAN_AUTH_TOKEN}`** se reemplaza con la variable de entorno del sistema

## Como configurar ATLASSIAN_AUTH_TOKEN

### Paso 1: Generar el token base64

```bash
echo -n "tu.email@segurosbolivar.com:TU_API_TOKEN_AQUI" | base64
```

Esto produce algo como: `dHUuZW1haWxAc2VndXJvc2JvbGl2YXIuY29tOmFiYzEyMw==`

### Paso 2: Exportar la variable

**macOS/Linux** — Agregar a `~/.zshrc` o `~/.bashrc`:

```bash
export ATLASSIAN_AUTH_TOKEN="dHUuZW1haWxAc2VndXJvc2JvbGl2YXIuY29tOmFiYzEyMw=="
```

Luego recargar:
```bash
source ~/.zshrc
```

**Windows 11 (sin permisos de administrador)** — En PowerShell:

```powershell
# Setear variable a nivel usuario (NO requiere admin)
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_AUTH_TOKEN", "dHUuZW1haWxAc2VndXJvc2JvbGl2YXIuY29tOmFiYzEyMw==", "User")
```

O desde la UI (sin admin):
1. Buscar "Variables de entorno" en el menu inicio
2. Click en "Editar las variables de entorno de esta cuenta" (NO las del sistema)
3. Nueva → Nombre: `ATLASSIAN_AUTH_TOKEN` → Valor: el base64
4. Aceptar

**Generar el base64 en PowerShell (sin admin):**

```powershell
$bytes = [System.Text.Encoding]::UTF8.GetBytes("tu.email@segurosbolivar.com:TU_API_TOKEN")
[System.Convert]::ToBase64String($bytes)
```

**Verificar en PowerShell:**

```powershell
# Verificar que existe
$env:ATLASSIAN_AUTH_TOKEN

# Decodificar para confirmar
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($env:ATLASSIAN_AUTH_TOKEN))
```

> **IMPORTANTE:** Despues de setear la variable, cerrar y abrir una terminal nueva (o reiniciar Kiro) para que tome el valor.

### Paso 3: Reiniciar Kiro

Kiro lee las variables de entorno al iniciar. Despues de exportar, reiniciar Kiro para que tome el valor.

## Verificar

```bash
# Verificar que la variable existe
echo $ATLASSIAN_AUTH_TOKEN

# Verificar que decodifica bien
echo $ATLASSIAN_AUTH_TOKEN | base64 --decode
# Debe mostrar: tu.email@segurosbolivar.com:tu-api-token
```

## Si prefieres OAuth (sin variables)

Cambia el mcp.json a:

```json
{
  "atlassian": {
    "command": "npx",
    "args": ["-y", "mcp-remote", "https://mcp.atlassian.com/v1/mcp/authv2"]
  }
}
```

Con OAuth, la primera conexion abre un browser para autorizar. No necesitas variables de entorno.
