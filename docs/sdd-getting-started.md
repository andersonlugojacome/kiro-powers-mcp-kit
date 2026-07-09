# Guía de Inicio: SDD (Spec-Driven Development)

> De cero a tu primer cambio completado con el framework SDD.

## Qué es SDD en 30 segundos

SDD es un proceso que te obliga a PENSAR antes de CODEAR. En vez de pedirle al agente "haceme un login" y que tire código al azar, SDD fuerza este orden:

1. **Definir QUÉ** (spec) → qué debe hacer exactamente
2. **Definir CÓMO** (design) → qué arquitectura y patrones usar
3. **Descomponer** (tasks) → en pasos concretos y secuenciales
4. **Implementar** (apply) → código guiado por las specs
5. **Verificar** (verify) → comprobar que cumple con lo definido
6. **Archivar** (archive) → persistir el conocimiento

El resultado: menos rework, código alineado con specs, y memoria entre sesiones.

---

## Prerequisitos

### 1. Tener Kiro instalado

- [Kiro IDE](https://kiro.dev) o Kiro CLI

### 2. Instalar el Power

1. Abrir Kiro → Panel de Powers → **Add Custom Power**
2. Seleccionar **Import power from GitHub**
3. URL: `https://github.com/andersonlugojacome/kiro-powers-mcp-kit`
4. Click **Install**

### 3. Instalar Engram GO (memoria persistente)

```bash
# macOS
brew install gentleman-programming/tap/engram

# Windows (scoop)
scoop bucket add engram https://github.com/Gentleman-Programming/scoop-bucket
scoop install engram

# Verificar
engram --version
```

### 4. Tener Node.js 18+ (para Context7)

```bash
node --version  # debe ser >= 18
```

### 5. Verificar que todo funciona

En Kiro, escribí: **"estatus"** — te mostrará el estado de los MCP servers.

---

## Tu primer cambio con SDD (paso a paso)

Vamos a hacer un cambio real en tu proyecto. Puede ser nuevo o existente.

---

### Paso 1: Inicializar SDD en tu proyecto

Escribí en Kiro:

```
/sdd-init
```

**Qué hace**: Escanea tu proyecto, detecta el stack (Java, Python, Node, Angular, React), identifica el test runner, y cachea esta info para todas las fases futuras.

**Resultado**: Se guarda en Engram el contexto del proyecto. No necesitás volver a hacerlo.

---

### Paso 2: Decidir qué cambiar

Tenés dos caminos:

**Camino A — Explorar primero** (recomendado si no tenés claro qué hacer):

```
/sdd-explore <tema>
```

Ejemplo: `/sdd-explore mejorar manejo de errores en el módulo de pagos`

Esto investiga tu codebase, compara alternativas, y te da opciones.

**Camino B — Ir directo** (si ya sabés qué querés):

Pasá al Paso 3.

---

### Paso 3: Crear la propuesta de cambio

```
/sdd-new <nombre-del-cambio>
```

Ejemplo: `/sdd-new error-handling-pagos`

**Qué hace**: Crea una propuesta formal con:
- **Intent** — por qué se hace este cambio
- **Scope** — qué archivos/módulos toca
- **Approach** — cómo se va a resolver

**Importante**: Kiro te va a MOSTRAR la propuesta y ESPERAR tu aprobación. Revisala. Si no te convence, decile qué ajustar.

---

### Paso 4: Generar specs + design + tasks (fast-forward)

Si la propuesta te parece bien y querés avanzar rápido:

```
/sdd-ff <nombre-del-cambio>
```

Ejemplo: `/sdd-ff error-handling-pagos`

**Qué hace** (en secuencia automática):
1. **Spec** → Requisitos verificables con escenarios Given/When/Then
2. **Design** → Decisiones de arquitectura, patrones, archivos a modificar
3. **Tasks** → Tareas ordenadas por lotes (Phase 1, Phase 2, etc.)

**Alternativa manual** (si querés revisar cada fase):

```
/sdd-continue error-handling-pagos
```

Esto ejecuta la SIGUIENTE fase pendiente y te pide aprobación antes de continuar.

---

### Paso 5: Implementar

```
/sdd-apply error-handling-pagos
```

**Qué hace**: Toma las tareas del Phase 1 y las implementa una por una, siguiendo las specs y el design. Si tu proyecto tiene TDD habilitado, escribe tests PRIMERO (Red → Green → Refactor).

**El Execution Loop Controller (ELC)** entra en acción aquí:
- Si una tarea falla verificación, el ELC decide si hacer PATCH (fix encima) o ROLLBACK (empezar con approach diferente)
- Máximo 3 intentos por tarea — si no se resuelve, te escala con contexto
- Cada fallo se comprime como restricción para el siguiente intento

**Nota**: Apply puede ejecutarse en LOTES. Si hay 6 tareas en 2 fases, primero implementa Phase 1 (tareas 1.1-1.3) y después Phase 2 (tareas 2.1-2.3).

---

### Paso 6: Verificar

```
/sdd-verify error-handling-pagos
```

**Qué hace**:
1. Ejecuta el build de tu proyecto
2. Corre los tests
3. Compara la implementación contra las specs (Compliance Matrix)
4. Reporta: CRITICAL / WARNING / SUGGESTION

**Resultado**: Un reporte con veredicto PASS, PASS WITH WARNINGS, o FAIL.

- Si **PASS** → podés archivar
- Si **FAIL** → volvé a apply (el ELC maneja esto automáticamente en la mayoría de casos)

---

### Paso 7: Archivar

```
/sdd-archive error-handling-pagos
```

**Qué hace**: Cierra el cambio, persiste todos los artefactos en Engram, y documenta las lecciones aprendidas. Tu próxima sesión va a poder recuperar toda esta info.

---

## Resumen visual del flujo

```
┌─────────────────────────────────────────────────────────────────┐
│                         SDD WORKFLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  /sdd-init          → Detecta tu stack (1 sola vez)             │
│       │                                                         │
│       ▼                                                         │
│  /sdd-explore       → (Opcional) Investiga alternativas         │
│       │                                                         │
│       ▼                                                         │
│  /sdd-new           → Propuesta: qué, por qué, cómo            │
│       │                                                         │
│       ▼                                                         │
│  /sdd-ff            → Spec + Design + Tasks (automático)        │
│       │                                                         │
│       ▼                                                         │
│  /sdd-apply         → Implementa por lotes                      │
│       │                                                         │
│       ▼                                                         │
│  /sdd-verify        → Valida contra specs                       │
│       │                                                         │
│       ▼                                                         │
│  /sdd-archive       → Cierra y persiste                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Modos de ejecución

Cuando invocás un flujo SDD por primera vez, Kiro te pregunta:

### Modo interactivo vs automático

| Modo | Comportamiento |
|------|----------------|
| **Interactive** (default) | Pausa después de cada fase para que revises y apruebes |
| **Automatic** | Ejecuta todas las fases sin pausar — para cuando confiás en el proceso |

### Artifact store

| Modo | Dónde se guardan los artefactos |
|------|--------------------------------|
| **engram** (default) | En memoria persistente — recuperable entre sesiones |
| **openspec** | En archivos locales (`openspec/`) — committeable con git |
| **hybrid** | Ambos — máxima durabilidad |

---

## Comandos rápidos de referencia

| Comando | Qué hace |
|---------|----------|
| `/sdd-init` | Inicializa contexto del proyecto (1 sola vez) |
| `/sdd-explore <tema>` | Investiga alternativas antes de decidir |
| `/sdd-new <cambio>` | Crea propuesta de cambio |
| `/sdd-ff <cambio>` | Fast-forward: spec → design → tasks sin pausas |
| `/sdd-continue <cambio>` | Ejecuta la siguiente fase pendiente |
| `/sdd-apply <cambio>` | Implementa tareas por lotes |
| `/sdd-verify <cambio>` | Valida implementación contra specs |
| `/sdd-archive <cambio>` | Cierra y archiva el cambio |

---

## Preguntas frecuentes

### ¿Necesito usar SDD para TODO?

No. SDD es para cambios medianos a grandes (múltiples archivos, lógica nueva, features). Para un typo, un one-liner, o un config change, simplemente pedile a Kiro que lo haga directamente.

### ¿Qué pasa si me equivoqué en la spec?

Podés re-ejecutar cualquier fase. Los artefactos se actualizan (upsert) — no se duplican.

### ¿Puedo usar SDD en un proyecto vacío?

Sí. `/sdd-init` detecta que no hay código y adapta el contexto. Luego podés usar `/sdd-new scaffold-inicial` para crear la estructura base.

### ¿Qué pasa entre sesiones?

Todo queda en Engram. La próxima vez que abrás Kiro, escribí `/sdd-continue <cambio>` y retoma donde dejaste.

### ¿Qué es el Execution Loop Controller?

Es el motor que evita loops infinitos cuando algo falla. Si la implementación no pasa verificación:
1. Comprime el error a una restricción
2. Decide si hacer fix encima (PATCH) o empezar de nuevo (ROLLBACK)
3. Reintenta con la restricción como regla obligatoria
4. Máximo 3 intentos — si no se resuelve, te muestra el contexto para que decidas vos

### ¿Funciona con mi proyecto en [lenguaje X]?

Soporta: Java (Spring Boot), Python (FastAPI), Node.js (Express/Fastify), Angular, React. El `/sdd-init` detecta tu stack automáticamente.

---

## Ejemplo real: de idea a código

```
Vos:     /sdd-init
Kiro:    ✅ Proyecto detectado: Node.js + Express + Jest. TDD mode: active.

Vos:     /sdd-new rate-limiting-api
Kiro:    📋 Propuesta creada:
         - Intent: Proteger endpoints de abuso
         - Scope: middleware de Express
         - Approach: express-rate-limit con Redis store
         ¿Aprobás? (sí/no/ajustar)

Vos:     sí

Vos:     /sdd-ff rate-limiting-api
Kiro:    📝 Spec: 3 requisitos, 7 escenarios
         🏗️ Design: middleware pattern, Redis adapter
         📋 Tasks: 2 fases, 5 tareas
         ¿Aprobás para implementar?

Vos:     dale

Vos:     /sdd-apply rate-limiting-api
Kiro:    ✅ Phase 1 completado (3/3 tareas)
         🔴→🟢→♻️ TDD cycles passed
         Listo para Phase 2 o verify?

Vos:     /sdd-verify rate-limiting-api
Kiro:    ## Verification Report
         Build: ✅ | Tests: ✅ 12/12 | Compliance: 7/7 scenarios
         Verdict: PASS
         ¿Archivamos?

Vos:     /sdd-archive rate-limiting-api
Kiro:    ✅ Cambio archivado. Lecciones persistidas en Engram.
```

---

## Siguiente paso

Abrí Kiro en tu proyecto y escribí:

```
/sdd-init
```

Después de eso, pensá en un cambio pequeño que quieras hacer y probá el flujo completo. La primera vez toma ~10 minutos. Después de entender el proceso, cada cambio estructurado te ahorra horas de rework.
