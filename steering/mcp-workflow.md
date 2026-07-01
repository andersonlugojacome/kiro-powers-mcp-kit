# MCP Workflow — Engram GO + Context7 + Atlassian

## Flujo Recomendado

1. Verificar prerequisitos: `engram`, `node`, `npx` disponibles.
2. Validar conectividad (internet para npm/Atlassian).
3. Confirmar mcp.json con los 3 servidores.
4. Probar Engram: `engram --version` y `engram doctor`.
5. Probar Context7: `npx -y @upstash/context7-mcp --help`.
6. Atlassian: verificar config (auth se maneja en runtime).
7. Reiniciar Kiro para aplicar cambios.

## Ciclo Continuo

```
onUserQuery(query):
  mem_search(query)  # Engram primero
  mcp_query_count += 1
  if mcp_query_count % 4 == 0:
    refresh Context7
  process query with full context
  if important finding:
    mem_save(finding)
```

## Uso de Atlassian

### Jira
- Buscar issues: JQL queries
- Crear tickets desde specs SDD
- Actualizar estados al completar work

### Confluence
- Buscar documentacion de arquitectura
- Crear paginas con specs/design
- Referenciar paginas en proposals

### Tips para tokens
```
- MUST use cloudId = "https://jirasegurosbolivar.atlassian.net"
- MUST use Jira project key = (ver .env JIRA_PROJECT_KEY)
- MUST use maxResults: 10 for searches
```

## Reglas de Seguridad

- No hardcodear secretos en mcp.json ni steering.
- Usar variables de entorno para credenciales.
- No persistir tokens en texto plano.

## Troubleshooting

| Problema | Solucion |
|---|---|
| `engram` not found | `brew install gentleman-programming/tap/engram` |
| `npx` falla | Reinstalar Node.js, abrir terminal nueva |
| Atlassian unauthorized | Renovar OAuth o API token |
| Context7 timeout | Verificar internet, continuar con Engram |
| Kiro no detecta cambios | Verificar mcp.json + reiniciar Kiro |

## Notificacion Proactiva de Updates (P10)

En la primera interaccion del dia con este Power activo:

1. Consultar GitHub API:
   ```
   GET https://api.github.com/repos/andersonlugojacome/kiro-powers-mcp-kit/releases/latest
   ```
2. Obtener `tag_name` del ultimo release.
3. Buscar en Engram si ya se notifico hoy:
   ```
   mem_search(query: "power-update-check", project: "kiro-powers-mcp-kit")
   ```
4. Si no se notifico hoy Y hay version nueva:
   - Informar al usuario: "Hay update de kiro-powers-mcp-kit (vX.Y.Z). Powers panel > Check for updates."
   - Guardar en Engram:
   ```
   mem_save(
     title: "power-update-check",
     topic_key: "power-update-check/last-notify",
     type: "decision",
     project: "kiro-powers-mcp-kit",
     content: "date: {hoy ISO}\nversion: {tag}\nnotified: true"
   )
   ```
5. Si ya se notifico hoy: no repetir.
6. Si no hay release nuevo: silencio.

### Canales

| Branch | Canal | Descripcion |
|---|---|---|
| `main` | stable | Default, probado |
| `canary` | canary | Pre-release, early adopters |

Para instalar canary: Import from GitHub con branch `canary`.

## Degradacion Graceful

- Si Engram no disponible: continuar sin memoria, WARN al usuario.
- Si Context7 no responde: usar Engram + contexto local.
- Si Atlassian no conecta: no bloquear, es opcional.
- Prioridad: 1) contexto local, 2) Engram, 3) Context7, 4) Atlassian.
