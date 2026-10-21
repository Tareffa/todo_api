# Todo API

Uma API RESTful para gerenciar quadros Kanban com colunas e tarefas.

A sua aplicação precisa permitir:
* Listar, criar, alterar e excluir quadros;
* dentro dos quadros, listar (em ordem), criar, alterar, mover (horizontalmente) e excluir colunas;
* dentro das colunas, listar (em ordem), criar, alterar, mover (vertical e horizontalmente) e excluir tarefas.

# Candidatos a desenvolvedor BackEnd:
> Desenvolva uma API, em Java Spring, que se adeque à documentação abaixo, siga as melhores práticas do mercado.
> Em seguida desenvolva testes unitários para todos os métodos da sua aplicação.
* Candidatos a BackEnd deverão receber apenas o README.md para construir a aplicação do zero.

# Candidatos a desenvolvedor FrontEnd:

> #### Não se preocupe com o código interno da API que você recebeu, você apenas precisa criar um frontend (preferencialmente na versão mais recente do Angular) que a consuma
> Sua aplicação deve ser 100% funcional tanto online quanto offline. Os dados devem ser salvos localmente e, havendo conexão com a internet, na API.
Após a conexão ser reestabelecida, os dados devem ser sincronizados
>
>
>
> ## 🚀 Como Executar
>
> ### Opção 1: Com Docker Compose (Recomendado)
>
> ```bash
> docker compose up
> ```
>
> A API estará disponível em `http://localhost:8080`
>
> ### Opção 2: Compilar e Rodar Localmente
>
> **Pré-requisitos:**
> - Hive (`hivec`) v0.2.16
> - Go 1.24 ou superior
>
> **Instalação do Hive:**
> - Baixe o `hivec` da sua plataforma na [página da release v0.2.16](https://github.com/R0DR160HM/hive-lang/releases/tag/v0.2.16) e coloque-o no `PATH`
> - Instale o Go a partir de [go.dev/dl](https://go.dev/dl/)
>
> **Rodar o projeto:**
>
> ```bash
> hivec run todo_api.hive
> ```
>
> A API estará disponível em `http://localhost:8080`. O primeiro build baixa o driver do SQLite, então precisa de internet.
>
> Os dados ficam no arquivo `todo_api.db`, ao lado do `todo_api.hive`. As variáveis de ambiente `PORT` e `DATABASE_PATH` trocam a porta e o arquivo.
>
> **Rodar os testes:**
>
> ```bash
> hivec test .
> ```
>
> ### Opção 3: Build Manual com Docker
>
> ```bash
> docker build -t todo_api .
> docker run -p 8080:8080 todo_api
> ```
* Candidatos a FrontEnd deverão receber o projeto (API) completo para construir as aplicações web por cima.

## 📚 Documentação de Endpoints

A API usa a seguinte estrutura de dados:

### Board (Quadro)
```json
{
  "id": "number",
  "name": "string"
}
```

### Column (Coluna)
```json
{
  "id": "number",
  "name": "string",
  "position": "number",
  "boardId": "number"
}
```

### Task (Tarefa)
```json
{
  "id": "number",
  "name": "string",
  "position": "number",
  "createdAt": "string (ISO 8601)",
  "dueDate": "string (ISO 8601)",
  "completed": "boolean",
  "tags": ["string"],
  "columnId": "number"
}
```

### Posições

`position` é o índice da coluna no quadro, ou da tarefa na coluna, começando em `0`. Ao criar ou alterar, a coluna (ou tarefa) entra nessa posição e as demais se reorganizam. Uma posição maior que o tamanho da lista a coloca no fim, e uma negativa, no início. A resposta traz a posição que ela de fato ocupou.

Excluir um quadro exclui as colunas dele, e excluir uma coluna exclui as tarefas dela.

---

## 🎯 Endpoints de Board

### Listar todos os quadros
```
GET /api/v1/board
```

**Resposta (200):**
```json
[
  {
    "id": 1,
    "name": "Projeto A"
  }
]
```

---

### Criar novo quadro
```
POST /api/v1/board
```

**Body:**
```json
{
  "name": "Projeto A"
}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "Projeto A"
}
```

**Erro (400):** Body inválido

---

### Atualizar quadro
```
PUT /api/v1/board/{board_id}
```

**Body:**
```json
{
  "name": "Projeto A Atualizado"
}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "Projeto A Atualizado"
}
```

**Erro (400):** Body inválido

**Erro (404):** Quadro não encontrado

---

### Deletar quadro
```
DELETE /api/v1/board/{board_id}
```

**Resposta (200):**
```json
{
  "status": "ok"
}
```

**Erro (404):** Quadro não encontrado

---

## 🗂️ Endpoints de Column (Coluna)

### Listar colunas de um quadro
```
GET /api/v1/column/from/{board_id}
```

**Resposta (200):**
```json
[
  {
    "id": 1,
    "name": "A Fazer",
    "position": 0,
    "boardId": 1
  },
  {
    "id": 2,
    "name": "Fazendo",
    "position": 1,
    "boardId": 1
  }
]
```

---

### Criar nova coluna
```
POST /api/v1/column
```

**Body:**
```json
{
  "name": "A Fazer",
  "position": 0,
  "boardId": 1
}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "A Fazer",
  "position": 0,
  "boardId": 1
}
```

**Erro (400):** Body inválido ou quadro inexistente

---

### Atualizar coluna
```
PUT /api/v1/column/{column_id}
```

**Body:**
```json
{
  "name": "A Fazer Urgente",
  "position": 0,
  "boardId": 1
}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "A Fazer Urgente",
  "position": 0,
  "boardId": 1
}
```

**Erro (400):** Body inválido ou quadro inexistente

**Erro (404):** Coluna não encontrada

---

### Deletar coluna
```
DELETE /api/v1/column/{column_id}
```

**Resposta (200):**
```json
{
  "status": "ok"
}
```

**Erro (404):** Coluna não encontrada

---

## ✅ Endpoints de Task (Tarefa)

### Listar tarefas de uma coluna
```
GET /api/v1/task/from/{column_id}
```

**Resposta (200):**
```json
[
  {
    "id": 1,
    "name": "Implementar autenticação",
    "position": 0,
    "createdAt": "2026-02-05T10:00:00Z",
    "dueDate": "2026-02-10T23:59:59Z",
    "completed": false,
    "tags": ["backend", "segurança"],
    "columnId": 1
  }
]
```

---

### Criar nova tarefa
```
POST /api/v1/task
```

**Body:**
```json
{
  "name": "Implementar autenticação",
  "position": 0,
  "createdAt": "2026-02-05T10:00:00Z",
  "dueDate": "2026-02-10T23:59:59Z",
  "completed": false,
  "tags": ["backend", "segurança"],
  "columnId": 1
}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "Implementar autenticação",
  "position": 0,
  "createdAt": "2026-02-05T10:00:00Z",
  "dueDate": "2026-02-10T23:59:59Z",
  "completed": false,
  "tags": ["backend", "segurança"],
  "columnId": 1
}
```

**Erro (400):** Body inválido ou coluna inexistente

---

### Atualizar tarefa
```
PUT /api/v1/task/{task_id}
```

**Body:**
```json
{
  "name": "Implementar autenticação",
  "position": 0,
  "createdAt": "2026-02-05T10:00:00Z",
  "dueDate": "2026-02-10T23:59:59Z",
  "completed": true,
  "tags": ["backend", "segurança"],
  "columnId": 1
}
```

**Resposta (200):**
```json
{
  "id": 1,
  "name": "Implementar autenticação",
  "position": 0,
  "createdAt": "2026-02-05T10:00:00Z",
  "dueDate": "2026-02-10T23:59:59Z",
  "completed": true,
  "tags": ["backend", "segurança"],
  "columnId": 1
}
```

**Erro (400):** Body inválido ou coluna inexistente

**Erro (404):** Tarefa não encontrada

---

### Deletar tarefa
```
DELETE /api/v1/task/{task_id}
```

**Resposta (200):**
```json
{
  "status": "ok"
}
```

**Erro (404):** Tarefa não encontrada

---



# Boa sorte e boa competência.
