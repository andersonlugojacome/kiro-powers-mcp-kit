---
name: kiro-update-assistant
description: >
  Guia actualizaciones del Power kiro-powers-mcp-kit.
  Trigger: "actualizame", "actualiza", "update power", "update kit".
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Objetivo

Responder con pasos claros para actualizar kiro-powers-mcp-kit.

## Metodo principal: Import Power From Github

kiro-powers-mcp-kit se instala y actualiza via el mecanismo oficial de Kiro:

```
Import Power From Github
Repo: andersonlugojacome/kiro-powers-mcp-kit
Branch: main
```

Esto sincroniza automaticamente:
- `.kiro/settings/mcp.json` (merge con config existente)
- `.kiro/steering/` (steering del kit)
- `.kiro/skills/` (skills SDD + operativas)

## Comportamiento esperado

### 1. Update standard

Cuando el usuario pide actualizar:

```
1. En Kiro: Import Power From Github
2. Repo: andersonlugojacome/kiro-powers-mcp-kit
3. Branch: main
4. Reiniciar Kiro para aplicar cambios
```

### 2. Verificacion post-update

Sugerir ejecutar verificacion:

```bash
# macOS/Linux
./scripts/setup.sh --verify-only

# O pedir "estatus" para que mcp-status-assistant muestre el estado
```

### 3. Si hay problemas de Engram GO

```bash
# Actualizar Engram GO
brew upgrade gentleman-programming/tap/engram

# Verificar
engram --version
engram doctor
```

### 4. Si hay problemas de Context7

```bash
# Limpiar cache npx
npx clear-npx-cache
# Reintentar
npx -y @upstash/context7-mcp --help
```

## Formato de respuesta

```
## Actualizar kiro-powers-mcp-kit

**Metodo:** Import Power From Github
**Repo:** andersonlugojacome/kiro-powers-mcp-kit
**Branch:** main

### Pasos
1. {instruccion}
2. {instruccion}
3. Reiniciar Kiro

### Verificacion
{como confirmar que quedo OK}
```

## Reglas

- Priorizar instrucciones de una sola accion.
- SIEMPRE mencionar "Import Power From Github" como metodo oficial.
- No mencionar scripts de instalacion como metodo principal.
- Si hay WARN, sugerir "estatus" para diagnostico.
