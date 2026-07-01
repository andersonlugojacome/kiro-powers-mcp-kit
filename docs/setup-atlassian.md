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
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.atlassian.com/v1/mcp"]
    }
  }
}
```

## Autenticacion

### Opcion A: OAuth 2.1 (recomendado para uso personal)

1. Al conectar por primera vez, se abre un browser para autorizar
2. Aceptar permisos de Jira/Confluence
3. El token se gestiona automaticamente

### Opcion B: API Token (headless, para CI/automacion)

1. Admin habilita API token en: Atlassian Administration > Rovo > MCP server > Authentication
2. Crear token personal con scopes necesarios
3. Configurar en el endpoint:

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.atlassian.com/v1/mcp"]
    }
  }
}
```

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
