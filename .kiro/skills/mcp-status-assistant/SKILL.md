---
name: mcp-status-assistant
description: >
  Muestra estado rapido de kiro-powers-mcp-kit: servidores MCP activos, Engram GO,
  Context7 y Atlassian. Trigger: "estatus", "estado mcp", "status", "mcp status".
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Objetivo

Entregar en el chat un resumen tecnico del estado MCP local.

## Que debe verificar

### 1. Configuracion MCP

Leer `.kiro/settings/mcp.json` del proyecto o `~/.kiro/settings/mcp.json` (usuario):
- Confirmar existencia de `engram`, `context7`, `atlassian` en `mcpServers`
- Mostrar command/args de cada server

### 2. Engram GO

- Verificar: `engram --version`
- Verificar: `engram mcp --help` (timeout 10s)
- Verificar: `~/.engram/engram.db` existe (SQLite)
- Mostrar: version, tamano de DB, proyecto actual

### 3. Context7

- Verificar: `npx -y @upstash/context7-mcp --help` (timeout 15s)
- Mostrar: estado OK/WARN

### 4. Atlassian

- Verificar: config presente en mcp.json
- Nota: server remoto, no se puede verificar sin auth activa
- Mostrar: endpoint configurado, estado config OK/WARN

## Formato de respuesta

```
## MCP Status

### Configuracion
- engram: {command} {args} — {OK/MISSING}
- context7: {command} {args} — {OK/MISSING}
- atlassian: {command} {args} — {OK/MISSING}

### Engram GO
- Version: {version}
- DB: {path} ({size})
- Proyecto: {current project}
- Estado: {OK/WARN}

### Context7
- Estado: {OK/WARN/TIMEOUT}

### Atlassian
- Endpoint: {url}
- Config: {OK/MISSING}
- Auth: requiere OAuth o API token

### Estado Final: {OK / WARN / BLOQUEO}
{Accion recomendada si hay WARN}
```

## Reglas

- No inventar valores. Si algo no se puede leer, marcar WARN con motivo.
- Respuesta breve y accionable.
- No ejecutar comandos destructivos.
