# Setup: Atlassian (Jira + Confluence)

Server MCP remoto oficial de Atlassian. Conecta Jira y Confluence con Kiro via OAuth 2.1 o API token.

## Prerequisitos

- Atlassian Cloud site (Jira y/o Confluence)
- Admin debe habilitar Rovo MCP Server en la organizacion
- Node.js v18+ (para `mcp-remote` proxy)

## Configuracion MCP

```json
{
  "mcpServers": {
    "atlassian": {
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        "Authorization": "Basic ${ATLASSIAN_AUTH_TOKEN}"
      }
    }
  }
}
```

## Setup con API Token (nuestro equipo)

### Paso 1: Crear API Token personal

1. Ir a: https://id.atlassian.com/manage-profile/security/api-tokens
2. Crear un nuevo token con todos los scopes
3. Copiar el token generado

### Paso 2: Generar el base64

```bash
# Formato: email:api_token
echo -n "tu.email@segurosbolivar.com:TU_API_TOKEN" | base64
```

### Paso 3: Configurar .env

Copiar `.env.sample` a `.env` y completar:

```bash
cp .env.sample .env
# Editar .env con tus valores:
ATLASSIAN_EMAIL=tu.email@segurosbolivar.com
ATLASSIAN_TOKEN=tu-api-token
ATLASSIAN_URL=https://jirasegurosbolivar.atlassian.net
JIRA_PROJECT_KEY=TUPROJ
```

El valor de `ATLASSIAN_AUTH_TOKEN` es el base64 de `email:token`.

### Opcion alternativa: OAuth 2.1

Si prefieres no usar API token, la primera conexion abre un browser para autorizar via OAuth. No necesitas .env en ese caso.

## Products soportados

| Producto | Permisos | Auth disponible |
|---|---|---|
| Jira | read, write, search | OAuth + API token |
| Confluence | read, write, search | OAuth + API token |
| Jira Service Management | read, write | Solo API token |
| Bitbucket Cloud | read, write | Solo API token |
| Compass | read, write | Solo OAuth |

## Tips para reducir tokens

Agregar en tu AGENTS.md del proyecto:

```markdown
## Atlassian Rovo MCP
- MUST use cloudId = "https://tu-site.atlassian.net"
- MUST use Jira project key = TUPROJ
- MUST use Confluence spaceId = "123456"
- MUST use maxResults: 10 for ALL searches
```

## Workflows comunes

```
# Jira
"Buscar bugs abiertos en proyecto ALPHA"
"Crear issue: Redesign onboarding"
"Actualizar estado de ALPHA-123 a Done"

# Confluence
"Buscar pagina de arquitectura en espacio TEAM"
"Crear pagina con specs del cambio"
"Resumir la pagina de Q3 planning"
```

## Troubleshooting

| Problema | Solucion |
|---|---|
| "unauthorized" | Renovar token o repetir OAuth flow |
| "site admin must authorize" | Admin debe completar 3LO consent primero |
| Timeout en mcp-remote | Verificar internet y proxy/VPN |
| No aparece en Connected apps | Verificar cuenta/site correctos |

## Mas info

- [Atlassian MCP Server (GitHub)](https://github.com/atlassian/atlassian-mcp-server)
- [Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
- [Supported Tools](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/supported-tools/)

## Nota importante

Atlassian es **opcional**. El kit funciona completo con solo Engram + Context7. Si no tenes Atlassian Cloud, simplemente no configures este server.
