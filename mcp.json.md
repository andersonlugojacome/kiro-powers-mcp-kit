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

**Windows** — En PowerShell (permanente):

```powershell
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_AUTH_TOKEN", "dHUuZW1haWxAc2VndXJvc2JvbGl2YXIuY29tOmFiYzEyMw==", "User")
```

O via System Properties > Environment Variables.

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
