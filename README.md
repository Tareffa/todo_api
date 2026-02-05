# Todo API

Uma API RESTful para gerenciar quadros Kanban com colunas e tarefas.

# Candidatos a desenvolvedor BackEnd:
> Desenvolva uma API, em Java Spring, que se adeque à documentação abaixo, siga as melhores práticas do mercado.
> Em seguida desenvolva testes unitários para todos os métodos da sua aplicação.
* Candidatos a BackEnd deverão receber apenas o README.md para construir a aplicação do zero.

# Candidatos a desenvolvedor FrontEnd:

> #### Não se preocupe com o código interno da API que você recebeu, você apenas precisa criar um frontend (preferencialmente na versão mais recente do Angular) que a consuma
> A sua aplicação precisa permitir:
> * Exibir, criar, alterar e excluir quadros;
> * dentro dos quadros, exibir (em ordem), criar, alterar, mover (horizontalmente) e excluir colunas;
> * dentro das colunas, exibir (em ordem), criar, alterar, mover (vertical e horizontalmente) e excluir tarefas.
>
> Além disso, sua aplicação deve ser 100% funcional tanto online quanto offline. Os dados devem ser salvos localmente e, havendo conexão com a internet, na API.
Após a conexão ser reestabelecida, os dados devem ser sincronizados
> 
> 
> 
> ## 🚀 Como Executar
> 
> ### Opção 1: Com Docker Compose (Recomendado)
> 
> ```bash
> docker-compose up
> ```
> 
> A API estará disponível em `http://> localhost:8080`
> 
> ### Opção 2: Compilar e Rodar Localmente
> 
> **Pré-requisitos:**
> - Gleam 1.14.0
> - Erlang 27 ou superior
> 
> **Instalação do Gleam:**
> - Visite [gleam.run](https://gleam.run/getting-started/installing/) para instruções de instalação
> 
> **Rodar o projeto:**
> 
> ```bash
> gleam run
> ```
> 
> A API estará disponível em `http://> localhost:8080`
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
  "id": "string",
  "name": "string"
}
```

### Column (Coluna)
```json
{
  "id": "string",
  "name": "string",
  "position": "number",
  "boardId": "string"
}
```

### Task (Tarefa)
```json
{
  "id": "string",
  "name": "string",
  "position": "number",
  "createdAt": "string (ISO 8601)",
  "dueDate": "string (ISO 8601)",
  "completed": "boolean",
  "tags": ["string"],
  "columnId": "string"
}
```

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
    "id": "board-1",
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
  "id": "board-1",
  "name": "Projeto A"
}
```

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
  "id": "board-1",
  "name": "Projeto A Atualizado"
}
```

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
    "id": "column-1",
    "name": "A Fazer",
    "position": 0,
    "boardId": "board-1"
  },
  {
    "id": "column-2",
    "name": "Fazendo",
    "position": 1,
    "boardId": "board-1"
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
  "boardId": "board-1"
}
```

**Resposta (200):**
```json
{
  "id": "column-1",
  "name": "A Fazer",
  "position": 0,
  "boardId": "board-1"
}
```

**Erro (400):** Body inválido

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
  "boardId": "board-1"
}
```

**Resposta (200):**
```json
{
  "id": "column-1",
  "name": "A Fazer Urgente",
  "position": 0,
  "boardId": "board-1"
}
```

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
    "id": "task-1",
    "name": "Implementar autenticação",
    "position": 0,
    "createdAt": "2026-02-05T10:00:00Z",
    "dueDate": "2026-02-10T23:59:59Z",
    "completed": false,
    "tags": ["backend", "segurança"],
    "columnId": "column-1"
  }
]
```

---

### Criar nova tarefa
```
POST /api/v1/task/from/{column_id}
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
  "columnId": "column-1"
}
```

**Resposta (200):**
```json
{
  "id": "task-1",
  "name": "Implementar autenticação",
  "position": 0,
  "createdAt": "2026-02-05T10:00:00Z",
  "dueDate": "2026-02-10T23:59:59Z",
  "completed": false,
  "tags": ["backend", "segurança"],
  "columnId": "column-1"
}
```

**Erro (400):** Body inválido

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
  "columnId": "column-1"
}
```

**Resposta (200):**
```json
{
  "id": "task-1",
  "name": "Implementar autenticação",
  "position": 0,
  "createdAt": "2026-02-05T10:00:00Z",
  "dueDate": "2026-02-10T23:59:59Z",
  "completed": true,
  "tags": ["backend", "segurança"],
  "columnId": "column-1"
}
```

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
