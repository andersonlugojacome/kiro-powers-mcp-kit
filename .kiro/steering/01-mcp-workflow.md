---
inclusion: always
---

# MCP Workflow (Engram GO + Context7 + Atlassian)

## Objetivo

Tener Kiro operativo con MCP de forma segura, portable e idempotente.

## Politica de Orquestacion Continua

1. En cada consulta del usuario, ejecutar Engram primero para contexto previo.
2. Mantener contador de consultas (`mcp_query_count`).
3. Refrescar Context7 cada 4 consultas (`mcp_query_count % 4 == 0`).
4. Si hay incertidumbre tecnica, consultar Context7 de inmediato.
5. Registrar decisiones y hallazgos en Engram al cerrar cada bloque.
6. Usar Atlassian (Jira/Confluence) cuando el usuario lo pida o cuando haya contexto de proyecto relevante.

## Flujo Recomendado

1. Verificar base del entorno: `engram`, `node`, `npx` disponibles.
2. Validar conectividad minima (internet para npm/Atlassian).
3. Confirmar `.kiro/settings/mcp.json` con los 3 servidores.
4. Probar Engram: `engram --version` y `engram doctor`.
5. Probar Context7: `npx -y @upstash/context7-mcp --help`.
6. Atlassian: verificar config presente (auth se maneja en runtime).
7. Reiniciar Kiro para levantar configuracion nueva.
8. Consulta de humo: docs en Context7 + registro en Engram.

## Uso de Atlassian

### Cuando usar Jira
- Buscar issues relacionados al trabajo actual
- Crear tickets desde specs o tasks SDD
- Actualizar estado de issues al completar apply/verify

### Cuando usar Confluence
- Buscar documentacion de arquitectura del equipo
- Crear paginas de specs/design como documentacion viva
- Referenciar paginas existentes en proposals

### Tips para reducir tokens
```markdown
## Atlassian Rovo MCP
- MUST use cloudId = "https://tu-site.atlassian.net"
- MUST use Jira project key = TUPROJ
- MUST use maxResults: 10 for searches
```

## Buenas Practicas

- JSON limpio y valido, sin comentarios.
- Evitar rutas absolutas de una sola maquina.
- No persistir secretos en archivos de equipo.
- Si Engram GO falla: verificar binary con `engram doctor`.
- Si Context7 no responde: continuar con Engram + contexto local.
- Si Atlassian no conecta: no bloquear trabajo, es opcional.

## Troubleshooting Rapido

| Problema | Solucion |
|---|---|
| `engram` no encontrado | `brew install gentleman-programming/tap/engram` |
| `npx` falla | Reinstalar nodejs-lts, abrir terminal nueva |
| Atlassian "unauthorized" | Renovar OAuth token o API token en Atlassian admin |
| Kiro no detecta cambios | Verificar mcp.json + reiniciar Kiro |
| Context7 timeout | Verificar internet, reintentar en proximo ciclo de 4 |
