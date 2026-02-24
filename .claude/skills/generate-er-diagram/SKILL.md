---
name: generate-er-diagram
description: Generate an ER diagram from database model code (SQLAlchemy, Prisma, Django, TypeORM, etc.).
argument-hint: <path>
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(npx *)
---

## Your Task

Read all database model files from a given path, analyze the entities, attributes, and relationships, and generate a Mermaid ER diagram. Render the diagram to SVG using mermaid-cli and output a textual explanation of the data model. Do NOT output the Mermaid diagram code in the response — refer the user to the generated files instead.

## Arguments

```
${ARGUMENTS}
```

## Steps

1. Use the Glob tool to find all model/schema files in the provided path. Look for common patterns:
   - Python: `**/*.py` (look for SQLAlchemy, Django, Peewee, Tortoise ORM model definitions)
   - TypeScript/JavaScript: `**/schema.prisma`, `**/*.entity.ts`, `**/*.model.ts`, `**/*.model.js`
   - Go: `**/*.go` (look for GORM, Ent struct definitions)
   - Ruby: `**/app/models/**/*.rb`, `**/db/schema.rb`
   - Java/Kotlin: `**/*.java`, `**/*.kt` (look for JPA/Hibernate `@Entity` annotations)
   - Rust: `**/*.rs` (look for Diesel or SeaORM model definitions)
   - SQL: `**/*.sql` (look for `CREATE TABLE` statements)

   If no model files are found, inform the user and stop.

2. Read all discovered model files to understand the full data model. Pay special attention to:
   - Class/struct/table definitions that represent entities
   - Field/column definitions with their types and constraints (primary key, not null, unique, default values)
   - Relationship definitions (one-to-one, one-to-many, many-to-many) through foreign keys, association tables, or ORM relationship decorators
   - Enums that are referenced by model fields
   - Inheritance hierarchies (e.g., single-table inheritance, polymorphic models)

3. Analyze the data model by identifying all entities, their attributes, and relationships:
   - **Entities** — Each model/table becomes an entity
   - **Attributes** — Each column/field becomes an attribute with its type normalized to a generic form (see type mapping below)
   - **Primary keys** — Mark with `PK`
   - **Foreign keys** — Mark with `FK`
   - **Unique constraints** — Mark with `UK`
   - **Relationships** — Determine cardinality from foreign keys, ORM decorators, and association/join tables:
     - `||--||` one-to-one (exactly one)
     - `||--o|` one-to-zero-or-one (optional one)
     - `||--|{` one-to-many (one or more)
     - `||--o{` one-to-zero-or-more (optional many)
     - `}|--|{` many-to-many

4. Generate a Mermaid `erDiagram` following the standards defined in the additional resources section below.

5. Render the diagram:
   - Write the Mermaid code to `<path>/er-diagram.mmd`
   - Run: `npx -p @mermaid-js/mermaid-cli@latest mmdc -i <path>/er-diagram.mmd -o <path>/er-diagram.svg --quiet`
   - If the render fails, still output the Mermaid source path so the user can debug

6. Output a textual explanation of the data model covering:
   - Total number of entities and relationships discovered
   - Core entities and their purpose
   - Key relationships and their cardinality (especially many-to-many join tables)
   - Notable patterns (e.g., soft deletes, audit timestamps, polymorphic associations, self-referential relationships)
   - Confirm the file paths for the generated `.mmd` and `.svg` files

## Additional Resources

### Type Mapping

Normalize ORM-specific and database-specific types to these generic types for diagram consistency:

| Generic Type   | Maps From                                                                |
|----------------|--------------------------------------------------------------------------|
| `string`       | `String`, `VARCHAR`, `TEXT`, `CHAR`, `str`, `CharField`, `TextField`     |
| `int`          | `Integer`, `INT`, `BIGINT`, `SMALLINT`, `Int`, `IntegerField`           |
| `float`        | `Float`, `DOUBLE`, `DECIMAL`, `NUMERIC`, `Real`, `FloatField`           |
| `bool`         | `Boolean`, `BOOLEAN`, `BIT`, `BooleanField`                             |
| `datetime`     | `DateTime`, `TIMESTAMP`, `DATETIME`, `DateTimeField`                    |
| `date`         | `Date`, `DATE`, `DateField`                                             |
| `time`         | `Time`, `TIME`, `TimeField`                                             |
| `uuid`         | `UUID`, `Uuid`, `UUIDField`                                             |
| `json`         | `JSON`, `JSONB`, `JsonField`, `Dict`                                    |
| `binary`       | `BLOB`, `BYTEA`, `LargeBinary`, `Bytes`, `BinaryField`                 |
| `enum`         | `Enum`, `ENUM`, use the actual enum name where possible                 |
| `array`        | `ARRAY`, `List`, arrays of other types                                  |

### Diagram Standards

#### Entity Format

```
erDiagram
    ENTITY_NAME {
        type attribute_name PK "comment"
        type attribute_name FK
        type attribute_name UK
        type attribute_name
    }
```

- Entity names use `UPPER_SNAKE_CASE`
- Attribute names use `lower_snake_case`
- Always include `PK`, `FK`, and `UK` markers where applicable
- Use the `"comment"` field for additional context (e.g., `"auto-generated"`, `"soft delete"`, enum name)

#### Relationship Format

```
ENTITY_A ||--o{ ENTITY_B : "relationship_label"
```

- Always include a descriptive relationship label (e.g., `"has"`, `"belongs to"`, `"authored by"`)
- For many-to-many relationships implemented via join tables, show both relationships through the join table rather than a direct many-to-many edge, unless the join table has no additional attributes
- For self-referential relationships, show the entity relating to itself with a descriptive label (e.g., `EMPLOYEE ||--o| EMPLOYEE : "manages"`)

#### Layout Tips

- Order entities so that parent/referenced entities appear before child/referencing entities
- Group related entities together (e.g., user-related tables, order-related tables)
- Keep join/association tables near the entities they connect
