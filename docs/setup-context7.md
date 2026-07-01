# Setup: Context7

Context7 provee documentacion actualizada de librerias y frameworks via semantic search. Se ejecuta con npx, sin instalacion adicional.

## Prerequisitos

- Node.js v18+
- Acceso a internet (para npm registry y API de Context7)

## Configuracion MCP

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

## Verificacion

```bash
npx -y @upstash/context7-mcp --help
```

Si responde sin error, esta listo.

## Tools disponibles

| Tool | Funcion |
|---|---|
| `resolve-library-id` | Busca library ID compatible con Context7 |
| `query-docs` | Consulta documentacion con examples de codigo |

## Uso tipico

```
1. resolve-library-id(libraryName: "React", query: "hooks")
   -> /facebook/react

2. query-docs(libraryId: "/facebook/react", query: "useEffect cleanup")
   -> Documentacion + code snippets
```

## Troubleshooting

| Problema | Solucion |
|---|---|
| `npx` no responde | Verificar Node.js, abrir terminal nueva |
| Timeout en Context7 | Verificar internet, reintentar en siguiente ciclo |
| "package not found" | `npx clear-npx-cache` y reintentar |
| Rate limit | Esperar y reintentar, reducir frecuencia |

## Politica de uso en el kit

- Se refresca cada 4 consultas del usuario (automatico via steering)
- Si hay incertidumbre tecnica, se consulta de inmediato
- Si no responde, se continua con Engram + contexto local
- No bloquea trabajo si esta inaccesible
