# Setup: Atlassian Jira

Server MCP para Jira Cloud via `@aashari/mcp-server-atlassian-jira`. Permite buscar, crear y actualizar issues desde Kiro.

## Prerequisitos

- Atlassian Cloud site con Jira
- Node.js v18+
- API token personal de Atlassian

## Configuracion MCP

El server se registra automaticamente en `mcp.json`:

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@aashari/mcp-server-atlassian-jira"],
      "env": {
        "ATLASSIAN_SITE_NAME": "${ATLASSIAN_SITE_NAME}",
        "ATLASSIAN_USER_EMAIL": "${ATLASSIAN_USER_EMAIL}",
        "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN}"
      }
    }
  }
}
```

## Variables de entorno

| Variable | Descripcion | Ejemplo |
|---|---|---|
| `ATLASSIAN_SITE_NAME` | Nombre del site (parte antes de `.atlassian.net`) | `jirasegurosbolivar` |
| `ATLASSIAN_USER_EMAIL` | Tu email de Atlassian | `tu.email@segurosbolivar.com` |
| `ATLASSIAN_API_TOKEN` | API token personal | `abc123...` |

## Setup paso a paso

### Paso 1: Crear API Token

1. Ir a: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Nombre: "Kiro MCP"
4. Copiar el token generado

### Paso 2: Configurar variables de entorno

#### Windows (PowerShell, sin admin)

```powershell
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_SITE_NAME", "jirasegurosbolivar", "User")
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_USER_EMAIL", "tu.email@segurosbolivar.com", "User")
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_API_TOKEN", "tu-api-token-copiado", "User")
```

O desde la UI:
1. Buscar "Variables de entorno" en el menu inicio
2. Click "Editar las variables de entorno de esta cuenta"
3. Nueva → agregar las 3 variables
4. Aceptar

#### macOS / Linux

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

### Paso 3: Reiniciar Kiro

Cerrar y abrir Kiro para que tome las variables nuevas.

### Paso 4: Verificar

En Kiro escribir: "Lista mis proyectos de Jira"

## Tips para reducir tokens

Agregar en el `AGENTS.md` de tu proyecto:

```markdown
## Atlassian Jira MCP
- MUST use Jira project key = TUPROJ
- MUST use maxResults: 10 for ALL searches
```

## Workflows comunes

```
"Buscar bugs abiertos en proyecto ALPHA"
"Crear issue: Redesign onboarding"
"Actualizar estado de ALPHA-123 a Done"
```

## Troubleshooting

| Error | Causa | Solucion |
|---|---|---|
| 401 Unauthorized | Token invalido o expirado | Crear nuevo token en Atlassian |
| 403 Forbidden | Sin permisos en ese proyecto | Verificar acceso en Jira web |
| `ATLASSIAN_SITE_NAME` not set | Variable no exportada | Cerrar/abrir terminal, verificar con `echo $ATLASSIAN_SITE_NAME` |
| npx timeout | Sin internet o npm bloqueado | Verificar red/proxy |

## Mas info

- [Package npm](https://www.npmjs.com/package/@aashari/mcp-server-atlassian-jira)
- [GitHub](https://github.com/aashari/mcp-server-atlassian-jira)

## Nota importante

Atlassian es **opcional**. El kit funciona completo con solo Engram + Context7. Si no tenes Atlassian Cloud, simplemente no configures este server.
