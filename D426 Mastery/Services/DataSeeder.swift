import Foundation
import SwiftData

@MainActor
struct DataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Topic>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // MARK: - Topics
        let relationalModel = Topic(name: "Relational Model Concepts", competencyCode: "D426-C1", iconName: "circle.grid.3x3.fill", colorHex: "007AFF")
        let erDiagrams = Topic(name: "ER Diagrams & Crow's Foot", competencyCode: "D426-C2", iconName: "diagram", colorHex: "00C7BE")
        let keys = Topic(name: "Primary & Foreign Keys", competencyCode: "D426-C3", iconName: "key.fill", colorHex: "FFD60A")
        let normalization = Topic(name: "Normalization 1NF-BCNF", competencyCode: "D426-C4", iconName: "chart.bar.fill", colorHex: "FF6B6B")
        let ddl = Topic(name: "SQL DDL Commands", competencyCode: "D426-C5", iconName: "hammer.fill", colorHex: "AF52DE")
        let dml = Topic(name: "SQL DML Commands", competencyCode: "D426-C6", iconName: "terminal.fill", colorHex: "30D158")
        let models = Topic(name: "Conceptual/Logical/Physical Models", competencyCode: "D426-C7", iconName: "square.3.layers.3d", colorHex: "FF9F0A")
        let dbms = Topic(name: "DBMS Architecture", competencyCode: "D426-C8", iconName: "server.rack", colorHex: "64D2FF")

        let allTopics = [relationalModel, erDiagrams, keys, normalization, ddl, dml, models, dbms]
        for t in allTopics { context.insert(t) }

        seedFlashcards(context: context, relationalModel: relationalModel, erDiagrams: erDiagrams, keys: keys, normalization: normalization, ddl: ddl, dml: dml, models: models, dbms: dbms)
        seedQuizQuestions(context: context, relationalModel: relationalModel, erDiagrams: erDiagrams, keys: keys, normalization: normalization, ddl: ddl, dml: dml, models: models, dbms: dbms)
        seedGlossary(context: context)
        seedSampleDatabases(context: context)

        // Insert initial user progress
        context.insert(UserProgress())
        try? context.save()
    }

    // MARK: - Flashcards
    private static func seedFlashcards(context: ModelContext, relationalModel: Topic, erDiagrams: Topic, keys: Topic, normalization: Topic, ddl: Topic, dml: Topic, models: Topic, dbms: Topic) {

        // --- Relational Model Concepts (50+ cards) ---
        let rmCards: [(String, String, [String])] = [
            ("What is a relation in the relational model?", "A relation is a two-dimensional table consisting of rows (tuples) and columns (attributes) with a specific name.", ["relation", "table"]),
            ("What is a tuple?", "A tuple is a single row in a relation, representing one record or instance of the entity.", ["tuple", "row"]),
            ("What is an attribute in the relational model?", "An attribute is a named column of a relation that represents a property of the entity.", ["attribute", "column"]),
            ("What is the domain of an attribute?", "The domain is the set of all allowable values that an attribute can hold. For example, the domain of 'age' might be positive integers 0-150.", ["domain"]),
            ("What is the degree of a relation?", "The degree is the number of attributes (columns) in a relation.", ["degree"]),
            ("What is the cardinality of a relation?", "The cardinality is the number of tuples (rows) in a relation.", ["cardinality"]),
            ("Who is considered the father of the relational model?", "Edgar F. Codd, who published 'A Relational Model of Data for Large Shared Data Banks' in 1970.", ["Codd", "history"]),
            ("What is relational algebra?", "A procedural query language that uses operators (select, project, join, union, etc.) to manipulate relations and produce new relations.", ["relational algebra"]),
            ("What is the SELECT operation in relational algebra?", "The SELECT operation (σ) filters tuples from a relation based on a specified condition/predicate.", ["relational algebra", "select"]),
            ("What is the PROJECT operation in relational algebra?", "The PROJECT operation (π) selects specific columns from a relation, removing duplicates from the result.", ["relational algebra", "project"]),
            ("What is relational calculus?", "A non-procedural query language that specifies what data to retrieve without specifying how to retrieve it. It uses tuple or domain calculus.", ["relational calculus"]),
            ("What is the difference between relational algebra and relational calculus?", "Relational algebra is procedural (specifies how), while relational calculus is non-procedural/declarative (specifies what). Both are equivalent in expressive power.", ["comparison"]),
            ("What is a relation schema?", "A relation schema defines the structure of a relation: its name, attributes, and the domains of those attributes. Example: Student(ID, Name, GPA).", ["schema"]),
            ("What is a relation instance?", "A relation instance is the set of tuples in a relation at a particular point in time. It changes as data is inserted, updated, or deleted.", ["instance"]),
            ("What is the Cartesian Product operation?", "The Cartesian Product (×) combines every tuple from one relation with every tuple from another, producing all possible pairs.", ["relational algebra", "cartesian"]),
            ("What is the UNION operation in relational algebra?", "UNION (∪) combines tuples from two union-compatible relations, removing duplicates.", ["relational algebra", "union"]),
            ("What does union-compatible mean?", "Two relations are union-compatible if they have the same number of attributes and corresponding attributes have compatible domains.", ["union-compatible"]),
            ("What is the DIFFERENCE operation?", "DIFFERENCE (−) returns tuples that are in the first relation but not in the second. Both relations must be union-compatible.", ["relational algebra", "difference"]),
            ("What is the INTERSECTION operation?", "INTERSECTION (∩) returns tuples that appear in both relations. Both must be union-compatible.", ["relational algebra", "intersection"]),
            ("What is the NATURAL JOIN operation?", "Natural Join combines two relations by matching tuples with equal values on all common attributes, removing duplicate columns.", ["relational algebra", "join"]),
            ("What is a NULL value in the relational model?", "NULL represents a missing, unknown, or inapplicable value. It is not the same as zero or an empty string.", ["null"]),
            ("What is the closed world assumption?", "The assumption that if a fact is not recorded in the database, it is considered false. Only explicitly stored facts are true.", ["theory"]),
            ("What is a base relation?", "A base relation (base table) is a named relation that physically stores data, as opposed to a view which is derived.", ["base relation"]),
            ("What is a derived relation?", "A derived relation (view) is a virtual table defined by a query over base relations. It does not store data independently.", ["view", "derived"]),
            ("What are Codd's 12 rules?", "A set of 13 rules (numbered 0-12) that define requirements for a DBMS to be considered fully relational, including information rule, guaranteed access, systematic treatment of nulls, etc.", ["Codd", "rules"]),
            ("What is Codd's Rule 0 (Foundation Rule)?", "A relational DBMS must manage its stored data using only its relational capabilities.", ["Codd"]),
            ("What is Codd's Rule 1 (Information Rule)?", "All information in a relational database is represented explicitly at the logical level in exactly one way – by values in tables.", ["Codd"]),
            ("What is the entity integrity rule?", "No primary key attribute may contain a NULL value. Every tuple must be uniquely identifiable.", ["integrity"]),
            ("What is the referential integrity rule?", "A foreign key value must either match a primary key value in the referenced relation or be NULL.", ["integrity"]),
            ("What is a relational database?", "A database structured according to the relational model, where data is organized into tables (relations) with rows and columns.", ["fundamentals"]),
            ("What is data independence?", "The ability to change the schema at one level without affecting the schema at the next higher level. There are logical and physical data independence.", ["data independence"]),
            ("What is an intension vs extension?", "Intension (schema) is the permanent structure definition. Extension (instance) is the actual data content at a point in time.", ["theory"]),
            ("What is a unary relation?", "A relation with only one attribute (degree of 1).", ["degree"]),
            ("What is a binary relation?", "A relation with exactly two attributes (degree of 2).", ["degree"]),
            ("What is a ternary relation?", "A relation with exactly three attributes (degree of 3).", ["degree"]),
            ("What is the DIVISION operation?", "Division returns tuples from one relation that are associated with every tuple in another relation. Used for 'for all' type queries.", ["relational algebra"]),
            ("What is the RENAME operation?", "RENAME (ρ) changes the name of a relation or its attributes without altering data.", ["relational algebra"]),
            ("What is a theta join?", "A join that combines tuples from two relations based on any comparison condition (=, <, >, ≤, ≥, ≠), not just equality.", ["join"]),
            ("What is an equijoin?", "A theta join where the comparison condition uses only equality (=). It retains both join columns.", ["join"]),
            ("What is a semijoin?", "A join that returns only the tuples from the first relation that have a matching tuple in the second relation.", ["join"]),
            ("What is an outer join?", "A join that preserves tuples that have no match. Types: LEFT (keeps all from left), RIGHT (keeps all from right), FULL (keeps all from both).", ["join"]),
            ("What is domain integrity?", "The requirement that all values in an attribute must come from the attribute's defined domain.", ["integrity"]),
            ("What is a view?", "A virtual table that is derived from a query on one or more base tables. It does not store data itself.", ["view"]),
            ("Can a view be updated?", "Some simple views can be updated, but views with joins, aggregation, DISTINCT, GROUP BY, or calculated columns are generally not updatable.", ["view"]),
            ("What is a materialized view?", "A view whose results are physically stored and periodically refreshed, improving query performance at the cost of storage and freshness.", ["view"]),
            ("What is a self-join?", "A join where a table is joined with itself, typically using aliases. Useful for comparing rows within the same table.", ["join"]),
            ("What is the difference between a key and a superkey?", "A superkey is any set of attributes that uniquely identifies tuples. A key is a minimal superkey — no attribute can be removed while maintaining uniqueness.", ["keys"]),
            ("What is an atomic value?", "A value that cannot be further divided. First Normal Form requires all attribute values to be atomic.", ["normalization", "atomic"]),
            ("What is a composite attribute?", "An attribute that can be subdivided into smaller parts. Example: 'Full Name' can be split into 'First Name' and 'Last Name'.", ["attribute"]),
            ("What is a multi-valued attribute?", "An attribute that can hold multiple values for a single entity. Example: a person may have multiple phone numbers.", ["attribute"]),
            ("What is a stored vs derived attribute?", "A stored attribute is directly recorded. A derived attribute is computed from other attributes (e.g., age derived from birth date).", ["attribute"]),
        ]
        for c in rmCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: relationalModel, tags: c.2))
        }

        // --- ER Diagrams & Crow's Foot (50+ cards) ---
        let erCards: [(String, String, [String])] = [
            ("What is an Entity-Relationship (ER) Diagram?", "A graphical representation of entities, their attributes, and the relationships between them. Used during database design.", ["ER diagram"]),
            ("What is an entity in an ER diagram?", "An object or concept about which data is stored. Represented as a rectangle. Examples: Student, Course, Employee.", ["entity"]),
            ("What is an entity set?", "A collection of similar entities, like all students. In the relational model, it maps to a table.", ["entity"]),
            ("What is a strong entity?", "An entity that can exist independently and has its own primary key. Represented by a single-border rectangle.", ["entity"]),
            ("What is a weak entity?", "An entity that cannot exist without a related strong entity and lacks a complete primary key. Represented by a double-border rectangle.", ["weak entity"]),
            ("What is a partial key (discriminator)?", "An attribute of a weak entity that, combined with the owner entity's primary key, uniquely identifies weak entity instances.", ["weak entity", "partial key"]),
            ("What is an identifying relationship?", "A relationship between a weak entity and its owner entity. The weak entity's existence depends on this relationship. Drawn with a double diamond.", ["weak entity", "relationship"]),
            ("What are the types of attributes in ER diagrams?", "Simple, composite, multivalued, derived, and key attributes. Each has a distinct notation.", ["attributes"]),
            ("How is a simple attribute represented?", "An oval connected to its entity with a line.", ["notation"]),
            ("How is a composite attribute represented?", "An oval that branches into sub-ovals for its component parts.", ["notation"]),
            ("How is a multivalued attribute represented?", "A double-bordered oval.", ["notation"]),
            ("How is a derived attribute represented?", "A dashed oval. Example: age derived from date_of_birth.", ["notation"]),
            ("How is a key attribute represented?", "An oval with the attribute name underlined.", ["notation"]),
            ("What is a relationship in an ER diagram?", "An association between two or more entities. Represented by a diamond shape.", ["relationship"]),
            ("What is the degree of a relationship?", "The number of entities participating. Unary (1), binary (2), ternary (3).", ["relationship"]),
            ("What is a unary (recursive) relationship?", "A relationship where an entity is related to itself. Example: an Employee manages other Employees.", ["relationship"]),
            ("What is a binary relationship?", "A relationship between two entity types. The most common type of relationship.", ["relationship"]),
            ("What is a ternary relationship?", "A relationship involving three entity types. Example: a Doctor prescribes a Medicine to a Patient.", ["relationship"]),
            ("What is cardinality in ER diagrams?", "The maximum number of instances of one entity that can be associated with instances of another. Types: 1:1, 1:M, M:N.", ["cardinality"]),
            ("What is a 1:1 (one-to-one) relationship?", "Each instance of entity A is associated with at most one instance of entity B, and vice versa. Example: Person-Passport.", ["cardinality"]),
            ("What is a 1:M (one-to-many) relationship?", "One instance of entity A can be associated with many instances of entity B, but each B is associated with at most one A. Example: Department-Employee.", ["cardinality"]),
            ("What is an M:N (many-to-many) relationship?", "Instances of entity A can be associated with many instances of B, and vice versa. Example: Student-Course. Requires a junction table.", ["cardinality"]),
            ("What is participation constraint?", "Specifies whether all entities must participate in a relationship. Total (mandatory) or partial (optional).", ["participation"]),
            ("What is total participation?", "Every instance of the entity must participate in the relationship. Shown as a double line in Chen notation.", ["participation"]),
            ("What is partial participation?", "Some instances may not participate in the relationship. Shown as a single line in Chen notation.", ["participation"]),
            ("What is Crow's Foot notation?", "A popular ER diagram notation that uses symbols resembling a crow's foot (fork) to show 'many' and a single line for 'one'.", ["Crow's Foot"]),
            ("In Crow's Foot notation, what does a circle (O) mean?", "Zero — indicates optional participation (zero minimum cardinality).", ["Crow's Foot"]),
            ("In Crow's Foot notation, what does a single dash (|) mean?", "One — indicates mandatory participation or 'exactly one'.", ["Crow's Foot"]),
            ("In Crow's Foot notation, what does the crow's foot (fork) symbol mean?", "Many — indicates a maximum cardinality of many (unlimited).", ["Crow's Foot"]),
            ("How do you read Crow's Foot notation?", "Read from entity outward. The symbol closest to the entity indicates minimum cardinality, the outer symbol indicates maximum. O| = zero or one, || = exactly one, O< = zero or many, |< = one or many.", ["Crow's Foot"]),
            ("What is Chen notation?", "The original ER notation by Peter Chen. Uses rectangles (entities), diamonds (relationships), ovals (attributes), and lines with cardinality labels.", ["Chen notation"]),
            ("Compare Chen notation vs Crow's Foot.", "Chen is more academic and explicit with diamonds for relationships. Crow's Foot is more compact, widely used in industry, and shows cardinality directly on the lines.", ["comparison"]),
            ("What is an associative entity (junction table)?", "An entity that resolves an M:N relationship into two 1:M relationships. It contains foreign keys from both related entities.", ["junction table"]),
            ("What is an attribute of a relationship?", "Some relationships have their own attributes. For example, an 'Enrollment' relationship between Student and Course might have a 'grade' attribute.", ["relationship"]),
            ("How is total participation shown in Crow's Foot?", "With a mandatory indicator (|) on the minimum side, meaning every instance must participate.", ["Crow's Foot"]),
            ("How is partial participation shown in Crow's Foot?", "With an optional indicator (O) on the minimum side, meaning participation is optional.", ["Crow's Foot"]),
            ("What is the difference between cardinality and modality?", "Cardinality = maximum number of instances in a relationship. Modality (participation) = minimum number (0 = optional, 1 = mandatory).", ["cardinality", "modality"]),
            ("What does a 'zero or many' relationship look like in Crow's Foot?", "A circle (O) near the entity and a crow's foot (fork) at the far end: O——<", ["Crow's Foot"]),
            ("What does an 'exactly one' relationship look like in Crow's Foot?", "Two single dashes (||) — mandatory one: ||——", ["Crow's Foot"]),
            ("What does a 'one or many' relationship look like in Crow's Foot?", "A single dash (|) near entity and crow's foot at far end: |——<", ["Crow's Foot"]),
            ("What is a supertype/subtype in ER modeling?", "A generalization/specialization hierarchy. A supertype entity has common attributes; subtypes have additional specific attributes. Example: Person → Student, Employee.", ["generalization"]),
            ("What is generalization in ER modeling?", "Combining multiple entity types that share common attributes into a single higher-level (supertype) entity.", ["generalization"]),
            ("What is specialization in ER modeling?", "Dividing a higher-level entity into lower-level subtypes based on distinguishing characteristics.", ["specialization"]),
            ("What is disjoint vs overlapping in specialization?", "Disjoint (d): an entity can belong to only one subtype. Overlapping (o): an entity can belong to multiple subtypes.", ["specialization"]),
            ("What is total vs partial specialization?", "Total: every supertype instance must belong to at least one subtype. Partial: some supertype instances may not belong to any subtype.", ["specialization"]),
            ("What is a relationship type vs relationship set?", "A relationship type is the schema-level definition. A relationship set is the current collection of relationship instances.", ["theory"]),
            ("What is an existence dependency?", "When the existence of one entity depends on the existence of another. The dependent entity is typically a weak entity.", ["weak entity"]),
            ("What are min-max constraints?", "A notation (min, max) placed on relationships to specify the minimum and maximum times an entity participates. Example: (1,N) means at least 1, at most many.", ["constraints"]),
            ("How do you convert an M:N relationship to tables?", "Create three tables: one for each entity and one junction table containing the primary keys of both entities as foreign keys (forming a composite primary key).", ["mapping"]),
            ("How do you convert a 1:M relationship to tables?", "Place the primary key of the '1' side as a foreign key in the 'M' side table.", ["mapping"]),
            ("How do you convert a 1:1 relationship to tables?", "Place the primary key of one side as a foreign key in the other. Prefer putting it on the side with total participation.", ["mapping"]),
        ]
        for c in erCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: erDiagrams, tags: c.2))
        }

        // --- Primary & Foreign Keys (50+ cards) ---
        let keyCards: [(String, String, [String])] = [
            ("What is a superkey?", "Any set of one or more attributes that, taken collectively, uniquely identifies a tuple in a relation.", ["superkey"]),
            ("What is a candidate key?", "A minimal superkey — a superkey from which no attribute can be removed without losing uniqueness.", ["candidate key"]),
            ("What is a primary key?", "The candidate key chosen to uniquely identify each tuple in a relation. It cannot contain NULL values.", ["primary key"]),
            ("What is an alternate key?", "A candidate key that was not selected as the primary key. Also called a secondary key.", ["alternate key"]),
            ("What is a foreign key?", "An attribute (or set of attributes) in one relation that references the primary key of another relation, establishing a link between them.", ["foreign key"]),
            ("What is a composite key?", "A key that consists of two or more attributes that together uniquely identify a tuple.", ["composite key"]),
            ("What is a surrogate key?", "A system-generated artificial key (like an auto-increment integer) with no business meaning, used solely for identification.", ["surrogate key"]),
            ("What is a natural key?", "A key formed from attributes that naturally exist in the data and have real-world meaning. Example: Social Security Number.", ["natural key"]),
            ("Compare surrogate keys vs natural keys.", "Surrogate: system-generated, stable, no business meaning, never changes. Natural: real-world meaning, may change, can be composite, more meaningful in queries.", ["comparison"]),
            ("What is referential integrity?", "The rule that every foreign key value must either match an existing primary key value in the referenced table or be NULL.", ["referential integrity"]),
            ("What happens when you delete a row referenced by a foreign key?", "Depends on the constraint action: RESTRICT (prevent deletion), CASCADE (delete referencing rows), SET NULL (set FK to NULL), SET DEFAULT (set FK to default).", ["referential integrity"]),
            ("What is CASCADE on DELETE?", "When a referenced row is deleted, all rows in the referencing table that point to it are also automatically deleted.", ["cascade"]),
            ("What is SET NULL on DELETE?", "When a referenced row is deleted, the foreign key values in the referencing table are set to NULL.", ["set null"]),
            ("What is RESTRICT on DELETE?", "Prevents deletion of a referenced row if any rows in the referencing table still point to it.", ["restrict"]),
            ("What is NO ACTION on DELETE?", "Similar to RESTRICT, but the check is deferred to the end of the statement. If a violation still exists, the operation is rejected.", ["no action"]),
            ("Can a foreign key reference a non-primary key?", "Yes, a foreign key can reference any column(s) with a UNIQUE constraint, not just the primary key.", ["foreign key"]),
            ("Can a foreign key be NULL?", "Yes, unless there is a NOT NULL constraint on the foreign key column. A NULL FK means the relationship is optional.", ["foreign key", "null"]),
            ("Can a primary key be changed?", "Technically yes via UPDATE, but it's strongly discouraged because any foreign keys referencing it must also be updated.", ["primary key"]),
            ("What is a simple key?", "A key consisting of a single attribute, as opposed to a composite key.", ["simple key"]),
            ("What is the difference between a key and an index?", "A key is a logical concept for uniqueness/identification. An index is a physical data structure that speeds up data retrieval.", ["index"]),
            ("Can a table have multiple candidate keys?", "Yes. One becomes the primary key; the rest are alternate keys.", ["candidate key"]),
            ("What is a compound key?", "Another term for a composite key — a key made up of two or more columns.", ["composite key"]),
            ("What is a unique key constraint?", "A constraint ensuring all values in a column (or set of columns) are unique. Unlike PRIMARY KEY, it allows one NULL.", ["unique"]),
            ("What is entity integrity?", "The rule that no primary key attribute may be NULL. Every row must be uniquely identifiable.", ["entity integrity"]),
            ("Why should you avoid using changeable data as a primary key?", "If the key value changes, all foreign key references must also change, risking inconsistency and requiring cascading updates.", ["best practices"]),
            ("What is a self-referencing foreign key?", "A foreign key in a table that references the primary key of the same table. Used for hierarchical data (e.g., employee-manager).", ["self-reference"]),
            ("What is ON UPDATE CASCADE?", "When a referenced primary key value is updated, all matching foreign key values are automatically updated to match.", ["cascade"]),
            ("Can a foreign key be part of a primary key?", "Yes. This is common in junction tables where the composite primary key consists of two foreign keys.", ["composite key", "foreign key"]),
            ("What is a dangling reference?", "A foreign key value that does not match any primary key in the referenced table — a violation of referential integrity.", ["referential integrity"]),
            ("What is key inheritance in weak entities?", "A weak entity inherits the primary key of its owner entity. Its full primary key = owner's PK + its own partial key.", ["weak entity"]),
            ("Give an example of a composite primary key.", "In an Enrollment table: (student_id, course_id) together form the composite primary key, since a student can enroll in multiple courses.", ["example"]),
            ("What is a determinant?", "An attribute (or set of attributes) whose value determines the value of another attribute. Written as X → Y.", ["functional dependency"]),
            ("What makes a good primary key?", "Unique, never null, stable (rarely changes), minimal (as few columns as possible), simple, and ideally system-generated.", ["best practices"]),
            ("What is the purpose of a foreign key constraint?", "To enforce referential integrity — ensuring that relationships between tables remain consistent and valid.", ["foreign key"]),
            ("What is a recursive foreign key?", "A foreign key that references the primary key of its own table. Example: Employee.manager_id references Employee.employee_id.", ["self-reference"]),
            ("How are 1:1 relationships implemented with keys?", "Place the PK of one table as a FK (with UNIQUE constraint) in the other table. Put FK on the mandatory side if possible.", ["relationship mapping"]),
            ("How are 1:M relationships implemented with keys?", "Place the PK of the 'one' side as a FK in the 'many' side table.", ["relationship mapping"]),
            ("How are M:N relationships implemented with keys?", "Create a junction/bridge table with FKs referencing both related tables. The composite of both FKs is typically the PK.", ["relationship mapping"]),
            ("What is a business key?", "Another name for a natural key — a key derived from real-world business data rather than system-generated.", ["natural key"]),
            ("What is the difference between UNIQUE and PRIMARY KEY?", "Both enforce uniqueness. PRIMARY KEY also enforces NOT NULL and there can be only one per table. UNIQUE allows NULL and multiple per table.", ["constraints"]),
            ("What is a partial key?", "An attribute of a weak entity that partially identifies its instances. Combined with the owner's PK, it forms the full key.", ["weak entity"]),
            ("What is an intelligent key?", "A key that encodes information in its structure (e.g., first 3 letters = department). Generally discouraged because embedded info may change.", ["best practices"]),
            ("What is key migration?", "The process of copying a primary key from one table into another as a foreign key to establish a relationship.", ["mapping"]),
            ("Can a table have no primary key?", "Technically yes in SQL, but it violates relational model rules. Every relation should have a primary key for tuple identification.", ["primary key"]),
            ("What is a GUID/UUID as a key?", "A globally unique identifier (128-bit) used as a surrogate key. Advantages: globally unique, no collisions. Disadvantage: large size, no natural ordering.", ["surrogate key"]),
            ("What is a sequence in databases?", "A database object that generates unique sequential numbers, often used to populate surrogate key columns.", ["surrogate key"]),
            ("Why use surrogate keys in data warehouses?", "They provide stable, compact identifiers that are independent of source systems. They simplify ETL processes and slowly changing dimensions.", ["data warehouse"]),
            ("What is a lookup table?", "A reference table that stores valid values for a coded field. The main table uses a foreign key to reference it. Example: state_codes table.", ["design pattern"]),
            ("What is a bridge table?", "Another name for a junction/associative table used to resolve M:N relationships.", ["junction table"]),
            ("What is referential integrity checking?", "The DBMS automatically verifying that FK values match existing PK values whenever data is inserted, updated, or deleted.", ["referential integrity"]),
        ]
        for c in keyCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: keys, tags: c.2))
        }

        // --- Normalization 1NF-BCNF (50+ cards) ---
        let normCards: [(String, String, [String])] = [
            ("What is database normalization?", "The process of organizing a relational database to reduce data redundancy and improve data integrity by decomposing tables.", ["normalization"]),
            ("What is a functional dependency?", "A relationship where the value of one attribute (or set) uniquely determines the value of another. Written X → Y.", ["functional dependency"]),
            ("What is a partial dependency?", "A non-key attribute depends on only part of a composite primary key, not the entire key.", ["partial dependency"]),
            ("What is a transitive dependency?", "A non-key attribute depends on another non-key attribute, which depends on the primary key. A → B → C means C transitively depends on A.", ["transitive dependency"]),
            ("What is 1NF (First Normal Form)?", "A relation is in 1NF if: all attributes contain only atomic (indivisible) values, each column has a unique name, no repeating groups, and order of rows/columns doesn't matter.", ["1NF"]),
            ("Give an example of a 1NF violation.", "A Student table with a 'PhoneNumbers' column containing '555-1234, 555-5678'. The multivalued attribute violates 1NF atomicity.", ["1NF", "example"]),
            ("How do you fix a 1NF violation?", "Remove repeating groups by creating a separate table for the multivalued attribute with a foreign key back to the original table.", ["1NF"]),
            ("What is 2NF (Second Normal Form)?", "A relation is in 2NF if it is in 1NF and every non-key attribute is fully functionally dependent on the entire primary key (no partial dependencies).", ["2NF"]),
            ("When can 2NF violations occur?", "Only when the primary key is composite. If the PK is a single attribute, 2NF is automatically satisfied if 1NF is met.", ["2NF"]),
            ("Give an example of a 2NF violation.", "Table: StudentCourse(StudentID, CourseID, StudentName, Grade). StudentName depends only on StudentID, not the full key (StudentID, CourseID).", ["2NF", "example"]),
            ("How do you fix a 2NF violation?", "Decompose the table: move partially dependent attributes to a new table with the part of the key they depend on.", ["2NF"]),
            ("What is 3NF (Third Normal Form)?", "A relation is in 3NF if it is in 2NF and no non-key attribute is transitively dependent on the primary key.", ["3NF"]),
            ("Give an example of a 3NF violation.", "Table: Employee(EmpID, DeptID, DeptName). DeptName depends on DeptID, and DeptID depends on EmpID. DeptName is transitively dependent on EmpID.", ["3NF", "example"]),
            ("How do you fix a 3NF violation?", "Decompose: create a separate Department(DeptID, DeptName) table and remove DeptName from the Employee table.", ["3NF"]),
            ("What is BCNF (Boyce-Codd Normal Form)?", "A relation is in BCNF if for every functional dependency X → Y, X is a superkey. It's a stronger version of 3NF.", ["BCNF"]),
            ("How does BCNF differ from 3NF?", "3NF allows non-key → key dependencies if the dependent is part of a candidate key. BCNF is stricter: every determinant must be a superkey.", ["BCNF", "comparison"]),
            ("Give an example of a 3NF but not BCNF violation.", "Table: Teaching(Student, Course, Professor) where Professor → Course but Professor is not a superkey.", ["BCNF", "example"]),
            ("What is an insertion anomaly?", "The inability to insert data because other required data is not yet available. Caused by poor normalization.", ["anomaly"]),
            ("What is an update anomaly?", "Inconsistency that occurs when the same data is stored in multiple places and only some copies are updated.", ["anomaly"]),
            ("What is a deletion anomaly?", "The unintended loss of data when deleting a row that contains the only copy of some information.", ["anomaly"]),
            ("What are the benefits of normalization?", "Eliminates redundancy, prevents anomalies, ensures data integrity, reduces storage, makes updates simpler and safer.", ["benefits"]),
            ("What are the disadvantages of normalization?", "More tables mean more joins (potentially slower queries), increased complexity in database design and application code.", ["tradeoffs"]),
            ("What is denormalization?", "Intentionally introducing redundancy back into a normalized design to improve read performance, often used in data warehousing.", ["denormalization"]),
            ("When should you denormalize?", "When read performance is critical, joins are too expensive, data is read-heavy with few updates, or for reporting/analytics workloads.", ["denormalization"]),
            ("What is a determinant?", "The attribute(s) on the left side of a functional dependency. In X → Y, X is the determinant.", ["functional dependency"]),
            ("What is a full functional dependency?", "An attribute is fully functionally dependent on a key if removing any attribute from the key breaks the dependency.", ["functional dependency"]),
            ("What is a trivial functional dependency?", "A dependency where the dependent attribute is a subset of the determinant. Example: {A, B} → A is trivial.", ["functional dependency"]),
            ("What is a multivalued dependency?", "Exists when one attribute determines a set of values of another attribute, independent of other attributes. Written X →→ Y.", ["4NF"]),
            ("What is 4NF?", "A relation is in 4NF if it is in BCNF and has no non-trivial multivalued dependencies.", ["4NF"]),
            ("What is 5NF?", "A relation is in 5NF (Project-Join Normal Form) if every join dependency is implied by the candidate keys.", ["5NF"]),
            ("What is lossless decomposition?", "A decomposition where the original relation can be perfectly reconstructed by joining the decomposed relations. Required for correctness.", ["decomposition"]),
            ("What is dependency preservation?", "A decomposition that preserves all original functional dependencies, so constraints can be checked without joining tables.", ["decomposition"]),
            ("How do you identify functional dependencies?", "Analyze the business rules and data semantics. Look at what attributes uniquely determine others. Check with domain experts.", ["analysis"]),
            ("What is the closure of a set of attributes?", "All attributes that can be functionally determined from the given set using the functional dependencies. Written X⁺.", ["theory"]),
            ("What is Armstrong's Axioms?", "Three inference rules for functional dependencies: Reflexivity (if Y⊆X then X→Y), Augmentation (if X→Y then XZ→YZ), Transitivity (if X→Y and Y→Z then X→Z).", ["theory"]),
            ("What is a canonical cover?", "A minimal set of functional dependencies equivalent to the original set, with no redundant dependencies or extraneous attributes.", ["theory"]),
            ("What is normalization's relationship to ER modeling?", "Good ER design often produces 3NF tables naturally. Normalization is applied after mapping the ER model to relations to verify and fix any remaining issues.", ["design"]),
            ("What is a repeating group?", "A set of attributes that can have multiple values for a single entity instance. Must be eliminated for 1NF.", ["1NF"]),
            ("Does a table with a single-column PK need 2NF checking?", "No. 2NF violations only occur with composite primary keys, since partial dependency requires depending on part of the key.", ["2NF"]),
            ("What is an anomaly-free design?", "A database design where insertions, updates, and deletions can be performed without unexpected side effects or data loss.", ["anomaly"]),
            ("Summarize the progression: UNF → 1NF → 2NF → 3NF → BCNF.", "UNF: has repeating groups. 1NF: atomic values only. 2NF: no partial deps. 3NF: no transitive deps. BCNF: every determinant is a superkey.", ["summary"]),
            ("What is a prime attribute?", "An attribute that is part of any candidate key.", ["theory"]),
            ("What is a non-prime attribute?", "An attribute that is not part of any candidate key.", ["theory"]),
            ("Can normalization lead to data loss?", "No, if decomposition is lossless. You can always reconstruct the original data by joining the decomposed tables.", ["decomposition"]),
            ("What is over-normalization?", "Normalizing to a degree that makes the database overly complex and queries inefficient due to excessive joins.", ["tradeoffs"]),
            ("What is a universal relation?", "A single relation containing all attributes of the database. Normalization decomposes this into smaller, well-structured relations.", ["theory"]),
            ("What determines if a table is in BCNF?", "Check every functional dependency X → Y: if X is a superkey for every dependency, the table is in BCNF.", ["BCNF"]),
            ("Name three real-world examples of transitive dependencies.", "1) Employee → Department → Location. 2) Order → Customer → City. 3) Book → Publisher → Country.", ["3NF", "example"]),
            ("What is a join dependency?", "A constraint stating that a relation can be losslessly decomposed into a specific set of projections. Related to 5NF.", ["5NF"]),
            ("Why is BCNF not always achievable?", "Sometimes decomposing to BCNF sacrifices dependency preservation. In such cases, 3NF may be preferred.", ["BCNF", "tradeoffs"]),
        ]
        for c in normCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: normalization, tags: c.2))
        }

        // --- SQL DDL Commands (50+ cards) ---
        let ddlCards: [(String, String, [String])] = [
            ("What does DDL stand for?", "Data Definition Language — SQL commands used to define, alter, and manage database structures (schemas, tables, indexes, views).", ["DDL"]),
            ("What are the main DDL commands?", "CREATE, ALTER, DROP, TRUNCATE, RENAME. These define and modify the structure of database objects.", ["DDL"]),
            ("Write the syntax for CREATE TABLE.", "CREATE TABLE table_name (\n  column1 datatype constraints,\n  column2 datatype constraints,\n  ...\n);", ["CREATE TABLE"]),
            ("What is the CREATE TABLE command?", "Creates a new table in the database with specified columns, data types, and constraints.", ["CREATE TABLE"]),
            ("What is the DROP TABLE command?", "Permanently removes a table and all its data from the database. Syntax: DROP TABLE table_name;", ["DROP TABLE"]),
            ("What is the ALTER TABLE command?", "Modifies an existing table structure — add/drop/modify columns, add/drop constraints.", ["ALTER TABLE"]),
            ("How do you add a column to an existing table?", "ALTER TABLE table_name ADD column_name datatype;", ["ALTER TABLE"]),
            ("How do you drop a column from a table?", "ALTER TABLE table_name DROP COLUMN column_name;", ["ALTER TABLE"]),
            ("How do you modify a column's data type?", "ALTER TABLE table_name MODIFY column_name new_datatype; (or ALTER COLUMN in some DBMS)", ["ALTER TABLE"]),
            ("What is the NOT NULL constraint?", "Ensures a column cannot contain NULL values. Every row must have a value for this column.", ["constraints"]),
            ("What is the UNIQUE constraint?", "Ensures all values in a column are distinct. Unlike PRIMARY KEY, allows NULL (typically one).", ["constraints"]),
            ("What is the PRIMARY KEY constraint?", "Uniquely identifies each row. Combines NOT NULL and UNIQUE. Only one per table.", ["constraints"]),
            ("What is the FOREIGN KEY constraint?", "Links a column to the primary key of another table, enforcing referential integrity.", ["constraints"]),
            ("What is the CHECK constraint?", "Limits the values allowed in a column based on a condition. Example: CHECK (age >= 0)", ["constraints"]),
            ("What is the DEFAULT constraint?", "Specifies a default value for a column when no value is provided during INSERT.", ["constraints"]),
            ("Write syntax for a FOREIGN KEY constraint.", "CONSTRAINT fk_name FOREIGN KEY (column) REFERENCES other_table(pk_column) ON DELETE CASCADE ON UPDATE CASCADE", ["FOREIGN KEY"]),
            ("What is CREATE INDEX?", "Creates an index on one or more columns to speed up data retrieval. Syntax: CREATE INDEX idx_name ON table(column);", ["index"]),
            ("What is a unique index?", "An index that also enforces uniqueness on the indexed columns. CREATE UNIQUE INDEX idx_name ON table(column);", ["index"]),
            ("What is DROP INDEX?", "Removes an existing index. Syntax varies by DBMS: DROP INDEX idx_name; or DROP INDEX idx_name ON table;", ["index"]),
            ("What is CREATE VIEW?", "Creates a virtual table based on a SELECT query. Syntax: CREATE VIEW view_name AS SELECT ...;", ["view"]),
            ("What is DROP VIEW?", "Removes a view definition. Syntax: DROP VIEW view_name;", ["view"]),
            ("What are common SQL data types?", "INT/INTEGER, VARCHAR(n), CHAR(n), TEXT, DATE, DATETIME/TIMESTAMP, DECIMAL(p,s), FLOAT, BOOLEAN, BLOB.", ["data types"]),
            ("What is VARCHAR vs CHAR?", "VARCHAR stores variable-length strings (uses only needed space). CHAR stores fixed-length strings (padded with spaces).", ["data types"]),
            ("What is DECIMAL(p,s)?", "A fixed-point number. p = total digits (precision), s = digits after decimal (scale). DECIMAL(8,2) stores up to 999999.99.", ["data types"]),
            ("What is TRUNCATE TABLE?", "Removes all rows from a table but keeps the table structure. Faster than DELETE because it doesn't log individual row deletions.", ["TRUNCATE"]),
            ("How does TRUNCATE differ from DELETE?", "TRUNCATE: DDL, removes all rows, can't use WHERE, faster, resets auto-increment. DELETE: DML, can use WHERE, logs each row, doesn't reset counters.", ["comparison"]),
            ("How does TRUNCATE differ from DROP?", "TRUNCATE removes all data but keeps the table structure. DROP removes both the data and the table definition.", ["comparison"]),
            ("What is CREATE DATABASE?", "Creates a new database. Syntax: CREATE DATABASE db_name;", ["CREATE"]),
            ("What is DROP DATABASE?", "Permanently deletes a database and all its objects. Syntax: DROP DATABASE db_name;", ["DROP"]),
            ("What is CREATE SCHEMA?", "Creates a named schema (namespace) within a database to group related objects.", ["schema"]),
            ("What is a table constraint vs column constraint?", "A column constraint is defined inline with the column. A table constraint is defined after all columns — required for composite keys.", ["constraints"]),
            ("Write syntax for a composite primary key.", "CREATE TABLE Enrollment (\n  student_id INT,\n  course_id INT,\n  grade CHAR(1),\n  PRIMARY KEY (student_id, course_id)\n);", ["composite key"]),
            ("What is IF EXISTS / IF NOT EXISTS?", "Optional clauses for safety: DROP TABLE IF EXISTS prevents error if table doesn't exist. CREATE TABLE IF NOT EXISTS prevents error if it already exists.", ["safety"]),
            ("What is AUTO_INCREMENT (or IDENTITY)?", "A column property that automatically generates a unique sequential number for each new row. Used for surrogate keys.", ["auto increment"]),
            ("What is a schema in SQL?", "A container/namespace for database objects (tables, views, indexes). Helps organize objects and manage permissions.", ["schema"]),
            ("How do you rename a table?", "ALTER TABLE old_name RENAME TO new_name; (or RENAME TABLE in some DBMS)", ["ALTER TABLE"]),
            ("How do you add a constraint to an existing table?", "ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_type (columns);", ["ALTER TABLE", "constraints"]),
            ("How do you drop a constraint?", "ALTER TABLE table_name DROP CONSTRAINT constraint_name;", ["ALTER TABLE", "constraints"]),
            ("What is a composite foreign key?", "A foreign key consisting of multiple columns that together reference a composite primary key in another table.", ["foreign key"]),
            ("What is the REFERENCES clause?", "Part of a FOREIGN KEY constraint that specifies which table and column(s) the FK points to.", ["FOREIGN KEY"]),
            ("What is ON DELETE SET DEFAULT?", "When a referenced row is deleted, the FK column is set to its default value instead of NULL or cascading.", ["referential actions"]),
            ("What is a temporary table?", "A table that exists only for the duration of a session or transaction. Created with CREATE TEMPORARY TABLE.", ["temporary table"]),
            ("What is a CHECK constraint with multiple conditions?", "CHECK (salary > 0 AND salary < 1000000) — validates multiple conditions on insert/update.", ["constraints"]),
            ("What happens if you CREATE TABLE with a name that already exists?", "An error is returned unless IF NOT EXISTS is specified.", ["CREATE TABLE"]),
            ("What is the difference between BLOB and TEXT?", "BLOB stores binary data (images, files). TEXT stores character/string data. Both can hold large amounts of data.", ["data types"]),
            ("What is a generated/computed column?", "A column whose value is automatically computed from other columns. Example: total_price AS (quantity * unit_price).", ["computed column"]),
            ("What is COMMENT ON?", "A DDL statement that adds a descriptive comment/metadata to a table, column, or other database object.", ["metadata"]),
            ("List three things you can do with ALTER TABLE.", "1) ADD/DROP columns 2) ADD/DROP constraints 3) MODIFY column data type or size", ["ALTER TABLE"]),
            ("What is the order of clauses in CREATE TABLE?", "CREATE TABLE name (column definitions, table constraints); Column defs include name, type, and optional column constraints.", ["syntax"]),
            ("What data type would you use for currency?", "DECIMAL(10,2) or NUMERIC(10,2) — fixed-point types that avoid floating-point precision errors.", ["data types"]),
        ]
        for c in ddlCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: ddl, tags: c.2))
        }

        // --- SQL DML Commands (50+ cards) ---
        let dmlCards: [(String, String, [String])] = [
            ("What does DML stand for?", "Data Manipulation Language — SQL commands for querying and modifying data: SELECT, INSERT, UPDATE, DELETE.", ["DML"]),
            ("What is the SELECT statement?", "Retrieves data from one or more tables. Syntax: SELECT columns FROM table WHERE condition;", ["SELECT"]),
            ("What is the INSERT statement?", "Adds new rows to a table. Syntax: INSERT INTO table (col1, col2) VALUES (val1, val2);", ["INSERT"]),
            ("What is the UPDATE statement?", "Modifies existing data. Syntax: UPDATE table SET col1 = val1 WHERE condition;", ["UPDATE"]),
            ("What is the DELETE statement?", "Removes rows from a table. Syntax: DELETE FROM table WHERE condition;", ["DELETE"]),
            ("What happens if you run DELETE without WHERE?", "ALL rows in the table are deleted. This is destructive and usually unintended.", ["DELETE", "caution"]),
            ("What happens if you run UPDATE without WHERE?", "ALL rows in the table are updated with the specified values.", ["UPDATE", "caution"]),
            ("What is the WHERE clause?", "Filters rows based on a condition. Only rows meeting the condition are selected/updated/deleted.", ["WHERE"]),
            ("What is the ORDER BY clause?", "Sorts the result set by one or more columns. ASC (default) for ascending, DESC for descending.", ["ORDER BY"]),
            ("What is the GROUP BY clause?", "Groups rows sharing common values into summary rows, typically used with aggregate functions.", ["GROUP BY"]),
            ("What is the HAVING clause?", "Filters groups created by GROUP BY based on a condition. Like WHERE but for aggregated data.", ["HAVING"]),
            ("What is the difference between WHERE and HAVING?", "WHERE filters individual rows before grouping. HAVING filters groups after GROUP BY and aggregation.", ["comparison"]),
            ("What is DISTINCT?", "Removes duplicate rows from the result set. SELECT DISTINCT column FROM table;", ["DISTINCT"]),
            ("Name five aggregate functions.", "COUNT() — number of rows, SUM() — total, AVG() — average, MIN() — smallest, MAX() — largest.", ["aggregate"]),
            ("What does COUNT(*) vs COUNT(column) do?", "COUNT(*) counts all rows including NULLs. COUNT(column) counts only non-NULL values in that column.", ["aggregate"]),
            ("What is an INNER JOIN?", "Returns only rows that have matching values in both tables. Unmatched rows are excluded.", ["JOIN"]),
            ("What is a LEFT JOIN?", "Returns all rows from the left table and matched rows from the right table. Unmatched right rows appear as NULL.", ["JOIN"]),
            ("What is a RIGHT JOIN?", "Returns all rows from the right table and matched rows from the left table. Unmatched left rows appear as NULL.", ["JOIN"]),
            ("What is a FULL OUTER JOIN?", "Returns all rows from both tables. Where there's no match, NULL fills in for the missing side.", ["JOIN"]),
            ("What is a CROSS JOIN?", "Returns the Cartesian product — every row from the first table combined with every row from the second.", ["JOIN"]),
            ("Write an INNER JOIN query.", "SELECT e.name, d.dept_name FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;", ["JOIN", "example"]),
            ("Write a LEFT JOIN query.", "SELECT c.name, o.order_id FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;", ["JOIN", "example"]),
            ("What is a self-join?", "A join of a table with itself using aliases. Example: SELECT e.name, m.name AS manager FROM employees e JOIN employees m ON e.manager_id = m.id;", ["JOIN"]),
            ("What is a subquery?", "A query nested inside another query. Can appear in WHERE, FROM, SELECT, or HAVING clauses.", ["subquery"]),
            ("What is a correlated subquery?", "A subquery that references columns from the outer query. It executes once for each row of the outer query.", ["subquery"]),
            ("Give an example of a subquery in WHERE.", "SELECT name FROM employees WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'NYC');", ["subquery", "example"]),
            ("What is the LIKE operator?", "Pattern matching for strings. % matches any sequence of characters, _ matches exactly one character.", ["LIKE"]),
            ("What is the BETWEEN operator?", "Filters values within a range (inclusive). WHERE salary BETWEEN 40000 AND 80000.", ["BETWEEN"]),
            ("What is the IN operator?", "Checks if a value matches any value in a list or subquery. WHERE dept_id IN (1, 2, 3).", ["IN"]),
            ("What is IS NULL / IS NOT NULL?", "Tests for NULL values. You cannot use = NULL; you must use IS NULL.", ["NULL"]),
            ("What is COALESCE?", "Returns the first non-NULL value from a list of arguments. COALESCE(phone, email, 'N/A').", ["functions"]),
            ("What is UNION?", "Combines results of two SELECT statements, removing duplicates. Both must have the same number and type of columns.", ["UNION"]),
            ("What is UNION ALL?", "Like UNION but keeps duplicate rows. Faster because no deduplication is needed.", ["UNION"]),
            ("What is the order of SQL clause execution?", "FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT", ["execution order"]),
            ("What is an alias in SQL?", "A temporary name for a table or column. SELECT name AS employee_name FROM employees e; (AS is optional for tables)", ["alias"]),
            ("What is a wildcard in SQL?", "% (any characters) and _ (single character) used with LIKE. SELECT * uses * as wildcard for all columns.", ["wildcard"]),
            ("Write a GROUP BY query with HAVING.", "SELECT dept_id, COUNT(*) AS cnt FROM employees GROUP BY dept_id HAVING COUNT(*) > 5;", ["GROUP BY", "example"]),
            ("What is LIMIT/TOP/FETCH FIRST?", "Restricts the number of rows returned. MySQL: LIMIT 10. SQL Server: TOP 10. Standard SQL: FETCH FIRST 10 ROWS ONLY.", ["LIMIT"]),
            ("What is INSERT INTO ... SELECT?", "Inserts rows from a query result into a table. INSERT INTO archive SELECT * FROM orders WHERE year = 2023;", ["INSERT"]),
            ("What is a CASE expression?", "SQL's if-then-else. CASE WHEN condition THEN result WHEN ... ELSE default END. Can be used in SELECT, WHERE, ORDER BY.", ["CASE"]),
            ("What are string functions in SQL?", "UPPER(), LOWER(), LENGTH()/LEN(), SUBSTRING(), TRIM(), CONCAT(), REPLACE(), LEFT(), RIGHT().", ["functions"]),
            ("What are date functions in SQL?", "NOW()/CURRENT_TIMESTAMP, DATEADD(), DATEDIFF(), YEAR(), MONTH(), DAY(), DATE_FORMAT().", ["functions"]),
            ("What is a natural join in SQL?", "A join that automatically matches columns with the same name in both tables. SELECT * FROM A NATURAL JOIN B;", ["JOIN"]),
            ("What is EXISTS in SQL?", "Tests whether a subquery returns any rows. Returns TRUE if the subquery result is non-empty.", ["EXISTS"]),
            ("What is the difference between IN and EXISTS?", "IN checks a value against a list. EXISTS checks if a subquery returns rows. EXISTS can be more efficient for large datasets.", ["comparison"]),
            ("What is a derived table?", "A subquery in the FROM clause that acts as a temporary table. SELECT * FROM (SELECT ... ) AS derived;", ["subquery"]),
            ("What is NULL handling in aggregate functions?", "Aggregate functions (except COUNT(*)) ignore NULL values. SUM, AVG, MIN, MAX all skip NULLs.", ["NULL", "aggregate"]),
            ("What is the difference between DELETE and TRUNCATE?", "DELETE: DML, logged per row, can use WHERE, fires triggers. TRUNCATE: DDL, removes all rows, faster, doesn't fire row triggers.", ["comparison"]),
            ("Write a multi-table JOIN query.", "SELECT s.name, c.title, e.grade FROM students s JOIN enrollments e ON s.id = e.student_id JOIN courses c ON c.id = e.course_id;", ["JOIN", "example"]),
            ("What is EXCEPT/MINUS?", "Returns rows from the first query that are not in the second query. Both must be union-compatible.", ["set operations"]),
            ("What is INTERSECT?", "Returns only rows that appear in both query results. Both must be union-compatible.", ["set operations"]),
        ]
        for c in dmlCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: dml, tags: c.2))
        }

        // --- Conceptual/Logical/Physical Models (50+ cards) ---
        let modelCards: [(String, String, [String])] = [
            ("What is a conceptual data model?", "A high-level, abstract representation of data requirements. Focuses on entities, relationships, and business rules without implementation details.", ["conceptual"]),
            ("What is a logical data model?", "A detailed representation of data structure including entities, attributes, relationships, primary/foreign keys, and normalization. DBMS-independent.", ["logical"]),
            ("What is a physical data model?", "The actual implementation design for a specific DBMS. Includes tables, columns, data types, indexes, partitions, and storage details.", ["physical"]),
            ("Compare conceptual vs logical vs physical models.", "Conceptual: what data (high-level entities). Logical: how data is structured (attributes, keys, normalized). Physical: how data is stored (DBMS-specific, indexes, partitions).", ["comparison"]),
            ("What is a schema?", "The formal description of the structure of a database — its tables, columns, data types, relationships, and constraints.", ["schema"]),
            ("What is an instance?", "The actual data stored in the database at a particular moment in time. The schema doesn't change; the instance does.", ["instance"]),
            ("What is the three-schema architecture?", "ANSI/SPARC architecture with three levels: External (user views), Conceptual (community view), Internal (physical storage). Provides data independence.", ["three-schema"]),
            ("What is the external schema?", "Describes the part of the database relevant to a particular user or application. Each user may have a different external view.", ["three-schema"]),
            ("What is the conceptual schema?", "Describes the structure of the entire database for the community of users. Hides physical storage details.", ["three-schema"]),
            ("What is the internal schema?", "Describes how data is physically stored — file structures, indexes, access paths, storage allocation.", ["three-schema"]),
            ("What is logical data independence?", "The ability to change the conceptual schema without affecting external schemas or applications.", ["data independence"]),
            ("What is physical data independence?", "The ability to change the internal schema (storage, indexes) without affecting the conceptual or external schemas.", ["data independence"]),
            ("Which type of data independence is harder to achieve?", "Logical data independence is harder because changing the conceptual schema (adding/removing tables) is more likely to affect applications.", ["data independence"]),
            ("What is a data model?", "A collection of concepts and rules for describing the structure of a database: data types, relationships, constraints, and operations.", ["fundamentals"]),
            ("Name four common data models.", "Relational, Entity-Relationship, Object-Oriented, and Document/NoSQL.", ["data models"]),
            ("What is the hierarchical data model?", "An early model organizing data in a tree structure with parent-child relationships. Each child has exactly one parent.", ["historical"]),
            ("What is the network data model?", "An early model similar to hierarchical but allows a child to have multiple parents, forming a graph structure.", ["historical"]),
            ("What is the object-relational model?", "Extends the relational model with object-oriented features like user-defined types, inheritance, and methods.", ["object-relational"]),
            ("What is a data dictionary?", "A centralized repository of metadata — information about tables, columns, data types, constraints, and relationships in the database.", ["data dictionary"]),
            ("What does the data dictionary contain?", "Table/column names, data types, constraints, relationships, indexes, users/permissions, stored procedures, and other metadata.", ["data dictionary"]),
            ("What is metadata?", "Data about data — information describing the structure, format, relationships, and constraints of the actual data.", ["metadata"]),
            ("What is a database schema diagram?", "A visual representation of the database schema showing tables, their columns, primary/foreign keys, and relationships.", ["visualization"]),
            ("What is the purpose of the conceptual model?", "To capture business requirements and rules at a high level, understandable by non-technical stakeholders. Usually an ER diagram.", ["conceptual"]),
            ("Who creates the conceptual model?", "Database designers in collaboration with business analysts and stakeholders during requirements gathering.", ["roles"]),
            ("Who creates the physical model?", "Database administrators (DBAs) and developers who understand the target DBMS's capabilities and optimization.", ["roles"]),
            ("What is forward engineering?", "The process of creating a physical database from a logical/conceptual model. Going from design to implementation.", ["engineering"]),
            ("What is reverse engineering in databases?", "Creating a logical/conceptual model from an existing physical database. Extracting design from implementation.", ["engineering"]),
            ("What are integrity constraints?", "Rules that ensure data accuracy and consistency: entity integrity, referential integrity, domain constraints, and business rules.", ["constraints"]),
            ("What is a domain constraint?", "A rule that restricts the values an attribute can hold, based on data type, range, or enumeration.", ["constraints"]),
            ("What is a business rule?", "A specific organizational regulation or policy that governs data. Example: 'A student can enroll in at most 6 courses per semester.'", ["business rules"]),
            ("How do business rules relate to constraints?", "Business rules are translated into database constraints (CHECK, triggers, application logic) to enforce data integrity.", ["business rules"]),
            ("What is a star schema?", "A data warehouse schema with a central fact table surrounded by dimension tables. Optimized for analytical queries.", ["data warehouse"]),
            ("What is a snowflake schema?", "A normalized version of a star schema where dimension tables are further decomposed into sub-dimensions.", ["data warehouse"]),
            ("What is OLTP vs OLAP?", "OLTP: Online Transaction Processing — handles day-to-day operations, many short transactions. OLAP: Online Analytical Processing — handles complex queries for analysis.", ["comparison"]),
            ("What is a fact table?", "The central table in a star/snowflake schema containing measurable, quantitative data (facts) and foreign keys to dimension tables.", ["data warehouse"]),
            ("What is a dimension table?", "A table in a star/snowflake schema containing descriptive attributes used to filter, group, and label facts.", ["data warehouse"]),
            ("What is an ER-to-relational mapping?", "The process of converting an ER diagram into relational tables with proper columns, keys, and constraints.", ["mapping"]),
            ("How do you map a strong entity to a table?", "Create a table with all simple attributes as columns. Choose one candidate key as the primary key.", ["mapping"]),
            ("How do you map a weak entity?", "Create a table with the weak entity's attributes plus the owner's PK as a FK. The composite of both becomes the PK.", ["mapping"]),
            ("How do you map a multivalued attribute?", "Create a separate table with the attribute value and the PK of the owning entity as a FK.", ["mapping"]),
            ("How do you map a composite attribute?", "Include only the simple component attributes as columns — do not include the composite attribute itself.", ["mapping"]),
            ("How do you map a derived attribute?", "Generally don't store it — compute it with a query or view. Optionally store it for performance with a trigger to keep it updated.", ["mapping"]),
            ("What is data abstraction?", "Hiding implementation complexity and showing only essential features. The three-schema architecture provides three levels of abstraction.", ["theory"]),
            ("What is the difference between schema and subschema?", "A schema describes the whole database. A subschema (external schema) describes a specific user's view — a subset.", ["three-schema"]),
            ("What is a database catalog?", "A system database that stores metadata (schema information). Also called the system catalog or data dictionary.", ["metadata"]),
            ("What is the information schema?", "A standard set of read-only views in SQL that provide information about the database's tables, columns, constraints, etc.", ["metadata"]),
            ("What is a tablespace?", "A physical storage unit in the DBMS where data files are stored. Part of the physical model.", ["physical"]),
            ("What is an extent?", "A contiguous block of storage allocated to a table or index. Multiple extents form a segment.", ["physical"]),
            ("What is data independence important?", "It allows changes at one level (physical, logical) without affecting other levels, reducing maintenance and increasing flexibility.", ["data independence"]),
            ("What is conceptual modeling used for in requirements gathering?", "To identify and document the key entities, their attributes, and relationships needed to support business processes.", ["conceptual", "requirements"]),
        ]
        for c in modelCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: models, tags: c.2))
        }

        // --- DBMS Architecture (50+ cards) ---
        let dbmsCards: [(String, String, [String])] = [
            ("What is a DBMS?", "Database Management System — software that provides an interface for creating, managing, and querying databases while ensuring data integrity and security.", ["DBMS"]),
            ("What are the main components of a DBMS?", "Query Processor, Storage Manager, Transaction Manager, Buffer Manager, Data Dictionary, Authorization/Security Manager.", ["components"]),
            ("What does the Query Processor do?", "Parses, validates, optimizes, and executes SQL queries. Includes the parser, optimizer, and execution engine.", ["query processor"]),
            ("What does the Storage Manager do?", "Manages the interaction between the DBMS and the file system. Handles data storage, retrieval, and buffering.", ["storage manager"]),
            ("What does the Transaction Manager do?", "Ensures ACID properties are maintained. Coordinates concurrent transactions and handles recovery.", ["transaction manager"]),
            ("What does the Buffer Manager do?", "Manages the transfer of data between disk and main memory (buffer pool). Decides which pages to cache and evict.", ["buffer manager"]),
            ("What is a transaction?", "A logical unit of work consisting of one or more database operations that must be executed as an atomic whole.", ["transaction"]),
            ("What are the ACID properties?", "Atomicity (all or nothing), Consistency (valid state to valid state), Isolation (concurrent transactions don't interfere), Durability (committed changes persist).", ["ACID"]),
            ("What is Atomicity?", "A transaction is treated as a single indivisible unit — either all operations complete successfully, or none do (rolled back).", ["ACID"]),
            ("What is Consistency?", "A transaction must take the database from one valid state to another, maintaining all integrity constraints.", ["ACID"]),
            ("What is Isolation?", "Concurrent transactions execute as if they were running serially. Each transaction is unaware of other concurrent transactions.", ["ACID"]),
            ("What is Durability?", "Once a transaction is committed, its changes are permanent and survive system crashes, power failures, etc.", ["ACID"]),
            ("What is COMMIT?", "A command that makes all changes made during a transaction permanent in the database.", ["transaction"]),
            ("What is ROLLBACK?", "A command that undoes all changes made during a transaction, restoring the database to its state before the transaction began.", ["transaction"]),
            ("What is a SAVEPOINT?", "A point within a transaction to which you can later rollback without undoing the entire transaction.", ["transaction"]),
            ("What is concurrency control?", "Mechanisms that manage simultaneous access to the database by multiple transactions, preventing conflicts and inconsistencies.", ["concurrency"]),
            ("What is a lock?", "A mechanism that restricts access to a data item by a transaction, preventing conflicting operations by other transactions.", ["concurrency"]),
            ("What is a shared lock vs exclusive lock?", "Shared (read) lock: multiple transactions can read simultaneously. Exclusive (write) lock: only one transaction can access the data.", ["concurrency"]),
            ("What is a deadlock?", "A situation where two or more transactions are waiting for each other to release locks, creating a cycle of dependency.", ["concurrency"]),
            ("How are deadlocks resolved?", "Detection and rollback (abort one transaction), prevention (ordering locks), timeout (abort after waiting too long).", ["concurrency"]),
            ("What is the write-ahead log (WAL)?", "A recovery technique where changes are written to a log file before being applied to the database, ensuring durability and enabling recovery.", ["recovery"]),
            ("What is database recovery?", "The process of restoring a database to a consistent state after a failure, using transaction logs and backups.", ["recovery"]),
            ("What is a checkpoint?", "A point at which all modified buffer pages are written to disk and a record is written to the log. Speeds up recovery.", ["recovery"]),
            ("What is a database backup?", "A complete or partial copy of the database and its transaction logs, used for disaster recovery.", ["recovery"]),
            ("What is two-phase locking (2PL)?", "A protocol where a transaction has a growing phase (acquires locks) and a shrinking phase (releases locks). Ensures serializability.", ["concurrency"]),
            ("What is serializability?", "A property ensuring that the result of concurrent transactions is equivalent to some serial (one-at-a-time) execution.", ["concurrency"]),
            ("What are transaction isolation levels?", "READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE. Each provides different trade-offs between consistency and concurrency.", ["isolation levels"]),
            ("What is a dirty read?", "Reading uncommitted data from another transaction. Can occur at READ UNCOMMITTED level.", ["isolation levels"]),
            ("What is a non-repeatable read?", "When a transaction reads the same row twice and gets different values because another transaction modified it between reads.", ["isolation levels"]),
            ("What is a phantom read?", "When a transaction re-executes a query and finds new rows that were inserted by another committed transaction.", ["isolation levels"]),
            ("What is the query optimizer?", "A DBMS component that determines the most efficient execution plan for a query by analyzing different strategies.", ["query processor"]),
            ("What is a query execution plan?", "The step-by-step strategy the DBMS uses to execute a query — which indexes to use, join order, algorithms, etc.", ["query processor"]),
            ("What is an index?", "A data structure (typically B-tree or hash) that speeds up data retrieval by providing quick access paths to rows.", ["index"]),
            ("What is a B-tree index?", "A balanced tree structure that maintains sorted data and allows searches, insertions, and deletions in O(log n) time.", ["index"]),
            ("What is a hash index?", "An index using a hash function to map keys to locations. Excellent for equality lookups, poor for range queries.", ["index"]),
            ("What is a clustered vs non-clustered index?", "Clustered: physically reorders data rows to match the index (one per table). Non-clustered: separate structure pointing to data rows (multiple per table).", ["index"]),
            ("What is the buffer pool?", "An area of main memory used to cache database pages, reducing disk I/O. Managed by the buffer manager.", ["buffer manager"]),
            ("What is a page/block?", "The basic unit of data transfer between disk and memory, typically 4KB-16KB in size.", ["storage"]),
            ("What is the difference between a file-based system and a DBMS?", "File-based: data redundancy, inconsistency, no concurrent access, no query language. DBMS: centralized control, data integrity, concurrent access, SQL.", ["comparison"]),
            ("What are advantages of a DBMS?", "Data independence, reduced redundancy, data integrity, concurrent access, security, backup/recovery, query language (SQL).", ["advantages"]),
            ("What are disadvantages of a DBMS?", "Cost (hardware, software, training), complexity, performance overhead for simple applications, single point of failure.", ["disadvantages"]),
            ("What is a stored procedure?", "A precompiled set of SQL statements stored in the database that can be called by name. Improves performance and security.", ["stored procedure"]),
            ("What is a trigger?", "A stored procedure that automatically executes in response to certain events (INSERT, UPDATE, DELETE) on a table.", ["trigger"]),
            ("What is a cursor?", "A database object that allows row-by-row processing of query results, rather than set-based operations.", ["cursor"]),
            ("What is normalization's relationship to DBMS performance?", "Higher normalization reduces redundancy but increases joins. DBAs may denormalize strategically for read performance.", ["performance"]),
            ("What is connection pooling?", "Reusing database connections across multiple requests instead of creating new ones each time. Reduces overhead.", ["performance"]),
            ("What is the purpose of the authorization manager?", "Controls user access to database objects through authentication, permissions (GRANT/REVOKE), and role-based access control.", ["security"]),
            ("What is GRANT and REVOKE?", "SQL commands to give (GRANT) or remove (REVOKE) permissions on database objects to users or roles.", ["security"]),
            ("What is a role in database security?", "A named collection of privileges that can be assigned to users, simplifying permission management.", ["security"]),
            ("What is SQL injection?", "A security vulnerability where malicious SQL code is inserted into application inputs to manipulate database queries. Prevented with parameterized queries.", ["security"]),
        ]
        for c in dbmsCards {
            context.insert(Flashcard(question: c.0, answer: c.1, topic: dbms, tags: c.2))
        }
    }

    // MARK: - Quiz Questions
    private static func seedQuizQuestions(context: ModelContext, relationalModel: Topic, erDiagrams: Topic, keys: Topic, normalization: Topic, ddl: Topic, dml: Topic, models: Topic, dbms: Topic) {

        // --- Relational Model Questions (25+) ---
        let rmQ: [(String, [String], String, String)] = [
            ("What is a tuple in the relational model?", ["A column in a table", "A row in a table", "A constraint on a table", "A key in a table"], "A row in a table", "A tuple is a single row in a relation, representing one record or instance."),
            ("What is the degree of a relation?", ["Number of rows", "Number of columns", "Number of keys", "Number of constraints"], "Number of columns", "Degree refers to the number of attributes (columns) in a relation."),
            ("What is the cardinality of a relation?", ["Number of columns", "Number of rows", "Number of keys", "Number of tables"], "Number of rows", "Cardinality is the number of tuples (rows) in a relation."),
            ("Who proposed the relational model?", ["Charles Bachman", "Peter Chen", "Edgar F. Codd", "Raymond Boyce"], "Edgar F. Codd", "Edgar F. Codd published the relational model in 1970 at IBM."),
            ("Which operation filters rows from a relation?", ["PROJECT", "SELECT", "JOIN", "UNION"], "SELECT", "The SELECT operation (σ) filters tuples based on a condition."),
            ("Which operation selects specific columns?", ["SELECT", "PROJECT", "RENAME", "DIVIDE"], "PROJECT", "The PROJECT operation (π) selects specific attributes, removing duplicates."),
            ("What does relational algebra specify?", ["What data to retrieve", "How to retrieve data", "Where data is stored", "When data was created"], "How to retrieve data", "Relational algebra is procedural — it specifies the operations/steps to retrieve data."),
            ("What does relational calculus specify?", ["How to retrieve data", "What data to retrieve", "Where to store data", "How to update data"], "What data to retrieve", "Relational calculus is non-procedural/declarative — it specifies what is needed, not how."),
            ("What does NULL represent in the relational model?", ["Zero", "Empty string", "Unknown or missing value", "False"], "Unknown or missing value", "NULL represents a missing, unknown, or inapplicable value — distinct from zero or empty string."),
            ("A relation schema defines:", ["The actual data in a table", "The structure of a relation", "The number of rows", "The storage location"], "The structure of a relation", "A relation schema defines the name, attributes, and domains of a relation."),
            ("What is the Cartesian Product of two relations?", ["Only matching rows", "All possible pairs of rows", "Common rows only", "Distinct rows"], "All possible pairs of rows", "The Cartesian Product combines every tuple from one relation with every tuple from another."),
            ("Two relations are union-compatible when:", ["They have the same name", "They have the same number of attributes with compatible domains", "They have the same primary key", "They are in the same database"], "They have the same number of attributes with compatible domains", "Union-compatible means same number of attributes and corresponding domains are compatible."),
            ("A derived relation is also known as a:", ["Base table", "View", "Index", "Trigger"], "View", "A derived relation (view) is a virtual table defined by a query over base relations."),
            ("What is a base relation?", ["A temporary table", "A view", "A physically stored table", "An index"], "A physically stored table", "A base relation is a named relation that physically stores data."),
            ("What is the NATURAL JOIN?", ["Joins on any condition", "Joins on equal values of common attributes", "Joins all rows", "Joins on primary keys only"], "Joins on equal values of common attributes", "Natural Join matches tuples with equal values on all shared attribute names."),
            ("Which relational algebra operation renames?", ["PROJECT", "SELECT", "RENAME", "DIVIDE"], "RENAME", "The RENAME operation (ρ) changes the name of a relation or attributes."),
            ("What is a theta join?", ["Join on equality only", "Join on any comparison condition", "Cross product", "Natural join"], "Join on any comparison condition", "A theta join combines tuples based on any comparison operator (=, <, >, etc.)."),
            ("An outer join preserves:", ["Only matching tuples", "Unmatched tuples", "Duplicate tuples", "NULL tuples only"], "Unmatched tuples", "Outer joins preserve tuples that have no match, filling in NULLs."),
            ("Codd's Rule 1 (Information Rule) states:", ["Data must be encrypted", "All info is represented as values in tables", "Data must be normalized", "All tables need primary keys"], "All info is represented as values in tables", "The Information Rule says all data is represented explicitly by values in tables."),
            ("What is the entity integrity rule?", ["Foreign keys can't be NULL", "Primary keys can't be NULL", "All attributes must be NOT NULL", "Tables must have indexes"], "Primary keys can't be NULL", "Entity integrity requires that no primary key attribute may contain NULL."),
            ("What is the closed world assumption?", ["All data is encrypted", "Facts not in the database are false", "The database is always available", "All queries return results"], "Facts not in the database are false", "If a fact is not recorded in the database, it is assumed to be false."),
            ("What is a self-join?", ["A join between two different tables", "A join of a table with itself", "An inner join", "A cross join"], "A join of a table with itself", "A self-join joins a table with itself, using aliases to distinguish the copies."),
            ("What is the DIVISION operation used for?", ["Finding differences between sets", "Finding all-related tuples", "Dividing numeric values", "Splitting a table"], "Finding all-related tuples", "Division finds tuples in one relation associated with every tuple in another — 'for all' queries."),
            ("A materialized view:", ["Is always up to date", "Stores query results physically", "Cannot be refreshed", "Is the same as a base table"], "Stores query results physically", "A materialized view physically stores query results and must be periodically refreshed."),
            ("Which is NOT a property of a relation?", ["Rows are ordered", "No duplicate rows", "Attribute values are atomic", "Each column has a unique name"], "Rows are ordered", "In the relational model, the order of rows has no significance."),
        ]
        for q in rmQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: relationalModel))
        }

        // --- ER Diagrams Questions (25+) ---
        let erQ: [(String, [String], String, String)] = [
            ("In an ER diagram, a rectangle represents:", ["An attribute", "A relationship", "An entity", "A key"], "An entity", "Entities are represented as rectangles in ER diagrams."),
            ("A diamond shape in an ER diagram represents:", ["An entity", "An attribute", "A relationship", "A key"], "A relationship", "Relationships between entities are shown as diamonds in Chen notation."),
            ("A double-bordered rectangle represents:", ["A strong entity", "A weak entity", "A relationship", "An attribute"], "A weak entity", "Weak entities are shown with double-bordered rectangles because they depend on another entity."),
            ("A dashed oval in an ER diagram represents:", ["A key attribute", "A multivalued attribute", "A derived attribute", "A composite attribute"], "A derived attribute", "Derived attributes are computed from other attributes, shown with dashed ovals."),
            ("A double-bordered oval represents:", ["A derived attribute", "A multivalued attribute", "A key attribute", "A composite attribute"], "A multivalued attribute", "Multivalued attributes can hold multiple values and are shown with double-bordered ovals."),
            ("In Crow's Foot notation, a fork symbol means:", ["One", "Zero", "Many", "Optional"], "Many", "The crow's foot (fork) indicates a maximum cardinality of 'many'."),
            ("In Crow's Foot notation, a circle (O) means:", ["One", "Many", "Zero (optional)", "Required"], "Zero (optional)", "A circle indicates zero minimum cardinality — participation is optional."),
            ("A 1:M relationship means:", ["Each A has one B, each B has one A", "Each A has many Bs, each B has one A", "Each A has many Bs, each B has many As", "Each A has zero Bs"], "Each A has many Bs, each B has one A", "In a 1:M relationship, one instance on the '1' side relates to many on the 'M' side."),
            ("How is an M:N relationship resolved in tables?", ["Add FK to one table", "Add FK to both tables", "Create a junction table", "Merge both tables"], "Create a junction table", "M:N relationships require a junction/bridge table with FKs from both entities."),
            ("What is total participation?", ["Some entities participate", "Every entity must participate in the relationship", "No entities participate", "Only key entities participate"], "Every entity must participate in the relationship", "Total participation means every instance must be involved in the relationship."),
            ("What is partial participation shown as in Chen notation?", ["Double line", "Single line", "Dashed line", "Bold line"], "Single line", "Partial participation uses a single line; total participation uses a double line."),
            ("A weak entity always has:", ["Its own primary key", "A partial key and identifying relationship", "No attributes", "Multiple primary keys"], "A partial key and identifying relationship", "Weak entities have a partial key (discriminator) and depend on an identifying relationship."),
            ("Cardinality defines:", ["Attribute types", "Max instances in a relationship", "Number of tables", "Storage requirements"], "Max instances in a relationship", "Cardinality specifies the maximum number of entity instances in a relationship."),
            ("Which notation is more commonly used in industry?", ["Chen notation", "Crow's Foot notation", "UML notation", "Barker notation"], "Crow's Foot notation", "Crow's Foot is compact and widely used in industry tools."),
            ("A recursive relationship involves:", ["Two different entities", "An entity related to itself", "Three entities", "No entities"], "An entity related to itself", "A recursive (unary) relationship is where an entity is related to itself."),
            ("What is an associative entity?", ["A strong entity", "An entity that resolves M:N relationships", "A weak entity", "An entity with no attributes"], "An entity that resolves M:N relationships", "An associative entity (junction table) resolves M:N relationships into two 1:M relationships."),
            ("In Crow's Foot, || means:", ["Zero or many", "Exactly one (mandatory)", "Zero or one", "One or many"], "Exactly one (mandatory)", "Two single dashes indicate mandatory participation with a cardinality of exactly one."),
            ("In Crow's Foot, O< means:", ["Exactly one", "One or many", "Zero or many", "Zero or one"], "Zero or many", "Circle (O) for optional + crow's foot (<) for many = zero or many."),
            ("Generalization in ER modeling is:", ["Splitting an entity into subtypes", "Combining entity types into a supertype", "Creating new entities", "Removing entities"], "Combining entity types into a supertype", "Generalization combines multiple entity types with common attributes into a higher-level entity."),
            ("Specialization in ER modeling is:", ["Combining entities", "Dividing a supertype into subtypes", "Removing entities", "Adding attributes"], "Dividing a supertype into subtypes", "Specialization divides a higher-level entity into lower-level subtypes."),
            ("In disjoint specialization:", ["An entity can belong to multiple subtypes", "An entity belongs to only one subtype", "All entities must be in a subtype", "No entities are in subtypes"], "An entity belongs to only one subtype", "Disjoint (d) means each supertype instance belongs to at most one subtype."),
            ("A ternary relationship involves:", ["One entity", "Two entities", "Three entities", "Four entities"], "Three entities", "A ternary relationship connects three entity types."),
            ("How is a 1:1 relationship mapped to tables?", ["Create a junction table", "Add FK in one table referencing the other", "Merge both tables", "Use a view"], "Add FK in one table referencing the other", "Place the PK of one side as a FK (with UNIQUE) in the other table."),
            ("Modality refers to:", ["Maximum cardinality", "Minimum cardinality (0 or 1)", "Number of entities", "Degree of relationship"], "Minimum cardinality (0 or 1)", "Modality indicates whether participation is optional (0) or mandatory (1)."),
            ("What is an attribute of a relationship?", ["An attribute belonging to an entity", "An attribute that describes the relationship itself", "A primary key", "A foreign key"], "An attribute that describes the relationship itself", "Some relationships have their own attributes, like 'grade' on an Enrollment relationship."),
            ("Chen notation uses what shape for attributes?", ["Rectangle", "Diamond", "Oval", "Triangle"], "Oval", "Attributes are represented as ovals in Chen notation."),
        ]
        for q in erQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: erDiagrams))
        }

        // --- Keys Questions (25+) ---
        let keyQ: [(String, [String], String, String)] = [
            ("A candidate key is:", ["Any superkey", "A minimal superkey", "The primary key", "A foreign key"], "A minimal superkey", "A candidate key is a superkey from which no attribute can be removed without losing uniqueness."),
            ("How many primary keys can a table have?", ["Zero", "One", "Two", "Unlimited"], "One", "A table can have only one primary key, though it may be composite (multiple columns)."),
            ("A surrogate key is:", ["A natural business attribute", "A system-generated artificial key", "A foreign key", "A composite key"], "A system-generated artificial key", "A surrogate key is system-generated (e.g., auto-increment) with no business meaning."),
            ("Referential integrity ensures:", ["All columns have indexes", "FK values match PK values in the referenced table", "Tables are normalized", "Primary keys are auto-generated"], "FK values match PK values in the referenced table", "Referential integrity requires FK values to match existing PK values or be NULL."),
            ("CASCADE on DELETE means:", ["Prevent the deletion", "Set FK to NULL", "Delete referencing rows too", "Ignore the constraint"], "Delete referencing rows too", "CASCADE automatically deletes all rows that reference the deleted row."),
            ("A composite key consists of:", ["One column", "Two or more columns", "No columns", "All columns"], "Two or more columns", "A composite key uses multiple columns together to uniquely identify rows."),
            ("An alternate key is:", ["The primary key", "A candidate key not chosen as PK", "A foreign key", "A superkey"], "A candidate key not chosen as PK", "Alternate keys are candidate keys that were not selected as the primary key."),
            ("Can a foreign key be NULL?", ["Never", "Always", "Yes, unless NOT NULL is specified", "Only in weak entities"], "Yes, unless NOT NULL is specified", "A FK can be NULL if there's no NOT NULL constraint, indicating an optional relationship."),
            ("Entity integrity states:", ["FKs cannot be NULL", "PKs cannot be NULL", "All columns must have values", "Tables must have indexes"], "PKs cannot be NULL", "Entity integrity requires that no primary key attribute may contain NULL."),
            ("What is SET NULL on DELETE?", ["Delete referencing rows", "Prevent deletion", "Set FK values to NULL", "Set FK to default"], "Set FK values to NULL", "SET NULL changes the FK value to NULL when the referenced row is deleted."),
            ("A natural key is:", ["System-generated", "Derived from real-world data", "Always numeric", "A composite key"], "Derived from real-world data", "Natural keys use existing meaningful attributes, like SSN or email."),
            ("What is RESTRICT on DELETE?", ["Delete referencing rows", "Prevent deletion if references exist", "Set FK to NULL", "Ignore the constraint"], "Prevent deletion if references exist", "RESTRICT prevents deletion of a row that is still referenced by other rows."),
            ("In a junction table, the PK is typically:", ["A single auto-increment column", "A composite of two FKs", "The first FK only", "No primary key"], "A composite of two FKs", "Junction tables typically use a composite PK made of FKs from both related tables."),
            ("A self-referencing FK:", ["References another table", "References the same table's PK", "Is always NULL", "Cannot exist"], "References the same table's PK", "A self-referencing FK points to the PK of the same table (e.g., manager_id → employee_id)."),
            ("What makes a good primary key?", ["Changes frequently", "Contains business meaning", "Is unique, stable, and non-null", "Is always a string"], "Is unique, stable, and non-null", "Good PKs are unique, never null, stable, minimal, and ideally system-generated."),
            ("A superkey is:", ["Always minimal", "Any set of attributes that uniquely identifies tuples", "The primary key only", "A foreign key"], "Any set of attributes that uniquely identifies tuples", "A superkey is any set of attributes that uniquely identifies tuples. It may not be minimal."),
            ("ON UPDATE CASCADE:", ["Prevents updates to PK", "Updates FK values when PK changes", "Deletes rows on update", "Sets FK to NULL"], "Updates FK values when PK changes", "ON UPDATE CASCADE automatically updates FK values when the referenced PK value changes."),
            ("UNIQUE constraint differs from PRIMARY KEY because:", ["UNIQUE cannot be on multiple columns", "UNIQUE allows NULL and multiple per table", "UNIQUE is faster", "UNIQUE enforces NOT NULL"], "UNIQUE allows NULL and multiple per table", "UNIQUE allows NULL values and a table can have multiple UNIQUE constraints, but only one PK."),
            ("A dangling reference is:", ["A FK with no matching PK", "A PK with no FK reference", "An orphan table", "A missing index"], "A FK with no matching PK", "A dangling reference is a FK value that doesn't match any PK — a referential integrity violation."),
            ("Key inheritance occurs with:", ["Strong entities", "Weak entities", "All entities", "Views"], "Weak entities", "Weak entities inherit the PK of their owner entity as part of their own key."),
            ("A business key is another name for:", ["Surrogate key", "Natural key", "Foreign key", "Composite key"], "Natural key", "A business key (natural key) is derived from real-world business data."),
            ("Can a table have multiple candidate keys?", ["No, only one", "Yes", "Only with composite keys", "Only in normalized tables"], "Yes", "A table can have multiple candidate keys; one is chosen as the PK, the rest are alternate keys."),
            ("What is NO ACTION on DELETE?", ["Delete all references", "Check at statement end, reject if violation", "Set FK to NULL", "Same as CASCADE"], "Check at statement end, reject if violation", "NO ACTION defers the referential integrity check to the end of the statement."),
            ("A GUID/UUID is a type of:", ["Natural key", "Surrogate key", "Foreign key", "Alternate key"], "Surrogate key", "GUIDs are system-generated globally unique identifiers used as surrogate keys."),
            ("Why avoid changeable data as a PK?", ["It's too large", "It's not unique", "Changes require cascading FK updates", "It can't be indexed"], "Changes require cascading FK updates", "If a PK changes, all referencing FK values must also update, risking inconsistency."),
        ]
        for q in keyQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: keys))
        }

        // --- Normalization Questions (25+) ---
        let normQ: [(String, [String], String, String)] = [
            ("1NF requires:", ["No partial dependencies", "No transitive dependencies", "Atomic values only", "Every determinant is a superkey"], "Atomic values only", "First Normal Form requires all attribute values to be atomic (indivisible) with no repeating groups."),
            ("2NF eliminates:", ["Transitive dependencies", "Partial dependencies", "Multivalued dependencies", "All redundancy"], "Partial dependencies", "2NF removes partial dependencies — where a non-key attribute depends on part of a composite PK."),
            ("3NF eliminates:", ["Partial dependencies", "Transitive dependencies", "Join dependencies", "Multivalued dependencies"], "Transitive dependencies", "3NF removes transitive dependencies — where non-key attributes depend on other non-key attributes."),
            ("BCNF requires that:", ["All attributes are atomic", "No partial dependencies exist", "Every determinant is a superkey", "No multivalued dependencies exist"], "Every determinant is a superkey", "In BCNF, for every functional dependency X → Y, X must be a superkey."),
            ("A functional dependency X → Y means:", ["X is determined by Y", "Y is determined by X", "X and Y are equal", "X and Y are independent"], "Y is determined by X", "X → Y means the value of X uniquely determines the value of Y."),
            ("An insertion anomaly is:", ["Inability to insert due to missing data", "Inserting duplicate data", "Inserting NULL values", "Inserting into a view"], "Inability to insert due to missing data", "Insertion anomalies occur when you can't add data without other required data being present."),
            ("An update anomaly is:", ["Failure to update a view", "Inconsistency from updating only some copies", "Updating the schema", "Updating primary keys"], "Inconsistency from updating only some copies", "Update anomalies occur when redundant data is changed in some places but not others."),
            ("A deletion anomaly is:", ["Accidental loss of unrelated data", "Deleting a constraint", "Deleting an index", "Deleting a view"], "Accidental loss of unrelated data", "Deletion anomalies cause unintended loss of data when a row containing the only copy is deleted."),
            ("Denormalization is:", ["Removing all redundancy", "Intentionally adding redundancy for performance", "Normalizing to BCNF", "Removing tables"], "Intentionally adding redundancy for performance", "Denormalization trades data integrity for faster reads by introducing controlled redundancy."),
            ("2NF violations can only occur when:", ["The table has no keys", "The PK is composite", "The PK is a single column", "The table has foreign keys"], "The PK is composite", "Partial dependencies require a composite PK — you can't depend on 'part' of a single-column PK."),
            ("A transitive dependency is: A → B → C, where:", ["A, B, C are all keys", "C depends on A through B (non-key)", "B depends on C", "A depends on C"], "C depends on A through B (non-key)", "In a transitive dependency, C depends on B, and B depends on A, so C transitively depends on A."),
            ("Lossless decomposition means:", ["Some data may be lost", "Original data can be perfectly reconstructed", "Data is compressed", "Redundancy is eliminated"], "Original data can be perfectly reconstructed", "Lossless decomposition ensures the original relation is recoverable by joining the decomposed tables."),
            ("Armstrong's Axioms include:", ["Reflexivity, Augmentation, Transitivity", "Atomicity, Consistency, Isolation", "Selection, Projection, Join", "Create, Read, Update, Delete"], "Reflexivity, Augmentation, Transitivity", "Armstrong's Axioms are inference rules for deriving functional dependencies."),
            ("A prime attribute is:", ["Part of a candidate key", "A primary key", "A non-key attribute", "Always numeric"], "Part of a candidate key", "A prime attribute is any attribute that participates in at least one candidate key."),
            ("The closure of attributes X⁺ is:", ["All attributes determined by X", "All attributes in the table", "The primary key", "All candidate keys"], "All attributes determined by X", "X⁺ includes all attributes that can be functionally determined from X."),
            ("Which normal form handles multivalued dependencies?", ["2NF", "3NF", "BCNF", "4NF"], "4NF", "Fourth Normal Form deals with non-trivial multivalued dependencies."),
            ("A repeating group violates:", ["2NF", "3NF", "1NF", "BCNF"], "1NF", "Repeating groups (non-atomic values) are a direct violation of First Normal Form."),
            ("Good ER design typically produces tables in:", ["1NF only", "2NF only", "3NF naturally", "BCNF always"], "3NF naturally", "Well-designed ER models usually map to relations that are in 3NF or close to it."),
            ("Dependency preservation means:", ["All data is preserved", "All FDs can be checked without joins", "Dependencies are removed", "Only key dependencies remain"], "All FDs can be checked without joins", "Dependency-preserving decomposition allows checking all original FDs within individual tables."),
            ("Over-normalization can cause:", ["Data redundancy", "Too many joins and poor performance", "Anomalies", "Security issues"], "Too many joins and poor performance", "Excessive normalization creates many small tables requiring complex joins, reducing query performance."),
            ("A universal relation is:", ["A single table with all attributes", "A normalized table", "A view", "A junction table"], "A single table with all attributes", "A universal relation contains all attributes of the database in one table — the starting point for normalization."),
            ("If PK is (A, B) and C depends only on A, this violates:", ["1NF", "2NF", "3NF", "BCNF"], "2NF", "C partially depends on the composite key (only on A, not the full key A,B), violating 2NF."),
            ("3NF allows X → Y where Y is:", ["Part of a candidate key", "Any attribute", "Only the primary key", "Never allowed"], "Part of a candidate key", "3NF allows non-key → key dependencies if Y is part of a candidate key (unlike BCNF)."),
            ("Normalization reduces:", ["Query performance", "Data redundancy", "Number of tables", "Storage space always"], "Data redundancy", "The primary goal of normalization is to eliminate data redundancy and prevent anomalies."),
            ("BCNF is stricter than 3NF because:", ["It requires atomic values", "Every determinant must be a superkey", "It eliminates all dependencies", "It requires no foreign keys"], "Every determinant must be a superkey", "BCNF doesn't allow the 3NF exception — every functional dependency's determinant must be a superkey."),
            ("A canonical cover is:", ["The largest set of FDs", "A minimal equivalent set of FDs", "All possible FDs", "Only key dependencies"], "A minimal equivalent set of FDs", "A canonical cover is a minimal set of functional dependencies equivalent to the original with no redundancy."),
        ]
        for q in normQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: normalization))
        }

        // --- DDL Questions (25+) ---
        let ddlQ: [(String, [String], String, String)] = [
            ("DDL stands for:", ["Data Definition Language", "Data Deletion Language", "Data Description Language", "Data Design Language"], "Data Definition Language", "DDL commands define and modify database structure: CREATE, ALTER, DROP, TRUNCATE."),
            ("Which command creates a new table?", ["INSERT TABLE", "CREATE TABLE", "ADD TABLE", "NEW TABLE"], "CREATE TABLE", "CREATE TABLE defines a new table with its columns, data types, and constraints."),
            ("Which command permanently removes a table?", ["DELETE TABLE", "REMOVE TABLE", "DROP TABLE", "TRUNCATE TABLE"], "DROP TABLE", "DROP TABLE permanently removes the table and all its data from the database."),
            ("ALTER TABLE is used to:", ["Query data", "Modify table structure", "Insert data", "Delete data"], "Modify table structure", "ALTER TABLE adds/drops columns, modifies data types, and manages constraints."),
            ("NOT NULL constraint ensures:", ["Unique values", "No NULL values allowed", "Values match a pattern", "Default values are set"], "No NULL values allowed", "NOT NULL requires that every row must have a value for the column."),
            ("How many PRIMARY KEY constraints per table?", ["Zero", "One", "Two", "Unlimited"], "One", "A table can have exactly one PRIMARY KEY constraint, though it may span multiple columns."),
            ("CHECK constraint does what?", ["Verifies data types", "Limits values based on a condition", "Ensures uniqueness", "Creates an index"], "Limits values based on a condition", "CHECK validates that column values satisfy a specified condition."),
            ("DEFAULT constraint provides:", ["A fallback value when none is specified", "A unique value", "A NULL value", "An auto-increment value"], "A fallback value when none is specified", "DEFAULT specifies the value to use when no explicit value is provided during INSERT."),
            ("CREATE INDEX is used to:", ["Create a table", "Speed up data retrieval", "Create a constraint", "Create a view"], "Speed up data retrieval", "Indexes create data structures that allow faster searching and retrieval."),
            ("TRUNCATE TABLE vs DELETE:", ["TRUNCATE is DML, DELETE is DDL", "TRUNCATE removes all rows faster, DELETE can use WHERE", "They are identical", "TRUNCATE keeps data, DELETE removes it"], "TRUNCATE removes all rows faster, DELETE can use WHERE", "TRUNCATE is DDL (fast, no WHERE), DELETE is DML (logged per row, supports WHERE)."),
            ("VARCHAR(50) vs CHAR(50):", ["No difference", "VARCHAR is variable-length, CHAR is fixed-length", "CHAR is variable-length", "VARCHAR can't store strings"], "VARCHAR is variable-length, CHAR is fixed-length", "VARCHAR uses only the space needed; CHAR always uses the full specified length."),
            ("DECIMAL(8,2) can store:", ["Up to 8 digits with 2 after the decimal", "8 values of 2 digits each", "Up to 82 digits", "2 digits with 8 decimal places"], "Up to 8 digits with 2 after the decimal", "DECIMAL(8,2) allows 6 digits before and 2 after the decimal point, e.g., 999999.99."),
            ("A composite primary key is defined:", ["Inline with one column", "As a table-level constraint", "Using ALTER TABLE only", "In a separate file"], "As a table-level constraint", "Composite PKs spanning multiple columns must be defined as table-level constraints."),
            ("IF NOT EXISTS in CREATE TABLE:", ["Is required", "Prevents error if table already exists", "Deletes existing table first", "Creates a temporary table"], "Prevents error if table already exists", "IF NOT EXISTS is a safety clause that silently skips creation if the table already exists."),
            ("AUTO_INCREMENT / IDENTITY is used for:", ["String columns", "Automatically generating unique sequential numbers", "Creating indexes", "Defining foreign keys"], "Automatically generating unique sequential numbers", "AUTO_INCREMENT generates unique sequential values, typically for surrogate primary keys."),
            ("How do you add a constraint to an existing table?", ["CREATE CONSTRAINT", "ALTER TABLE ADD CONSTRAINT", "INSERT CONSTRAINT", "UPDATE CONSTRAINT"], "ALTER TABLE ADD CONSTRAINT", "Use ALTER TABLE table_name ADD CONSTRAINT constraint_name ... to add constraints."),
            ("A FOREIGN KEY constraint uses which clause?", ["JOINS", "LINKS TO", "REFERENCES", "CONNECTS"], "REFERENCES", "The REFERENCES clause specifies which table and column the FK points to."),
            ("DROP TABLE IF EXISTS:", ["Always drops the table", "Only drops if the table exists", "Creates a backup first", "Is not valid SQL"], "Only drops if the table exists", "IF EXISTS prevents an error when trying to drop a table that doesn't exist."),
            ("Which data type is best for currency?", ["FLOAT", "INT", "DECIMAL", "VARCHAR"], "DECIMAL", "DECIMAL (fixed-point) avoids floating-point precision errors that FLOAT would cause."),
            ("A temporary table:", ["Persists after session ends", "Exists only during the session", "Cannot be queried", "Is always empty"], "Exists only during the session", "Temporary tables are automatically dropped when the session or transaction ends."),
            ("CREATE VIEW creates:", ["A physical table", "A virtual table based on a query", "An index", "A stored procedure"], "A virtual table based on a query", "A view is a virtual table defined by a SELECT query."),
            ("How to rename a table?", ["RENAME TABLE old TO new", "ALTER TABLE old RENAME TO new", "Both A and B work (varies by DBMS)", "You cannot rename tables"], "Both A and B work (varies by DBMS)", "Syntax varies by DBMS but ALTER TABLE RENAME TO is widely supported."),
            ("A generated/computed column:", ["Is manually entered", "Is automatically computed from other columns", "Cannot be queried", "Is always indexed"], "Is automatically computed from other columns", "A computed column's value is derived automatically, e.g., total AS (quantity * price)."),
            ("Which is NOT a DDL command?", ["CREATE", "ALTER", "SELECT", "DROP"], "SELECT", "SELECT is a DML command for querying data, not defining structure."),
            ("A schema in SQL is:", ["A table", "A namespace for database objects", "An index", "A constraint"], "A namespace for database objects", "A schema groups related database objects (tables, views, etc.) and manages organization."),
        ]
        for q in ddlQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: ddl))
        }

        // --- DML Questions (25+) ---
        let dmlQ: [(String, [String], String, String)] = [
            ("DML stands for:", ["Data Manipulation Language", "Data Management Language", "Data Modification Language", "Data Modeling Language"], "Data Manipulation Language", "DML commands manipulate data: SELECT, INSERT, UPDATE, DELETE."),
            ("Which command retrieves data?", ["INSERT", "UPDATE", "SELECT", "CREATE"], "SELECT", "SELECT retrieves data from one or more tables based on specified criteria."),
            ("DELETE without WHERE will:", ["Do nothing", "Delete one row", "Delete all rows", "Drop the table"], "Delete all rows", "DELETE without WHERE removes ALL rows from the table — a dangerous operation."),
            ("INNER JOIN returns:", ["All rows from both tables", "Only matching rows", "All rows from the left table", "All rows from the right table"], "Only matching rows", "INNER JOIN returns only rows that have matching values in both tables."),
            ("LEFT JOIN preserves:", ["All rows from the right table", "All rows from the left table", "Only matching rows", "No rows"], "All rows from the left table", "LEFT JOIN keeps all left table rows, filling NULLs for unmatched right table columns."),
            ("GROUP BY is used with:", ["INSERT statements", "Aggregate functions", "DROP statements", "ALTER statements"], "Aggregate functions", "GROUP BY groups rows for aggregate calculations like COUNT, SUM, AVG."),
            ("WHERE vs HAVING:", ["WHERE filters groups, HAVING filters rows", "WHERE filters rows before grouping, HAVING filters after", "They are identical", "HAVING comes before WHERE"], "WHERE filters rows before grouping, HAVING filters after", "WHERE filters individual rows; HAVING filters grouped/aggregated results."),
            ("DISTINCT removes:", ["NULL values", "Duplicate rows from results", "Columns", "Tables"], "Duplicate rows from results", "DISTINCT eliminates duplicate rows from the result set."),
            ("COUNT(*) vs COUNT(column):", ["They're identical", "COUNT(*) includes NULLs, COUNT(column) doesn't", "COUNT(column) is faster", "COUNT(*) only counts keys"], "COUNT(*) includes NULLs, COUNT(column) doesn't", "COUNT(*) counts all rows; COUNT(column) counts only non-NULL values in that column."),
            ("A correlated subquery:", ["Runs once", "References the outer query", "Is always faster", "Cannot use WHERE"], "References the outer query", "A correlated subquery references columns from the outer query and executes per outer row."),
            ("The LIKE operator uses which wildcards?", ["* and ?", "% and _", "# and @", ". and *"], "% and _", "% matches any sequence of characters; _ matches exactly one character."),
            ("BETWEEN is:", ["Exclusive on both ends", "Inclusive on both ends", "Inclusive start, exclusive end", "Only for dates"], "Inclusive on both ends", "BETWEEN includes both boundary values: WHERE x BETWEEN 1 AND 10 includes 1 and 10."),
            ("IS NULL is used because:", ["NULL = NULL returns TRUE", "You cannot compare NULL with =", "NULL is a number", "NULL means zero"], "You cannot compare NULL with =", "NULL represents unknown, so NULL = NULL is undefined. You must use IS NULL."),
            ("UNION vs UNION ALL:", ["UNION keeps duplicates, UNION ALL removes them", "UNION removes duplicates, UNION ALL keeps them", "They are identical", "UNION ALL is slower"], "UNION removes duplicates, UNION ALL keeps them", "UNION deduplicates results; UNION ALL is faster because it keeps all rows."),
            ("SQL execution order starts with:", ["SELECT", "FROM", "WHERE", "ORDER BY"], "FROM", "SQL processes: FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT."),
            ("An alias in SQL:", ["Permanently renames a table", "Gives a temporary name", "Creates a copy", "Drops a column"], "Gives a temporary name", "Aliases provide temporary names for tables or columns within a query."),
            ("FULL OUTER JOIN returns:", ["Only matching rows", "All rows from both tables with NULLs for non-matches", "All rows from the left only", "A Cartesian product"], "All rows from both tables with NULLs for non-matches", "FULL OUTER JOIN returns all rows from both tables, filling NULLs where there's no match."),
            ("A CROSS JOIN produces:", ["Only matching rows", "The Cartesian product", "Distinct rows only", "A left join"], "The Cartesian product", "CROSS JOIN returns every combination of rows from both tables."),
            ("CASE expression provides:", ["Loop functionality", "Conditional if-then-else logic", "Transaction control", "Index creation"], "Conditional if-then-else logic", "CASE WHEN condition THEN result ELSE default END provides conditional logic in SQL."),
            ("INSERT INTO ... SELECT:", ["Creates a new table", "Inserts rows from a query result", "Updates existing rows", "Deletes and reinserts"], "Inserts rows from a query result", "This inserts data into a table using results from a SELECT query."),
            ("COALESCE returns:", ["The last argument", "The first non-NULL argument", "The sum of arguments", "NULL always"], "The first non-NULL argument", "COALESCE evaluates arguments in order and returns the first non-NULL value."),
            ("Aggregate functions handle NULLs by:", ["Counting them", "Ignoring them (except COUNT(*))", "Converting to zero", "Raising an error"], "Ignoring them (except COUNT(*))", "SUM, AVG, MIN, MAX all skip NULL values. Only COUNT(*) includes NULLs."),
            ("EXISTS checks:", ["If a column exists", "If a table exists", "If a subquery returns any rows", "If a value is NULL"], "If a subquery returns any rows", "EXISTS returns TRUE if the subquery result set is non-empty."),
            ("EXCEPT/MINUS returns:", ["All rows from both queries", "Rows in first query but not in second", "Only duplicate rows", "Rows in second query but not first"], "Rows in first query but not in second", "EXCEPT returns rows from the first query that don't appear in the second."),
            ("A derived table is:", ["A permanent table", "A subquery in the FROM clause", "A view", "An index"], "A subquery in the FROM clause", "A derived table is a subquery used in the FROM clause, acting as a temporary inline table."),
            ("Which is the correct multi-table JOIN?", ["SELECT * FROM a, b WHERE a.id = b.id", "SELECT * FROM a JOIN b ON a.id = b.id", "Both are valid (implicit vs explicit join)", "Neither is valid"], "Both are valid (implicit vs explicit join)", "Both work, but explicit JOIN syntax (ANSI) is preferred for clarity and maintainability."),
        ]
        for q in dmlQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: dml))
        }

        // --- Models Questions (25+) ---
        let modQ: [(String, [String], String, String)] = [
            ("The conceptual model focuses on:", ["Storage details", "High-level entities and relationships", "SQL syntax", "Indexes and partitions"], "High-level entities and relationships", "The conceptual model captures what data exists at a business level, without implementation details."),
            ("The logical model includes:", ["Physical storage details", "Attributes, keys, and normalization", "Server configurations", "File structures"], "Attributes, keys, and normalization", "The logical model details attributes, PKs/FKs, data types, and normalization — DBMS-independent."),
            ("The physical model specifies:", ["Business requirements", "DBMS-specific implementation details", "Entity relationships only", "User views only"], "DBMS-specific implementation details", "The physical model includes actual tables, indexes, partitions, and storage for a specific DBMS."),
            ("The three-schema architecture provides:", ["Data compression", "Data independence", "Data encryption", "Data deletion"], "Data independence", "The ANSI/SPARC three-schema architecture separates concerns to provide data independence."),
            ("The external schema represents:", ["The entire database", "Individual user views", "Physical storage", "Transaction logs"], "Individual user views", "Each user/application sees a customized external view of the relevant data."),
            ("Physical data independence means:", ["Changing physical storage doesn't affect logical schema", "Changing logical schema doesn't affect physical", "Data is independent of users", "Data exists without a database"], "Changing physical storage doesn't affect logical schema", "Physical data independence lets you change storage/indexing without affecting the conceptual schema."),
            ("Logical data independence means:", ["Changing logical schema doesn't affect external schemas", "Changing views doesn't affect tables", "Physical changes affect logic", "Data is self-describing"], "Changing logical schema doesn't affect external schemas", "Logical data independence lets you change the conceptual schema without affecting user applications."),
            ("A schema is:", ["The actual data", "The structural definition", "A query", "A user"], "The structural definition", "A schema describes the structure (tables, columns, types, constraints) — not the data itself."),
            ("An instance is:", ["The schema definition", "The actual data at a point in time", "A constraint", "An index"], "The actual data at a point in time", "An instance is the current content of the database — it changes as data is modified."),
            ("Metadata is:", ["User data", "Data about data", "Encrypted data", "Deleted data"], "Data about data", "Metadata describes the structure, format, and constraints of actual data."),
            ("The data dictionary stores:", ["User passwords only", "Metadata about database objects", "Application code", "Backup data"], "Metadata about database objects", "The data dictionary contains information about tables, columns, types, constraints, and relationships."),
            ("Forward engineering is:", ["Creating a database from a model", "Creating a model from a database", "Optimizing queries", "Backing up data"], "Creating a database from a model", "Forward engineering generates the physical database from a logical/conceptual design."),
            ("Reverse engineering is:", ["Creating a model from an existing database", "Creating a database from a model", "Deleting a database", "Migrating data"], "Creating a model from an existing database", "Reverse engineering extracts a model from an existing physical database implementation."),
            ("OLTP systems are designed for:", ["Complex analytical queries", "Many short transactions", "Data warehousing", "Report generation"], "Many short transactions", "OLTP handles day-to-day operations with many concurrent short transactions."),
            ("OLAP systems are designed for:", ["Transaction processing", "Complex analytical queries", "Data entry", "Real-time updates"], "Complex analytical queries", "OLAP handles complex queries for business analysis and decision support."),
            ("A star schema has:", ["Only dimension tables", "A central fact table with surrounding dimension tables", "Only fact tables", "Normalized dimension tables"], "A central fact table with surrounding dimension tables", "A star schema centers on a fact table connected to denormalized dimension tables."),
            ("A fact table contains:", ["Descriptive attributes", "Measurable quantitative data and FKs", "Only primary keys", "User information"], "Measurable quantitative data and FKs", "Fact tables store measurements/metrics and foreign keys linking to dimension tables."),
            ("Domain constraints restrict:", ["Table names", "Values an attribute can hold", "Number of tables", "Number of users"], "Values an attribute can hold", "Domain constraints define the valid set of values for an attribute based on type and range."),
            ("Business rules are translated into:", ["Comments", "Database constraints and application logic", "Table names", "Column names"], "Database constraints and application logic", "Business rules become CHECK constraints, triggers, stored procedures, or application code."),
            ("How is a multivalued attribute mapped?", ["Add multiple columns", "Create a separate table with FK", "Store as comma-separated values", "Ignore it"], "Create a separate table with FK", "Multivalued attributes get their own table with the entity's PK as a FK."),
            ("How is a composite attribute mapped?", ["Store the composite as one column", "Store only the simple components", "Create a separate table", "Use a JSON column"], "Store only the simple components", "Only the leaf-level simple attributes are stored as columns; the composite name is discarded."),
            ("The hierarchical model uses:", ["Tables", "Tree structure", "Graph structure", "Objects"], "Tree structure", "The hierarchical model organizes data in parent-child tree relationships."),
            ("The network model differs from hierarchical by:", ["Using tables", "Allowing multiple parents", "Using only one parent", "Having no relationships"], "Allowing multiple parents", "The network model allows a child to have multiple parent records, forming a graph."),
            ("Data abstraction hides:", ["All data", "Implementation complexity", "User interfaces", "Network details"], "Implementation complexity", "Data abstraction shows essential features while hiding underlying complexity."),
            ("Which type of data independence is harder to achieve?", ["Physical", "Logical", "They're equally difficult", "Neither is difficult"], "Logical", "Logical data independence is harder because conceptual schema changes are more likely to affect apps."),
        ]
        for q in modQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: models))
        }

        // --- DBMS Architecture Questions (25+) ---
        let dbmsQ: [(String, [String], String, String)] = [
            ("DBMS stands for:", ["Database Management System", "Data Backup Management System", "Database Modeling System", "Data Building Management System"], "Database Management System", "A DBMS is software for creating, managing, and querying databases with data integrity and security."),
            ("ACID stands for:", ["Access, Control, Integrity, Design", "Atomicity, Consistency, Isolation, Durability", "Authentication, Concurrency, Independence, Data", "Automatic, Centralized, Integrated, Distributed"], "Atomicity, Consistency, Isolation, Durability", "ACID properties ensure reliable transaction processing in databases."),
            ("Atomicity means:", ["Transactions can be split", "All or nothing — complete success or full rollback", "Data is stored in atoms", "Each operation is atomic"], "All or nothing — complete success or full rollback", "Atomicity treats a transaction as indivisible — either all operations succeed or none do."),
            ("Durability ensures:", ["Transactions are fast", "Committed changes survive system failures", "Data is encrypted", "Queries are optimized"], "Committed changes survive system failures", "Durability guarantees that once committed, changes persist despite crashes or power failures."),
            ("COMMIT does what?", ["Undoes changes", "Makes transaction changes permanent", "Locks a table", "Creates a savepoint"], "Makes transaction changes permanent", "COMMIT finalizes all changes made during the current transaction."),
            ("ROLLBACK does what?", ["Saves changes", "Undoes all changes in the current transaction", "Commits and closes", "Creates a new transaction"], "Undoes all changes in the current transaction", "ROLLBACK reverts the database to its state before the transaction began."),
            ("A deadlock occurs when:", ["A query is too slow", "Two transactions wait for each other's locks", "The database runs out of space", "A table is dropped"], "Two transactions wait for each other's locks", "Deadlock is a circular dependency where transactions block each other indefinitely."),
            ("A shared lock allows:", ["Only one transaction to read", "Multiple transactions to read", "One transaction to write", "No access"], "Multiple transactions to read", "A shared (read) lock permits concurrent reads but blocks writes."),
            ("An exclusive lock allows:", ["Multiple transactions to write", "Only one transaction to read/write", "Shared reading", "No locking"], "Only one transaction to read/write", "An exclusive (write) lock gives sole access to one transaction."),
            ("Write-ahead logging (WAL):", ["Writes data before logging", "Writes log before applying changes", "Never uses logs", "Only logs reads"], "Writes log before applying changes", "WAL ensures changes are logged before being applied, enabling recovery after failures."),
            ("A checkpoint:", ["Deletes old data", "Writes all modified pages to disk", "Creates a backup", "Locks the database"], "Writes all modified pages to disk", "Checkpoints flush modified buffer pages to disk, creating a recovery point."),
            ("Two-phase locking ensures:", ["Fast transactions", "Serializability", "No locks needed", "Parallel writes"], "Serializability", "2PL's growing/shrinking phases guarantee that concurrent execution is equivalent to serial."),
            ("READ UNCOMMITTED allows:", ["No anomalies", "Dirty reads", "Only committed reads", "Serializable execution"], "Dirty reads", "READ UNCOMMITTED is the lowest isolation level, allowing reads of uncommitted data."),
            ("SERIALIZABLE isolation:", ["Is the weakest level", "Provides the strongest consistency", "Allows dirty reads", "Is the default everywhere"], "Provides the strongest consistency", "SERIALIZABLE prevents dirty reads, non-repeatable reads, and phantom reads."),
            ("The query optimizer:", ["Executes queries directly", "Finds the most efficient execution plan", "Stores query results", "Manages user permissions"], "Finds the most efficient execution plan", "The optimizer evaluates different strategies to determine the best way to execute a query."),
            ("A B-tree index:", ["Only supports equality lookups", "Is a balanced tree for O(log n) access", "Stores data unsorted", "Cannot be updated"], "Is a balanced tree for O(log n) access", "B-trees maintain sorted data in a balanced tree, enabling efficient search, insert, and delete."),
            ("A clustered index:", ["Can have many per table", "Physically reorders table data", "Is always a hash index", "Is slower than non-clustered"], "Physically reorders table data", "A clustered index sorts and stores data rows in the index order — only one per table."),
            ("The buffer manager:", ["Manages user sessions", "Manages data transfer between disk and memory", "Creates tables", "Manages indexes"], "Manages data transfer between disk and memory", "The buffer manager decides which pages to cache in memory and when to write them to disk."),
            ("A stored procedure is:", ["A temporary table", "Precompiled SQL stored in the database", "An index type", "A constraint"], "Precompiled SQL stored in the database", "Stored procedures are reusable, precompiled SQL programs stored and executed within the database."),
            ("A trigger fires:", ["On user login", "Automatically in response to data changes", "When a query is optimized", "When backup runs"], "Automatically in response to data changes", "Triggers execute automatically when INSERT, UPDATE, or DELETE events occur on a table."),
            ("GRANT is used to:", ["Remove permissions", "Give permissions to users", "Create users", "Drop tables"], "Give permissions to users", "GRANT assigns specific privileges (SELECT, INSERT, etc.) on database objects to users/roles."),
            ("SQL injection is prevented by:", ["Using longer passwords", "Parameterized queries", "Creating more indexes", "Using surrogate keys"], "Parameterized queries", "Parameterized/prepared statements separate SQL code from data, preventing injection attacks."),
            ("Advantages of a DBMS over file systems include:", ["Simpler implementation", "Data integrity, concurrent access, and SQL", "Lower cost", "Less storage needed"], "Data integrity, concurrent access, and SQL", "DBMSs provide centralized control, integrity, concurrency, security, and a standard query language."),
            ("A SAVEPOINT allows:", ["Committing part of a transaction", "Rolling back to a specific point in a transaction", "Saving the database", "Creating a backup"], "Rolling back to a specific point in a transaction", "SAVEPOINT marks a point within a transaction to which you can partially rollback."),
            ("Connection pooling:", ["Creates a new connection per query", "Reuses database connections", "Pools data in memory", "Combines multiple databases"], "Reuses database connections", "Connection pooling reuses existing connections across requests, reducing connection overhead."),
            ("A dirty read means:", ["Reading corrupted data", "Reading uncommitted data from another transaction", "Reading old backup data", "Reading from a wrong table"], "Reading uncommitted data from another transaction", "A dirty read occurs when a transaction reads data that another transaction hasn't committed yet."),
        ]
        for q in dbmsQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: dbms))
        }
    }

    // MARK: - Glossary
    private static func seedGlossary(context: ModelContext) {
        let terms: [(String, String, String, [String])] = [
            ("Relation", "A two-dimensional table with rows and columns in the relational model.", "Relational Model", ["Tuple", "Attribute", "Table"]),
            ("Tuple", "A single row in a relation representing one record.", "Relational Model", ["Relation", "Attribute", "Row"]),
            ("Attribute", "A named column of a relation representing a property.", "Relational Model", ["Relation", "Domain", "Column"]),
            ("Domain", "The set of all allowable values for an attribute.", "Relational Model", ["Attribute", "Data Type"]),
            ("Degree", "The number of attributes (columns) in a relation.", "Relational Model", ["Cardinality", "Attribute"]),
            ("Cardinality", "The number of tuples (rows) in a relation, or the ratio in a relationship (1:1, 1:M, M:N).", "Relational Model", ["Degree", "Tuple"]),
            ("Primary Key", "A candidate key chosen to uniquely identify each row; cannot be NULL.", "Keys", ["Candidate Key", "Foreign Key", "Alternate Key"]),
            ("Foreign Key", "An attribute referencing the primary key of another table to establish a relationship.", "Keys", ["Primary Key", "Referential Integrity"]),
            ("Candidate Key", "A minimal superkey that uniquely identifies tuples.", "Keys", ["Primary Key", "Superkey", "Alternate Key"]),
            ("Superkey", "Any set of attributes that uniquely identifies tuples (may not be minimal).", "Keys", ["Candidate Key", "Primary Key"]),
            ("Alternate Key", "A candidate key not chosen as the primary key.", "Keys", ["Candidate Key", "Primary Key"]),
            ("Composite Key", "A key consisting of two or more attributes.", "Keys", ["Primary Key", "Candidate Key"]),
            ("Surrogate Key", "A system-generated artificial key with no business meaning.", "Keys", ["Natural Key", "Primary Key"]),
            ("Natural Key", "A key derived from real-world data with business meaning.", "Keys", ["Surrogate Key", "Business Key"]),
            ("Referential Integrity", "The rule that FK values must match existing PK values or be NULL.", "Keys", ["Foreign Key", "Primary Key", "CASCADE"]),
            ("Entity Integrity", "The rule that no primary key attribute may be NULL.", "Keys", ["Primary Key", "Referential Integrity"]),
            ("Entity", "An object or concept about which data is stored, represented as a rectangle.", "ER Diagrams", ["Attribute", "Relationship", "Entity Set"]),
            ("Weak Entity", "An entity that cannot exist without a related strong entity.", "ER Diagrams", ["Strong Entity", "Partial Key", "Identifying Relationship"]),
            ("Strong Entity", "An entity that exists independently with its own primary key.", "ER Diagrams", ["Weak Entity", "Primary Key"]),
            ("Relationship", "An association between two or more entities in an ER diagram.", "ER Diagrams", ["Entity", "Cardinality", "Participation"]),
            ("Participation Constraint", "Specifies if entities must (total) or may (partial) participate in a relationship.", "ER Diagrams", ["Total Participation", "Partial Participation"]),
            ("Total Participation", "Every entity instance must participate in the relationship (double line).", "ER Diagrams", ["Partial Participation", "Mandatory"]),
            ("Partial Participation", "Some entity instances may not participate (single line).", "ER Diagrams", ["Total Participation", "Optional"]),
            ("Crow's Foot Notation", "An ER notation using fork, dash, and circle symbols for cardinality.", "ER Diagrams", ["Chen Notation", "Cardinality"]),
            ("Chen Notation", "The original ER notation using rectangles, diamonds, and ovals.", "ER Diagrams", ["Crow's Foot Notation", "Peter Chen"]),
            ("Associative Entity", "An entity that resolves an M:N relationship (junction table).", "ER Diagrams", ["Junction Table", "M:N Relationship"]),
            ("Generalization", "Combining entity types with common attributes into a supertype.", "ER Diagrams", ["Specialization", "Supertype", "Subtype"]),
            ("Specialization", "Dividing a supertype entity into subtypes with distinct attributes.", "ER Diagrams", ["Generalization", "Supertype", "Subtype"]),
            ("1NF", "First Normal Form: all attribute values must be atomic with no repeating groups.", "Normalization", ["2NF", "Atomic", "Repeating Group"]),
            ("2NF", "Second Normal Form: in 1NF with no partial dependencies on composite keys.", "Normalization", ["1NF", "3NF", "Partial Dependency"]),
            ("3NF", "Third Normal Form: in 2NF with no transitive dependencies.", "Normalization", ["2NF", "BCNF", "Transitive Dependency"]),
            ("BCNF", "Boyce-Codd Normal Form: every determinant is a superkey.", "Normalization", ["3NF", "4NF", "Determinant"]),
            ("Functional Dependency", "A relationship where X uniquely determines Y (X → Y).", "Normalization", ["Determinant", "Partial Dependency", "Transitive Dependency"]),
            ("Partial Dependency", "A non-key attribute depends on only part of a composite primary key.", "Normalization", ["2NF", "Functional Dependency"]),
            ("Transitive Dependency", "A non-key attribute depends on another non-key attribute.", "Normalization", ["3NF", "Functional Dependency"]),
            ("Determinant", "The attribute(s) on the left side of a functional dependency.", "Normalization", ["Functional Dependency", "BCNF"]),
            ("Insertion Anomaly", "Inability to add data due to missing required related data.", "Normalization", ["Update Anomaly", "Deletion Anomaly"]),
            ("Update Anomaly", "Data inconsistency from updating only some copies of redundant data.", "Normalization", ["Insertion Anomaly", "Deletion Anomaly"]),
            ("Deletion Anomaly", "Unintended loss of data when deleting a row.", "Normalization", ["Insertion Anomaly", "Update Anomaly"]),
            ("Denormalization", "Intentionally adding redundancy to improve read performance.", "Normalization", ["Normalization", "Performance"]),
            ("DDL", "Data Definition Language: CREATE, ALTER, DROP, TRUNCATE.", "SQL", ["DML", "DCL", "CREATE TABLE"]),
            ("DML", "Data Manipulation Language: SELECT, INSERT, UPDATE, DELETE.", "SQL", ["DDL", "DCL", "Query"]),
            ("CREATE TABLE", "DDL command to define a new table with columns and constraints.", "SQL", ["DROP TABLE", "ALTER TABLE"]),
            ("ALTER TABLE", "DDL command to modify an existing table's structure.", "SQL", ["CREATE TABLE", "DROP TABLE"]),
            ("DROP TABLE", "DDL command to permanently remove a table and its data.", "SQL", ["CREATE TABLE", "TRUNCATE"]),
            ("SELECT", "DML command to retrieve data from tables.", "SQL", ["FROM", "WHERE", "JOIN"]),
            ("INSERT", "DML command to add new rows to a table.", "SQL", ["UPDATE", "DELETE", "VALUES"]),
            ("UPDATE", "DML command to modify existing data in a table.", "SQL", ["INSERT", "DELETE", "SET"]),
            ("DELETE", "DML command to remove rows from a table.", "SQL", ["INSERT", "UPDATE", "TRUNCATE"]),
            ("JOIN", "Combines rows from two or more tables based on related columns.", "SQL", ["INNER JOIN", "LEFT JOIN", "RIGHT JOIN"]),
            ("INNER JOIN", "Returns only rows with matching values in both tables.", "SQL", ["LEFT JOIN", "RIGHT JOIN", "FULL JOIN"]),
            ("LEFT JOIN", "Returns all rows from the left table, NULLs for unmatched right rows.", "SQL", ["INNER JOIN", "RIGHT JOIN"]),
            ("RIGHT JOIN", "Returns all rows from the right table, NULLs for unmatched left rows.", "SQL", ["LEFT JOIN", "INNER JOIN"]),
            ("FULL OUTER JOIN", "Returns all rows from both tables with NULLs for non-matches.", "SQL", ["LEFT JOIN", "RIGHT JOIN"]),
            ("GROUP BY", "Groups rows with same values for aggregate calculations.", "SQL", ["HAVING", "Aggregate Functions"]),
            ("HAVING", "Filters groups created by GROUP BY based on aggregate conditions.", "SQL", ["GROUP BY", "WHERE"]),
            ("Subquery", "A query nested inside another query.", "SQL", ["Correlated Subquery", "Derived Table"]),
            ("Aggregate Function", "Functions that operate on sets of rows: COUNT, SUM, AVG, MIN, MAX.", "SQL", ["GROUP BY", "HAVING"]),
            ("INDEX", "A data structure that speeds up data retrieval on specified columns.", "SQL", ["B-tree", "Clustered Index"]),
            ("VIEW", "A virtual table defined by a SELECT query.", "SQL", ["Base Table", "Materialized View"]),
            ("CONSTRAINT", "A rule enforced on data columns: NOT NULL, UNIQUE, CHECK, PK, FK.", "SQL", ["Primary Key", "Foreign Key", "CHECK"]),
            ("NULL", "Represents a missing, unknown, or inapplicable value.", "SQL", ["IS NULL", "COALESCE", "NOT NULL"]),
            ("DBMS", "Database Management System: software for creating and managing databases.", "DBMS", ["Database", "SQL"]),
            ("Transaction", "A logical unit of work that must complete entirely or not at all.", "DBMS", ["ACID", "COMMIT", "ROLLBACK"]),
            ("ACID", "Properties ensuring reliable transactions: Atomicity, Consistency, Isolation, Durability.", "DBMS", ["Transaction", "COMMIT"]),
            ("Atomicity", "A transaction is all-or-nothing: fully completes or fully rolls back.", "DBMS", ["ACID", "COMMIT", "ROLLBACK"]),
            ("Consistency", "A transaction moves the database from one valid state to another.", "DBMS", ["ACID", "Integrity"]),
            ("Isolation", "Concurrent transactions don't interfere with each other.", "DBMS", ["ACID", "Locking", "Serializability"]),
            ("Durability", "Committed changes persist even after system failures.", "DBMS", ["ACID", "WAL", "Recovery"]),
            ("COMMIT", "Command that makes transaction changes permanent.", "DBMS", ["ROLLBACK", "Transaction"]),
            ("ROLLBACK", "Command that undoes all changes in the current transaction.", "DBMS", ["COMMIT", "SAVEPOINT"]),
            ("Deadlock", "Circular wait where transactions block each other indefinitely.", "DBMS", ["Locking", "Concurrency"]),
            ("Lock", "Mechanism restricting concurrent access to prevent conflicts.", "DBMS", ["Shared Lock", "Exclusive Lock", "Deadlock"]),
            ("Concurrency Control", "Mechanisms managing simultaneous database access by multiple users.", "DBMS", ["Locking", "Serializability", "Isolation"]),
            ("Query Optimizer", "DBMS component that determines the most efficient execution plan.", "DBMS", ["Query Processor", "Execution Plan"]),
            ("Buffer Manager", "Manages data caching between disk and memory.", "DBMS", ["Buffer Pool", "Page"]),
            ("Write-Ahead Log", "Recovery technique logging changes before applying them to the database.", "DBMS", ["Recovery", "Checkpoint", "Durability"]),
            ("Checkpoint", "Point where modified buffer pages are flushed to disk for recovery.", "DBMS", ["WAL", "Recovery"]),
            ("Stored Procedure", "Precompiled SQL program stored in the database.", "DBMS", ["Trigger", "Function"]),
            ("Trigger", "SQL code that executes automatically in response to data changes.", "DBMS", ["Stored Procedure", "Event"]),
            ("Conceptual Model", "High-level data model showing entities and relationships.", "Data Modeling", ["Logical Model", "Physical Model"]),
            ("Logical Model", "Detailed data model with attributes, keys, and normalization.", "Data Modeling", ["Conceptual Model", "Physical Model"]),
            ("Physical Model", "DBMS-specific implementation with tables, indexes, and storage.", "Data Modeling", ["Conceptual Model", "Logical Model"]),
            ("Three-Schema Architecture", "ANSI/SPARC model with external, conceptual, and internal levels.", "Data Modeling", ["Data Independence", "Schema"]),
            ("Data Independence", "Ability to change one schema level without affecting others.", "Data Modeling", ["Three-Schema Architecture"]),
            ("Schema", "The formal definition of database structure.", "Data Modeling", ["Instance", "Metadata"]),
            ("Instance", "The actual data content of a database at a point in time.", "Data Modeling", ["Schema"]),
            ("Data Dictionary", "Repository of metadata about database objects.", "Data Modeling", ["Metadata", "System Catalog"]),
            ("Metadata", "Data that describes the structure and properties of other data.", "Data Modeling", ["Data Dictionary", "Schema"]),
            ("Star Schema", "Data warehouse design with a central fact table and dimension tables.", "Data Modeling", ["Snowflake Schema", "Fact Table"]),
            ("Fact Table", "Central table in a star schema containing measurable data.", "Data Modeling", ["Dimension Table", "Star Schema"]),
            ("Dimension Table", "Table with descriptive attributes for filtering and grouping facts.", "Data Modeling", ["Fact Table", "Star Schema"]),
            ("OLTP", "Online Transaction Processing: handles many short transactions.", "Data Modeling", ["OLAP", "Transaction"]),
            ("OLAP", "Online Analytical Processing: handles complex analytical queries.", "Data Modeling", ["OLTP", "Data Warehouse"]),
            ("CASCADE", "Referential action that propagates deletes/updates to referencing rows.", "Keys", ["RESTRICT", "SET NULL"]),
            ("RESTRICT", "Referential action that prevents deletes/updates if references exist.", "Keys", ["CASCADE", "SET NULL"]),
            ("B-tree Index", "Balanced tree structure for efficient O(log n) data access.", "DBMS", ["Hash Index", "Clustered Index"]),
            ("Clustered Index", "Index that physically reorders table data; one per table.", "DBMS", ["Non-Clustered Index", "B-tree"]),
            ("Serializability", "Ensuring concurrent execution equals some serial order.", "DBMS", ["Isolation", "Two-Phase Locking"]),
            ("SQL Injection", "Security attack inserting malicious SQL through application inputs.", "DBMS", ["Parameterized Query", "Security"]),
            ("Relational Algebra", "Procedural query language using operators on relations.", "Relational Model", ["Relational Calculus", "SELECT", "PROJECT"]),
            ("Relational Calculus", "Declarative query language specifying what, not how.", "Relational Model", ["Relational Algebra"]),
        ]
        for t in terms {
            context.insert(GlossaryTerm(term: t.0, definition: t.1, category: t.2, relatedTerms: t.3))
        }
    }

    // MARK: - Sample Databases
    private static func seedSampleDatabases(context: ModelContext) {

        // 1. University Database
        context.insert(SampleDatabase(
            name: "University",
            description: "Students, courses, enrollments, departments, and professors",
            schemaSQL: """
            CREATE TABLE departments (
                dept_id INTEGER PRIMARY KEY,
                dept_name VARCHAR(50) NOT NULL,
                building VARCHAR(50),
                budget DECIMAL(12,2)
            );
            CREATE TABLE professors (
                prof_id INTEGER PRIMARY KEY,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                email VARCHAR(100) UNIQUE,
                dept_id INTEGER,
                hire_date DATE,
                FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
            );
            CREATE TABLE students (
                student_id INTEGER PRIMARY KEY,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                email VARCHAR(100) UNIQUE,
                gpa DECIMAL(3,2),
                major_dept_id INTEGER,
                enrollment_date DATE,
                FOREIGN KEY (major_dept_id) REFERENCES departments(dept_id)
            );
            CREATE TABLE courses (
                course_id INTEGER PRIMARY KEY,
                course_code VARCHAR(10) NOT NULL,
                title VARCHAR(100) NOT NULL,
                credits INTEGER DEFAULT 3,
                dept_id INTEGER,
                prof_id INTEGER,
                FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
                FOREIGN KEY (prof_id) REFERENCES professors(prof_id)
            );
            CREATE TABLE enrollments (
                enrollment_id INTEGER PRIMARY KEY,
                student_id INTEGER NOT NULL,
                course_id INTEGER NOT NULL,
                semester VARCHAR(20),
                grade CHAR(2),
                FOREIGN KEY (student_id) REFERENCES students(student_id),
                FOREIGN KEY (course_id) REFERENCES courses(course_id)
            );
            """,
            sampleDataSQL: """
            INSERT INTO departments VALUES (1, 'Computer Science', 'Engineering Hall', 500000.00);
            INSERT INTO departments VALUES (2, 'Mathematics', 'Science Center', 350000.00);
            INSERT INTO departments VALUES (3, 'Business', 'Commerce Building', 450000.00);
            INSERT INTO departments VALUES (4, 'English', 'Liberal Arts Hall', 250000.00);
            INSERT INTO departments VALUES (5, 'Physics', 'Science Center', 400000.00);

            INSERT INTO professors VALUES (1, 'Alice', 'Johnson', 'ajohnson@uni.edu', 1, '2015-08-15');
            INSERT INTO professors VALUES (2, 'Bob', 'Smith', 'bsmith@uni.edu', 1, '2018-01-10');
            INSERT INTO professors VALUES (3, 'Carol', 'Davis', 'cdavis@uni.edu', 2, '2012-06-01');
            INSERT INTO professors VALUES (4, 'David', 'Wilson', 'dwilson@uni.edu', 3, '2020-09-01');
            INSERT INTO professors VALUES (5, 'Eve', 'Brown', 'ebrown@uni.edu', 4, '2016-03-20');
            INSERT INTO professors VALUES (6, 'Frank', 'Taylor', 'ftaylor@uni.edu', 5, '2014-11-15');

            INSERT INTO students VALUES (1, 'John', 'Doe', 'jdoe@uni.edu', 3.5, 1, '2022-08-20');
            INSERT INTO students VALUES (2, 'Jane', 'Smith', 'jsmith@uni.edu', 3.8, 1, '2021-08-18');
            INSERT INTO students VALUES (3, 'Mike', 'Johnson', 'mjohnson@uni.edu', 2.9, 2, '2023-01-10');
            INSERT INTO students VALUES (4, 'Sarah', 'Williams', 'swilliams@uni.edu', 3.2, 3, '2022-01-15');
            INSERT INTO students VALUES (5, 'Tom', 'Brown', 'tbrown@uni.edu', 3.7, 1, '2021-08-18');
            INSERT INTO students VALUES (6, 'Lisa', 'Davis', 'ldavis@uni.edu', 3.1, 4, '2023-08-21');
            INSERT INTO students VALUES (7, 'Chris', 'Miller', 'cmiller@uni.edu', 2.8, 2, '2022-08-20');
            INSERT INTO students VALUES (8, 'Amy', 'Wilson', 'awilson@uni.edu', 3.9, 5, '2021-01-12');
            INSERT INTO students VALUES (9, 'Ryan', 'Taylor', 'rtaylor@uni.edu', 3.0, 3, '2023-01-10');
            INSERT INTO students VALUES (10, 'Emma', 'Anderson', 'eanderson@uni.edu', 3.6, 1, '2022-01-15');

            INSERT INTO courses VALUES (1, 'CS101', 'Intro to Programming', 3, 1, 1);
            INSERT INTO courses VALUES (2, 'CS201', 'Data Structures', 3, 1, 2);
            INSERT INTO courses VALUES (3, 'CS301', 'Database Systems', 3, 1, 1);
            INSERT INTO courses VALUES (4, 'MATH101', 'Calculus I', 4, 2, 3);
            INSERT INTO courses VALUES (5, 'MATH201', 'Linear Algebra', 3, 2, 3);
            INSERT INTO courses VALUES (6, 'BUS101', 'Intro to Business', 3, 3, 4);
            INSERT INTO courses VALUES (7, 'ENG101', 'English Composition', 3, 4, 5);
            INSERT INTO courses VALUES (8, 'PHYS101', 'Physics I', 4, 5, 6);

            INSERT INTO enrollments VALUES (1, 1, 1, 'Fall 2022', 'A');
            INSERT INTO enrollments VALUES (2, 1, 3, 'Spring 2023', 'B+');
            INSERT INTO enrollments VALUES (3, 2, 1, 'Fall 2021', 'A');
            INSERT INTO enrollments VALUES (4, 2, 2, 'Spring 2022', 'A-');
            INSERT INTO enrollments VALUES (5, 3, 4, 'Spring 2023', 'B');
            INSERT INTO enrollments VALUES (6, 4, 6, 'Fall 2022', 'B+');
            INSERT INTO enrollments VALUES (7, 5, 2, 'Fall 2021', 'A');
            INSERT INTO enrollments VALUES (8, 5, 3, 'Spring 2022', 'A');
            INSERT INTO enrollments VALUES (9, 6, 7, 'Fall 2023', 'A-');
            INSERT INTO enrollments VALUES (10, 7, 4, 'Fall 2022', 'C+');
            INSERT INTO enrollments VALUES (11, 8, 8, 'Fall 2021', 'A');
            INSERT INTO enrollments VALUES (12, 9, 6, 'Spring 2023', 'B');
            INSERT INTO enrollments VALUES (13, 10, 1, 'Fall 2022', 'A-');
            INSERT INTO enrollments VALUES (14, 10, 2, 'Spring 2023', 'B+');
            INSERT INTO enrollments VALUES (15, 3, 5, 'Fall 2023', 'A');
            """,
            iconName: "graduationcap.fill"
        ))

        // 2. Sales Database
        context.insert(SampleDatabase(
            name: "Sales",
            description: "Customers, products, orders, and categories",
            schemaSQL: """
            CREATE TABLE categories (
                category_id INTEGER PRIMARY KEY,
                category_name VARCHAR(50) NOT NULL,
                description TEXT
            );
            CREATE TABLE customers (
                customer_id INTEGER PRIMARY KEY,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                email VARCHAR(100) UNIQUE,
                city VARCHAR(50),
                state VARCHAR(2),
                join_date DATE
            );
            CREATE TABLE products (
                product_id INTEGER PRIMARY KEY,
                product_name VARCHAR(100) NOT NULL,
                category_id INTEGER,
                price DECIMAL(10,2) NOT NULL,
                stock_qty INTEGER DEFAULT 0,
                FOREIGN KEY (category_id) REFERENCES categories(category_id)
            );
            CREATE TABLE orders (
                order_id INTEGER PRIMARY KEY,
                customer_id INTEGER NOT NULL,
                order_date DATE NOT NULL,
                total_amount DECIMAL(10,2),
                status VARCHAR(20) DEFAULT 'Pending',
                FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
            );
            CREATE TABLE order_items (
                item_id INTEGER PRIMARY KEY,
                order_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                unit_price DECIMAL(10,2) NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(order_id),
                FOREIGN KEY (product_id) REFERENCES products(product_id)
            );
            """,
            sampleDataSQL: """
            INSERT INTO categories VALUES (1, 'Electronics', 'Phones, laptops, accessories');
            INSERT INTO categories VALUES (2, 'Clothing', 'Shirts, pants, shoes');
            INSERT INTO categories VALUES (3, 'Books', 'Fiction, non-fiction, textbooks');
            INSERT INTO categories VALUES (4, 'Home & Garden', 'Furniture, decor, tools');

            INSERT INTO customers VALUES (1, 'Alice', 'Brown', 'abrown@email.com', 'New York', 'NY', '2023-01-15');
            INSERT INTO customers VALUES (2, 'Bob', 'Green', 'bgreen@email.com', 'Los Angeles', 'CA', '2023-02-20');
            INSERT INTO customers VALUES (3, 'Carol', 'White', 'cwhite@email.com', 'Chicago', 'IL', '2023-03-10');
            INSERT INTO customers VALUES (4, 'David', 'Black', 'dblack@email.com', 'Houston', 'TX', '2023-04-05');
            INSERT INTO customers VALUES (5, 'Eve', 'Gray', 'egray@email.com', 'Phoenix', 'AZ', '2023-05-12');
            INSERT INTO customers VALUES (6, 'Frank', 'Blue', 'fblue@email.com', 'Seattle', 'WA', '2023-06-18');
            INSERT INTO customers VALUES (7, 'Grace', 'Red', 'gred@email.com', 'Denver', 'CO', '2023-07-22');
            INSERT INTO customers VALUES (8, 'Henry', 'Gold', 'hgold@email.com', 'Miami', 'FL', '2023-08-30');
            INSERT INTO customers VALUES (9, 'Ivy', 'Silver', 'isilver@email.com', 'Boston', 'MA', '2023-09-14');
            INSERT INTO customers VALUES (10, 'Jack', 'Copper', 'jcopper@email.com', 'Austin', 'TX', '2023-10-01');

            INSERT INTO products VALUES (1, 'Laptop Pro 15', 1, 1299.99, 50);
            INSERT INTO products VALUES (2, 'Wireless Mouse', 1, 29.99, 200);
            INSERT INTO products VALUES (3, 'USB-C Hub', 1, 49.99, 150);
            INSERT INTO products VALUES (4, 'Cotton T-Shirt', 2, 19.99, 500);
            INSERT INTO products VALUES (5, 'Running Shoes', 2, 89.99, 100);
            INSERT INTO products VALUES (6, 'SQL Cookbook', 3, 39.99, 75);
            INSERT INTO products VALUES (7, 'Database Design', 3, 54.99, 60);
            INSERT INTO products VALUES (8, 'Desk Lamp', 4, 34.99, 120);
            INSERT INTO products VALUES (9, 'Phone Case', 1, 14.99, 300);
            INSERT INTO products VALUES (10, 'Backpack', 2, 59.99, 80);

            INSERT INTO orders VALUES (1, 1, '2024-01-15', 1349.97, 'Completed');
            INSERT INTO orders VALUES (2, 2, '2024-01-18', 89.99, 'Completed');
            INSERT INTO orders VALUES (3, 3, '2024-02-01', 94.98, 'Completed');
            INSERT INTO orders VALUES (4, 1, '2024-02-10', 29.99, 'Completed');
            INSERT INTO orders VALUES (5, 4, '2024-02-15', 174.97, 'Shipped');
            INSERT INTO orders VALUES (6, 5, '2024-03-01', 39.99, 'Completed');
            INSERT INTO orders VALUES (7, 6, '2024-03-10', 1359.97, 'Completed');
            INSERT INTO orders VALUES (8, 7, '2024-03-15', 59.99, 'Pending');
            INSERT INTO orders VALUES (9, 8, '2024-03-20', 109.98, 'Shipped');
            INSERT INTO orders VALUES (10, 3, '2024-04-01', 54.99, 'Pending');

            INSERT INTO order_items VALUES (1, 1, 1, 1, 1299.99);
            INSERT INTO order_items VALUES (2, 1, 3, 1, 49.99);
            INSERT INTO order_items VALUES (3, 2, 5, 1, 89.99);
            INSERT INTO order_items VALUES (4, 3, 6, 1, 39.99);
            INSERT INTO order_items VALUES (5, 3, 7, 1, 54.99);
            INSERT INTO order_items VALUES (6, 4, 2, 1, 29.99);
            INSERT INTO order_items VALUES (7, 5, 4, 3, 19.99);
            INSERT INTO order_items VALUES (8, 5, 8, 1, 34.99);
            INSERT INTO order_items VALUES (9, 5, 9, 2, 14.99);
            INSERT INTO order_items VALUES (10, 6, 6, 1, 39.99);
            INSERT INTO order_items VALUES (11, 7, 1, 1, 1299.99);
            INSERT INTO order_items VALUES (12, 7, 10, 1, 59.99);
            INSERT INTO order_items VALUES (13, 8, 10, 1, 59.99);
            INSERT INTO order_items VALUES (14, 9, 5, 1, 89.99);
            INSERT INTO order_items VALUES (15, 9, 4, 1, 19.99);
            INSERT INTO order_items VALUES (16, 10, 7, 1, 54.99);
            """,
            iconName: "cart.fill"
        ))

        // 3. Hospital Database
        context.insert(SampleDatabase(
            name: "Hospital",
            description: "Patients, doctors, appointments, and prescriptions",
            schemaSQL: """
            CREATE TABLE departments (
                dept_id INTEGER PRIMARY KEY,
                dept_name VARCHAR(50) NOT NULL,
                floor_number INTEGER,
                phone VARCHAR(15)
            );
            CREATE TABLE doctors (
                doctor_id INTEGER PRIMARY KEY,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                specialty VARCHAR(50),
                dept_id INTEGER,
                license_number VARCHAR(20) UNIQUE,
                FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
            );
            CREATE TABLE patients (
                patient_id INTEGER PRIMARY KEY,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                date_of_birth DATE,
                gender CHAR(1),
                phone VARCHAR(15),
                insurance_id VARCHAR(20)
            );
            CREATE TABLE appointments (
                appt_id INTEGER PRIMARY KEY,
                patient_id INTEGER NOT NULL,
                doctor_id INTEGER NOT NULL,
                appt_date DATE NOT NULL,
                appt_time VARCHAR(10),
                reason VARCHAR(200),
                status VARCHAR(20) DEFAULT 'Scheduled',
                FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
                FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
            );
            CREATE TABLE prescriptions (
                rx_id INTEGER PRIMARY KEY,
                patient_id INTEGER NOT NULL,
                doctor_id INTEGER NOT NULL,
                medication VARCHAR(100) NOT NULL,
                dosage VARCHAR(50),
                start_date DATE,
                end_date DATE,
                FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
                FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
            );
            """,
            sampleDataSQL: """
            INSERT INTO departments VALUES (1, 'Cardiology', 3, '555-0101');
            INSERT INTO departments VALUES (2, 'Orthopedics', 2, '555-0102');
            INSERT INTO departments VALUES (3, 'Pediatrics', 1, '555-0103');
            INSERT INTO departments VALUES (4, 'Neurology', 4, '555-0104');
            INSERT INTO departments VALUES (5, 'Emergency', 1, '555-0105');

            INSERT INTO doctors VALUES (1, 'Sarah', 'Chen', 'Cardiologist', 1, 'MD-10001');
            INSERT INTO doctors VALUES (2, 'James', 'Patel', 'Orthopedic Surgeon', 2, 'MD-10002');
            INSERT INTO doctors VALUES (3, 'Maria', 'Garcia', 'Pediatrician', 3, 'MD-10003');
            INSERT INTO doctors VALUES (4, 'Robert', 'Kim', 'Neurologist', 4, 'MD-10004');
            INSERT INTO doctors VALUES (5, 'Lisa', 'Wang', 'ER Physician', 5, 'MD-10005');
            INSERT INTO doctors VALUES (6, 'Michael', 'Brown', 'Cardiologist', 1, 'MD-10006');

            INSERT INTO patients VALUES (1, 'John', 'Adams', '1985-03-15', 'M', '555-1001', 'INS-A001');
            INSERT INTO patients VALUES (2, 'Emily', 'Baker', '1992-07-22', 'F', '555-1002', 'INS-B002');
            INSERT INTO patients VALUES (3, 'William', 'Clark', '1978-11-30', 'M', '555-1003', 'INS-C003');
            INSERT INTO patients VALUES (4, 'Sophie', 'Davis', '2015-04-10', 'F', '555-1004', 'INS-D004');
            INSERT INTO patients VALUES (5, 'Thomas', 'Evans', '1960-09-05', 'M', '555-1005', 'INS-E005');
            INSERT INTO patients VALUES (6, 'Olivia', 'Foster', '1988-12-18', 'F', '555-1006', 'INS-F006');
            INSERT INTO patients VALUES (7, 'Daniel', 'Green', '2001-06-25', 'M', '555-1007', 'INS-G007');
            INSERT INTO patients VALUES (8, 'Hannah', 'Hill', '1995-02-14', 'F', '555-1008', 'INS-H008');
            INSERT INTO patients VALUES (9, 'Jack', 'Irving', '1972-08-08', 'M', '555-1009', 'INS-I009');
            INSERT INTO patients VALUES (10, 'Mia', 'Jones', '2010-01-20', 'F', '555-1010', 'INS-J010');

            INSERT INTO appointments VALUES (1, 1, 1, '2024-03-15', '09:00', 'Annual heart checkup', 'Completed');
            INSERT INTO appointments VALUES (2, 2, 2, '2024-03-15', '10:30', 'Knee pain evaluation', 'Completed');
            INSERT INTO appointments VALUES (3, 3, 1, '2024-03-16', '14:00', 'Blood pressure follow-up', 'Completed');
            INSERT INTO appointments VALUES (4, 4, 3, '2024-03-17', '09:30', 'Routine pediatric visit', 'Completed');
            INSERT INTO appointments VALUES (5, 5, 4, '2024-03-18', '11:00', 'Headache evaluation', 'Completed');
            INSERT INTO appointments VALUES (6, 6, 5, '2024-03-18', '15:00', 'Wrist injury', 'Completed');
            INSERT INTO appointments VALUES (7, 7, 2, '2024-03-20', '10:00', 'Sports injury', 'Scheduled');
            INSERT INTO appointments VALUES (8, 8, 1, '2024-03-22', '13:00', 'Heart palpitations', 'Scheduled');
            INSERT INTO appointments VALUES (9, 9, 6, '2024-03-25', '09:00', 'Chest pain', 'Scheduled');
            INSERT INTO appointments VALUES (10, 10, 3, '2024-03-25', '14:30', 'Vaccination', 'Scheduled');

            INSERT INTO prescriptions VALUES (1, 1, 1, 'Lisinopril', '10mg daily', '2024-03-15', '2024-09-15');
            INSERT INTO prescriptions VALUES (2, 1, 1, 'Aspirin', '81mg daily', '2024-03-15', '2025-03-15');
            INSERT INTO prescriptions VALUES (3, 2, 2, 'Ibuprofen', '400mg as needed', '2024-03-15', '2024-04-15');
            INSERT INTO prescriptions VALUES (4, 3, 1, 'Amlodipine', '5mg daily', '2024-03-16', '2024-09-16');
            INSERT INTO prescriptions VALUES (5, 5, 4, 'Sumatriptan', '50mg as needed', '2024-03-18', '2024-06-18');
            INSERT INTO prescriptions VALUES (6, 6, 5, 'Acetaminophen', '500mg every 6hrs', '2024-03-18', '2024-03-25');
            INSERT INTO prescriptions VALUES (7, 3, 1, 'Metoprolol', '25mg twice daily', '2024-03-16', '2024-09-16');
            INSERT INTO prescriptions VALUES (8, 9, 6, 'Nitroglycerin', '0.4mg sublingual', '2024-03-25', '2024-06-25');
            """,
            iconName: "cross.case.fill"
        ))

        // 4. Employee Database
        context.insert(SampleDatabase(
            name: "Employee",
            description: "Employees, departments, projects, assignments, and salaries",
            schemaSQL: """
            CREATE TABLE departments (
                dept_id INTEGER PRIMARY KEY,
                dept_name VARCHAR(50) NOT NULL,
                location VARCHAR(50),
                manager_id INTEGER
            );
            CREATE TABLE employees (
                emp_id INTEGER PRIMARY KEY,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                email VARCHAR(100) UNIQUE,
                hire_date DATE,
                job_title VARCHAR(50),
                dept_id INTEGER,
                manager_id INTEGER,
                FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
                FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
            );
            CREATE TABLE salaries (
                salary_id INTEGER PRIMARY KEY,
                emp_id INTEGER NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                effective_date DATE NOT NULL,
                end_date DATE,
                FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
            );
            CREATE TABLE projects (
                project_id INTEGER PRIMARY KEY,
                project_name VARCHAR(100) NOT NULL,
                start_date DATE,
                end_date DATE,
                budget DECIMAL(12,2),
                dept_id INTEGER,
                FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
            );
            CREATE TABLE assignments (
                assign_id INTEGER PRIMARY KEY,
                emp_id INTEGER NOT NULL,
                project_id INTEGER NOT NULL,
                role VARCHAR(50),
                hours_per_week DECIMAL(4,1),
                FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
                FOREIGN KEY (project_id) REFERENCES projects(project_id)
            );
            """,
            sampleDataSQL: """
            INSERT INTO departments VALUES (1, 'Engineering', 'Building A', 1);
            INSERT INTO departments VALUES (2, 'Marketing', 'Building B', 4);
            INSERT INTO departments VALUES (3, 'Human Resources', 'Building A', 7);
            INSERT INTO departments VALUES (4, 'Finance', 'Building C', 9);
            INSERT INTO departments VALUES (5, 'Operations', 'Building D', 11);

            INSERT INTO employees VALUES (1, 'Alice', 'Johnson', 'ajohnson@corp.com', '2018-03-15', 'VP Engineering', 1, NULL);
            INSERT INTO employees VALUES (2, 'Bob', 'Smith', 'bsmith@corp.com', '2019-06-01', 'Senior Developer', 1, 1);
            INSERT INTO employees VALUES (3, 'Carol', 'Davis', 'cdavis@corp.com', '2020-01-10', 'Developer', 1, 2);
            INSERT INTO employees VALUES (4, 'David', 'Wilson', 'dwilson@corp.com', '2017-09-20', 'Marketing Director', 2, NULL);
            INSERT INTO employees VALUES (5, 'Eve', 'Brown', 'ebrown@corp.com', '2021-04-05', 'Marketing Specialist', 2, 4);
            INSERT INTO employees VALUES (6, 'Frank', 'Taylor', 'ftaylor@corp.com', '2020-08-12', 'Developer', 1, 2);
            INSERT INTO employees VALUES (7, 'Grace', 'Anderson', 'ganderson@corp.com', '2016-11-01', 'HR Director', 3, NULL);
            INSERT INTO employees VALUES (8, 'Henry', 'Thomas', 'hthomas@corp.com', '2022-02-14', 'HR Specialist', 3, 7);
            INSERT INTO employees VALUES (9, 'Ivy', 'Jackson', 'ijackson@corp.com', '2015-07-20', 'Finance Director', 4, NULL);
            INSERT INTO employees VALUES (10, 'Jack', 'White', 'jwhite@corp.com', '2021-10-01', 'Accountant', 4, 9);
            INSERT INTO employees VALUES (11, 'Karen', 'Lee', 'klee@corp.com', '2019-03-15', 'Ops Manager', 5, NULL);
            INSERT INTO employees VALUES (12, 'Leo', 'Martinez', 'lmartinez@corp.com', '2023-01-08', 'Junior Developer', 1, 2);

            INSERT INTO salaries VALUES (1, 1, 150000.00, '2018-03-15', NULL);
            INSERT INTO salaries VALUES (2, 2, 120000.00, '2019-06-01', '2022-06-01');
            INSERT INTO salaries VALUES (3, 2, 135000.00, '2022-06-01', NULL);
            INSERT INTO salaries VALUES (4, 3, 95000.00, '2020-01-10', NULL);
            INSERT INTO salaries VALUES (5, 4, 130000.00, '2017-09-20', NULL);
            INSERT INTO salaries VALUES (6, 5, 75000.00, '2021-04-05', NULL);
            INSERT INTO salaries VALUES (7, 6, 100000.00, '2020-08-12', NULL);
            INSERT INTO salaries VALUES (8, 7, 125000.00, '2016-11-01', NULL);
            INSERT INTO salaries VALUES (9, 8, 65000.00, '2022-02-14', NULL);
            INSERT INTO salaries VALUES (10, 9, 140000.00, '2015-07-20', NULL);
            INSERT INTO salaries VALUES (11, 10, 70000.00, '2021-10-01', NULL);
            INSERT INTO salaries VALUES (12, 11, 110000.00, '2019-03-15', NULL);
            INSERT INTO salaries VALUES (13, 12, 75000.00, '2023-01-08', NULL);

            INSERT INTO projects VALUES (1, 'Mobile App Redesign', '2024-01-01', '2024-06-30', 250000.00, 1);
            INSERT INTO projects VALUES (2, 'Cloud Migration', '2024-02-01', '2024-12-31', 500000.00, 1);
            INSERT INTO projects VALUES (3, 'Brand Refresh', '2024-03-01', '2024-09-30', 150000.00, 2);
            INSERT INTO projects VALUES (4, 'Employee Portal', '2024-01-15', '2024-07-31', 100000.00, 3);
            INSERT INTO projects VALUES (5, 'Budget System', '2024-04-01', '2024-10-31', 200000.00, 4);

            INSERT INTO assignments VALUES (1, 2, 1, 'Lead Developer', 20.0);
            INSERT INTO assignments VALUES (2, 3, 1, 'Frontend Dev', 30.0);
            INSERT INTO assignments VALUES (3, 6, 1, 'Backend Dev', 25.0);
            INSERT INTO assignments VALUES (4, 2, 2, 'Architect', 20.0);
            INSERT INTO assignments VALUES (5, 12, 2, 'Developer', 40.0);
            INSERT INTO assignments VALUES (6, 5, 3, 'Coordinator', 35.0);
            INSERT INTO assignments VALUES (7, 8, 4, 'Project Lead', 30.0);
            INSERT INTO assignments VALUES (8, 3, 4, 'Developer', 10.0);
            INSERT INTO assignments VALUES (9, 10, 5, 'Lead Analyst', 40.0);
            INSERT INTO assignments VALUES (10, 6, 2, 'Developer', 15.0);
            """,
            iconName: "person.3.fill"
        ))

        // 5. Inventory Database
        context.insert(SampleDatabase(
            name: "Inventory",
            description: "Warehouses, products, suppliers, stock levels, and purchase orders",
            schemaSQL: """
            CREATE TABLE suppliers (
                supplier_id INTEGER PRIMARY KEY,
                company_name VARCHAR(100) NOT NULL,
                contact_name VARCHAR(50),
                email VARCHAR(100),
                phone VARCHAR(15),
                city VARCHAR(50),
                country VARCHAR(50)
            );
            CREATE TABLE warehouses (
                warehouse_id INTEGER PRIMARY KEY,
                warehouse_name VARCHAR(50) NOT NULL,
                location VARCHAR(100),
                capacity INTEGER,
                manager_name VARCHAR(50)
            );
            CREATE TABLE products (
                product_id INTEGER PRIMARY KEY,
                product_name VARCHAR(100) NOT NULL,
                sku VARCHAR(20) UNIQUE,
                category VARCHAR(50),
                unit_cost DECIMAL(10,2),
                unit_price DECIMAL(10,2),
                reorder_level INTEGER DEFAULT 10
            );
            CREATE TABLE stock_levels (
                stock_id INTEGER PRIMARY KEY,
                product_id INTEGER NOT NULL,
                warehouse_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL DEFAULT 0,
                last_updated DATE,
                FOREIGN KEY (product_id) REFERENCES products(product_id),
                FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
            );
            CREATE TABLE purchase_orders (
                po_id INTEGER PRIMARY KEY,
                supplier_id INTEGER NOT NULL,
                warehouse_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                order_date DATE NOT NULL,
                expected_date DATE,
                status VARCHAR(20) DEFAULT 'Ordered',
                total_cost DECIMAL(10,2),
                FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
                FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
                FOREIGN KEY (product_id) REFERENCES products(product_id)
            );
            """,
            sampleDataSQL: """
            INSERT INTO suppliers VALUES (1, 'TechParts Inc', 'John Lee', 'jlee@techparts.com', '555-2001', 'San Jose', 'USA');
            INSERT INTO suppliers VALUES (2, 'Global Electronics', 'Maria Santos', 'msantos@globalelec.com', '555-2002', 'Shenzhen', 'China');
            INSERT INTO suppliers VALUES (3, 'EuroSupply GmbH', 'Hans Mueller', 'hmueller@eurosupply.de', '555-2003', 'Munich', 'Germany');
            INSERT INTO suppliers VALUES (4, 'PackRight Co', 'Sarah Kim', 'skim@packright.com', '555-2004', 'Seoul', 'South Korea');
            INSERT INTO suppliers VALUES (5, 'RawMaterials Ltd', 'James Brown', 'jbrown@rawmat.co.uk', '555-2005', 'London', 'UK');

            INSERT INTO warehouses VALUES (1, 'West Coast Hub', 'Los Angeles, CA', 50000, 'Tom Richards');
            INSERT INTO warehouses VALUES (2, 'East Coast Hub', 'Newark, NJ', 45000, 'Lisa Chen');
            INSERT INTO warehouses VALUES (3, 'Central Warehouse', 'Dallas, TX', 60000, 'Mike Johnson');
            INSERT INTO warehouses VALUES (4, 'Southeast Depot', 'Atlanta, GA', 35000, 'Amy Williams');

            INSERT INTO products VALUES (1, 'Widget Alpha', 'WA-001', 'Widgets', 5.50, 12.99, 100);
            INSERT INTO products VALUES (2, 'Widget Beta', 'WB-002', 'Widgets', 7.25, 16.99, 80);
            INSERT INTO products VALUES (3, 'Gadget X1', 'GX-003', 'Gadgets', 15.00, 34.99, 50);
            INSERT INTO products VALUES (4, 'Gadget X2', 'GX-004', 'Gadgets', 22.50, 49.99, 30);
            INSERT INTO products VALUES (5, 'Component A', 'CA-005', 'Components', 2.00, 5.99, 200);
            INSERT INTO products VALUES (6, 'Component B', 'CB-006', 'Components', 3.50, 8.99, 150);
            INSERT INTO products VALUES (7, 'Assembly Kit', 'AK-007', 'Kits', 45.00, 99.99, 20);
            INSERT INTO products VALUES (8, 'Packaging Box L', 'PB-008', 'Packaging', 1.20, 3.49, 500);
            INSERT INTO products VALUES (9, 'Packaging Box M', 'PB-009', 'Packaging', 0.80, 2.49, 500);
            INSERT INTO products VALUES (10, 'Sensor Module', 'SM-010', 'Electronics', 18.75, 42.99, 40);

            INSERT INTO stock_levels VALUES (1, 1, 1, 500, '2024-03-01');
            INSERT INTO stock_levels VALUES (2, 1, 2, 300, '2024-03-01');
            INSERT INTO stock_levels VALUES (3, 2, 1, 200, '2024-03-01');
            INSERT INTO stock_levels VALUES (4, 3, 1, 150, '2024-02-28');
            INSERT INTO stock_levels VALUES (5, 3, 3, 100, '2024-02-28');
            INSERT INTO stock_levels VALUES (6, 4, 2, 75, '2024-03-05');
            INSERT INTO stock_levels VALUES (7, 5, 1, 1000, '2024-03-01');
            INSERT INTO stock_levels VALUES (8, 5, 2, 800, '2024-03-01');
            INSERT INTO stock_levels VALUES (9, 5, 3, 600, '2024-03-01');
            INSERT INTO stock_levels VALUES (10, 6, 1, 400, '2024-02-15');
            INSERT INTO stock_levels VALUES (11, 7, 3, 45, '2024-03-10');
            INSERT INTO stock_levels VALUES (12, 8, 4, 2000, '2024-03-01');
            INSERT INTO stock_levels VALUES (13, 9, 4, 1500, '2024-03-01');
            INSERT INTO stock_levels VALUES (14, 10, 1, 60, '2024-03-08');
            INSERT INTO stock_levels VALUES (15, 10, 2, 40, '2024-03-08');

            INSERT INTO purchase_orders VALUES (1, 1, 1, 1, 1000, '2024-03-01', '2024-03-15', 'Delivered');
            INSERT INTO purchase_orders VALUES (2, 2, 2, 3, 200, '2024-03-05', '2024-03-25', 'Shipped');
            INSERT INTO purchase_orders VALUES (3, 1, 1, 5, 2000, '2024-03-08', '2024-03-20', 'Delivered');
            INSERT INTO purchase_orders VALUES (4, 3, 3, 7, 50, '2024-03-10', '2024-04-01', 'Ordered');
            INSERT INTO purchase_orders VALUES (5, 4, 4, 8, 5000, '2024-03-12', '2024-03-22', 'Shipped');
            INSERT INTO purchase_orders VALUES (6, 2, 1, 10, 100, '2024-03-15', '2024-04-05', 'Ordered');
            INSERT INTO purchase_orders VALUES (7, 5, 2, 6, 500, '2024-03-18', '2024-04-08', 'Ordered');
            INSERT INTO purchase_orders VALUES (8, 1, 3, 2, 300, '2024-03-20', '2024-04-02', 'Ordered');
            INSERT INTO purchase_orders VALUES (9, 4, 4, 9, 3000, '2024-03-22', '2024-04-01', 'Shipped');
            INSERT INTO purchase_orders VALUES (10, 3, 1, 4, 100, '2024-03-25', '2024-04-15', 'Ordered');
            """,
            iconName: "shippingbox.fill"
        ))
    }
}

    // MARK: - Quiz Questions
    private static func seedQuizQuestions(context: ModelContext, relationalModel: Topic, erDiagrams: Topic, keys: Topic, normalization: Topic, ddl: Topic, dml: Topic, models: Topic, dbms: Topic) {

        // --- Relational Model Quizzes (25+) ---
        let rmQ: [(String, [String], String, String)] = [
            ("What is a tuple in the relational model?", ["A column in a table", "A row in a table", "A table itself", "A database"], "A row in a table", "A tuple represents a single row/record in a relation."),
            ("What is the degree of a relation?", ["Number of rows", "Number of columns", "Number of tables", "Number of keys"], "Number of columns", "Degree refers to the number of attributes (columns) in a relation."),
            ("What is the cardinality of a relation?", ["Number of columns", "Number of rows", "Number of keys", "Number of constraints"], "Number of rows", "Cardinality is the number of tuples (rows) in a relation."),
            ("Who proposed the relational model?", ["Peter Chen", "Edgar F. Codd", "Michael Stonebraker", "Larry Ellison"], "Edgar F. Codd", "Edgar F. Codd published the relational model in 1970."),
            ("Which operation filters rows based on a condition?", ["PROJECT", "SELECT", "JOIN", "UNION"], "SELECT", "The SELECT (σ) operation filters tuples based on a predicate."),
            ("Which operation selects specific columns?", ["SELECT", "PROJECT", "RESTRICT", "DIVIDE"], "PROJECT", "PROJECT (π) selects specific attributes, removing duplicates."),
            ("What does the UNION operation require?", ["Same primary keys", "Same number of rows", "Union-compatible relations", "Foreign key relationships"], "Union-compatible relations", "UNION requires both relations to have the same number of attributes with compatible domains."),
            ("A NULL value represents:", ["Zero", "An empty string", "A missing or unknown value", "A false boolean"], "A missing or unknown value", "NULL represents missing, unknown, or inapplicable data — not zero or empty string."),
            ("What is a base relation?", ["A view", "A physically stored table", "A temporary table", "An index"], "A physically stored table", "A base relation is a named relation that physically stores data."),
            ("The closed world assumption states:", ["All data is encrypted", "Unstored facts are false", "All tables must have keys", "NULLs are not allowed"], "Unstored facts are false", "Under the closed world assumption, if a fact is not in the database, it is considered false."),
            ("What is a derived relation?", ["A base table", "A view defined by a query", "A foreign key", "An index"], "A view defined by a query", "A derived relation (view) is a virtual table defined by a query."),
            ("Which is NOT a relational algebra operation?", ["SELECT", "PROJECT", "COMMIT", "JOIN"], "COMMIT", "COMMIT is a transaction control command, not a relational algebra operation."),
            ("What does the Cartesian Product produce?", ["Matching rows only", "All possible row combinations", "Unique rows only", "Sorted rows"], "All possible row combinations", "Cartesian Product combines every tuple from one relation with every tuple from another."),
            ("A relation schema defines:", ["Actual data values", "Structure of a relation", "Query results", "Index structures"], "Structure of a relation", "A relation schema defines the name, attributes, and domains of a relation."),
            ("An equijoin uses which comparison?", ["Less than", "Greater than", "Equality only", "Any comparison"], "Equality only", "An equijoin is a theta join where the condition uses only equality (=)."),
            ("What does a LEFT OUTER JOIN preserve?", ["Only matched rows", "All rows from the left relation", "All rows from the right relation", "All rows from both"], "All rows from the left relation", "LEFT OUTER JOIN keeps all tuples from the left relation, with NULLs for unmatched right rows."),
            ("Which is a property of relations?", ["Duplicate rows allowed", "Column order matters", "Each cell contains an atomic value", "Row order matters"], "Each cell contains an atomic value", "In the relational model, all attribute values must be atomic (indivisible)."),
            ("What is relational calculus?", ["A procedural query language", "A non-procedural query language", "A physical storage model", "A normalization technique"], "A non-procedural query language", "Relational calculus is declarative — it specifies what to retrieve, not how."),
            ("Relational algebra is considered:", ["Declarative", "Procedural", "Object-oriented", "Hierarchical"], "Procedural", "Relational algebra specifies the sequence of operations (how) to retrieve data."),
            ("A self-join is:", ["A join between different databases", "A table joined with itself", "A join without conditions", "A cross-database join"], "A table joined with itself", "A self-join joins a table to itself using aliases."),
            ("What is a natural join?", ["Joins on all common attributes automatically", "Joins on primary keys only", "A cross join", "A join with no conditions"], "Joins on all common attributes automatically", "Natural join matches on all attributes with the same name in both relations."),
            ("The DIVISION operation answers which type of query?", ["Find any match", "Find all matches (for all)", "Find the first match", "Count matches"], "Find all matches (for all)", "Division finds tuples associated with ALL tuples in another relation."),
            ("What is a semijoin?", ["Returns columns from both tables", "Returns only matching rows from the first table", "Returns all rows", "A self-join"], "Returns only matching rows from the first table", "A semijoin returns tuples from the first relation that have matches in the second."),
            ("Codd's Information Rule states:", ["Data must be encrypted", "All info is represented in tables", "All tables need indexes", "Foreign keys are required"], "All info is represented in tables", "Rule 1: All information is represented at the logical level by values in tables."),
            ("The entity integrity rule requires:", ["Foreign keys match primary keys", "No primary key attribute is NULL", "All attributes are unique", "Tables have at most 10 columns"], "No primary key attribute is NULL", "Entity integrity ensures every tuple is uniquely identifiable via a non-null primary key."),
        ]
        for q in rmQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: relationalModel))
        }

        // --- ER Diagrams Quizzes (25+) ---
        let erQ: [(String, [String], String, String)] = [
            ("In Crow's Foot notation, a fork symbol represents:", ["One", "Zero", "Many", "Optional"], "Many", "The crow's foot (fork) indicates a maximum cardinality of 'many'."),
            ("A weak entity is represented by:", ["A single-border rectangle", "A double-border rectangle", "A diamond", "An oval"], "A double-border rectangle", "Weak entities use double-border rectangles to distinguish them from strong entities."),
            ("What symbol represents a derived attribute?", ["Solid oval", "Double oval", "Dashed oval", "Underlined oval"], "Dashed oval", "Derived attributes are shown with dashed ovals."),
            ("A multivalued attribute is shown as:", ["Single oval", "Double oval", "Dashed oval", "Rectangle"], "Double oval", "Multivalued attributes use double-bordered ovals."),
            ("Total participation is shown as:", ["Single line", "Double line", "Dashed line", "Dotted line"], "Double line", "Total (mandatory) participation uses a double line in Chen notation."),
            ("In a 1:M relationship, the FK goes on which side?", ["The 'one' side", "The 'many' side", "Both sides", "Neither side"], "The 'many' side", "The PK of the 'one' side is placed as a FK in the 'many' side table."),
            ("An M:N relationship requires:", ["A foreign key", "A junction/bridge table", "A weak entity", "A derived attribute"], "A junction/bridge table", "M:N relationships need an associative/junction table to resolve into two 1:M relationships."),
            ("In Crow's Foot, O| means:", ["Exactly one", "One or many", "Zero or one", "Zero or many"], "Zero or one", "O (optional/zero) + | (one) = zero or one."),
            ("In Crow's Foot, || means:", ["Zero or one", "Exactly one (mandatory)", "Zero or many", "One or many"], "Exactly one (mandatory)", "Two dashes (||) = mandatory one, meaning exactly one."),
            ("A recursive relationship involves:", ["Two different entities", "An entity related to itself", "Three entities", "A weak entity"], "An entity related to itself", "A recursive/unary relationship is an entity associated with itself."),
            ("The degree of a binary relationship is:", ["1", "2", "3", "4"], "2", "A binary relationship involves exactly two entity types."),
            ("Which notation is most common in industry?", ["Chen", "Crow's Foot", "Bachman", "UML only"], "Crow's Foot", "Crow's Foot is the most widely used notation in industry tools."),
            ("An identifying relationship connects:", ["Two strong entities", "A weak entity to its owner", "Two weak entities", "An entity to an attribute"], "A weak entity to its owner", "An identifying relationship links a weak entity to the strong entity it depends on."),
            ("A partial key (discriminator) belongs to:", ["A strong entity", "A weak entity", "A relationship", "A view"], "A weak entity", "A partial key partially identifies instances of a weak entity."),
            ("What is specialization?", ["Combining entities into one", "Dividing an entity into subtypes", "Creating a new relationship", "Removing attributes"], "Dividing an entity into subtypes", "Specialization decomposes a supertype into subtypes based on distinguishing characteristics."),
            ("What is generalization?", ["Dividing entities", "Combining entities into a supertype", "Creating indexes", "Normalizing tables"], "Combining entities into a supertype", "Generalization combines entity types with common attributes into a higher-level supertype."),
            ("Disjoint specialization means:", ["Entity belongs to multiple subtypes", "Entity belongs to only one subtype", "All entities must specialize", "No specialization allowed"], "Entity belongs to only one subtype", "Disjoint (d) means each supertype instance can be in at most one subtype."),
            ("An attribute of a relationship is common in:", ["1:1 relationships", "1:M relationships", "M:N relationships", "Recursive relationships"], "M:N relationships", "M:N relationships often have attributes (e.g., grade on enrollment)."),
            ("How is a key attribute shown in Chen notation?", ["Bold text", "Underlined name", "Dashed oval", "Double rectangle"], "Underlined name", "Key attributes are shown in ovals with the attribute name underlined."),
            ("A ternary relationship involves how many entities?", ["1", "2", "3", "4"], "3", "A ternary relationship involves three entity types."),
            ("Min-max notation (1,N) means:", ["Optional, one only", "Mandatory, many possible", "Optional, many possible", "Mandatory, one only"], "Mandatory, many possible", "(1,N) means minimum 1 (mandatory) and maximum N (many)."),
            ("Overlapping specialization means:", ["An entity can belong to multiple subtypes", "An entity belongs to one subtype only", "Subtypes cannot exist", "All must specialize"], "An entity can belong to multiple subtypes", "Overlapping (o) allows a supertype instance to belong to multiple subtypes."),
            ("A relationship in Chen notation is drawn as:", ["Rectangle", "Oval", "Diamond", "Triangle"], "Diamond", "Relationships are represented by diamond shapes in Chen notation."),
            ("What is modality?", ["Maximum participation", "Minimum participation (0 or 1)", "Number of entities", "Number of attributes"], "Minimum participation (0 or 1)", "Modality indicates whether participation is optional (0) or mandatory (1)."),
            ("How do you convert a 1:1 relationship to tables?", ["Create a junction table", "Put FK on either side (prefer total participation side)", "Merge into one table always", "Create three tables"], "Put FK on either side (prefer total participation side)", "For 1:1, place the FK on the side with total participation if possible."),
        ]
        for q in erQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: erDiagrams))
        }

        // --- Keys Quizzes (25+) ---
        let keyQ: [(String, [String], String, String)] = [
            ("A candidate key is:", ["Any set of unique attributes", "A minimal superkey", "Always a single column", "The same as a foreign key"], "A minimal superkey", "A candidate key is a minimal superkey — removing any attribute would lose uniqueness."),
            ("How many primary keys can a table have?", ["Zero", "Exactly one", "Two", "Unlimited"], "Exactly one", "A table has exactly one primary key, though it may be composite (multiple columns)."),
            ("A surrogate key is:", ["A natural business attribute", "A system-generated artificial key", "A foreign key", "A composite key"], "A system-generated artificial key", "Surrogate keys are auto-generated (e.g., auto-increment) with no business meaning."),
            ("Referential integrity ensures:", ["Primary keys are unique", "Foreign keys match existing primary keys or are NULL", "All columns have values", "Tables are normalized"], "Foreign keys match existing primary keys or are NULL", "Referential integrity requires FK values to match an existing PK or be NULL."),
            ("CASCADE on DELETE means:", ["Prevent deletion", "Set FK to NULL", "Delete referencing rows too", "Set FK to default"], "Delete referencing rows too", "CASCADE automatically deletes all rows that reference the deleted row."),
            ("SET NULL on DELETE means:", ["Prevent deletion", "Set FK values to NULL", "Delete referencing rows", "Ignore the constraint"], "Set FK values to NULL", "SET NULL sets the foreign key column to NULL when the referenced row is deleted."),
            ("RESTRICT on DELETE means:", ["Allow deletion always", "Prevent deletion if references exist", "Delete referencing rows", "Set FK to default"], "Prevent deletion if references exist", "RESTRICT prevents deletion of a row that is still referenced by foreign keys."),
            ("A composite primary key consists of:", ["One column", "Two or more columns", "No columns", "All columns"], "Two or more columns", "A composite key uses multiple attributes together to uniquely identify rows."),
            ("Entity integrity requires:", ["Foreign keys are not NULL", "Primary keys are not NULL", "All attributes are not NULL", "Indexes exist"], "Primary keys are not NULL", "Entity integrity: no component of a primary key may be NULL."),
            ("An alternate key is:", ["The chosen primary key", "A candidate key not chosen as PK", "A foreign key", "A superkey that's not minimal"], "A candidate key not chosen as PK", "Alternate keys are candidate keys that were not selected as the primary key."),
            ("A natural key example is:", ["Auto-increment ID", "GUID", "Social Security Number", "Row number"], "Social Security Number", "Natural keys have real-world meaning, like SSN, ISBN, or email."),
            ("Can a foreign key be NULL?", ["Never", "Yes, if no NOT NULL constraint", "Only in junction tables", "Only with CASCADE"], "Yes, if no NOT NULL constraint", "FK can be NULL unless explicitly constrained with NOT NULL, indicating optional relationship."),
            ("A junction table resolves which relationship?", ["1:1", "1:M", "M:N", "Recursive"], "M:N", "Junction/bridge tables resolve many-to-many relationships using two foreign keys."),
            ("The primary key of a junction table is typically:", ["A surrogate key", "A composite of both foreign keys", "One foreign key", "No primary key"], "A composite of both foreign keys", "The composite of both FKs typically forms the PK of a junction table."),
            ("What is key migration?", ["Deleting a key", "Copying a PK as FK to another table", "Changing key data type", "Adding an index"], "Copying a PK as FK to another table", "Key migration is the process of placing a PK from one table as a FK in another."),
            ("A self-referencing FK references:", ["Another table's PK", "Its own table's PK", "A view", "An index"], "Its own table's PK", "A self-referencing FK points to the PK of the same table (e.g., manager_id → employee_id)."),
            ("UNIQUE constraint differs from PRIMARY KEY because:", ["UNIQUE allows NULL values", "UNIQUE doesn't enforce uniqueness", "PRIMARY KEY allows duplicates", "They are identical"], "UNIQUE allows NULL values", "UNIQUE allows NULL (typically one) and multiple UNIQUE constraints per table. PK allows neither."),
            ("A dangling reference is:", ["A valid FK value", "An FK value with no matching PK", "A NULL primary key", "An unused index"], "An FK value with no matching PK", "A dangling reference violates referential integrity — the FK points to a non-existent PK."),
            ("ON UPDATE CASCADE means:", ["Prevent updates to PK", "Auto-update matching FKs", "Delete matching rows", "Set FKs to NULL"], "Auto-update matching FKs", "When a PK value changes, all matching FK values are automatically updated."),
            ("Which is NOT a good primary key practice?", ["Use stable values", "Use minimal columns", "Use frequently changing values", "Ensure NOT NULL"], "Use frequently changing values", "Good PKs should be stable/immutable. Changing PKs requires cascading updates."),
            ("A superkey is:", ["Always minimal", "Any set that uniquely identifies rows", "Always a single column", "The same as a foreign key"], "Any set that uniquely identifies rows", "A superkey is any combination of attributes that uniquely identifies tuples."),
            ("Can a table have multiple UNIQUE constraints?", ["No", "Yes", "Only with a surrogate key", "Only on numeric columns"], "Yes", "A table can have multiple UNIQUE constraints but only one PRIMARY KEY."),
            ("A lookup/reference table is used to:", ["Store transaction data", "Store valid values for coded fields", "Replace indexes", "Backup data"], "Store valid values for coded fields", "Lookup tables store valid values (e.g., state codes, status types) referenced by FKs."),
            ("What does a FK with ON DELETE SET DEFAULT do?", ["Deletes the FK row", "Sets FK to its default value", "Prevents deletion", "Sets FK to NULL"], "Sets FK to its default value", "SET DEFAULT sets the FK column to its defined default value when the referenced row is deleted."),
            ("In weak entity key inheritance, the full PK is:", ["Only the partial key", "Owner's PK + partial key", "Only the owner's PK", "A surrogate key"], "Owner's PK + partial key", "A weak entity's PK = owner entity's PK + its own discriminator/partial key."),
        ]
        for q in keyQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: keys))
        }

        // --- Normalization Quizzes (25+) ---
        let normQ: [(String, [String], String, String)] = [
            ("1NF requires:", ["No partial dependencies", "All values are atomic", "No transitive dependencies", "Every determinant is a superkey"], "All values are atomic", "First Normal Form requires all attribute values to be atomic (indivisible)."),
            ("2NF eliminates:", ["Multivalued attributes", "Partial dependencies", "Transitive dependencies", "All redundancy"], "Partial dependencies", "2NF removes partial dependencies — non-key attributes depending on part of a composite key."),
            ("3NF eliminates:", ["Repeating groups", "Partial dependencies", "Transitive dependencies", "Multivalued dependencies"], "Transitive dependencies", "3NF removes transitive dependencies — non-key attributes depending on other non-key attributes."),
            ("BCNF requires that every determinant is:", ["A foreign key", "A superkey", "A candidate key", "A non-key attribute"], "A superkey", "In BCNF, for every functional dependency X → Y, X must be a superkey."),
            ("A partial dependency can only occur when:", ["The PK is a single column", "The PK is composite", "There are no foreign keys", "The table has no indexes"], "The PK is composite", "Partial dependencies require a composite PK — depending on part of the key."),
            ("An insertion anomaly is:", ["Deleting too much data", "Unable to insert data without other data", "Inconsistent updates", "Slow insert performance"], "Unable to insert data without other data", "Insertion anomaly: can't add data because other required (unrelated) data is missing."),
            ("An update anomaly is:", ["Slow updates", "Inconsistency from redundant data updates", "Unable to update", "Automatic updates"], "Inconsistency from redundant data updates", "Update anomaly: changing data in one place but not all copies, causing inconsistency."),
            ("A deletion anomaly is:", ["Slow deletion", "Unintended data loss when deleting a row", "Unable to delete", "Cascading deletes"], "Unintended data loss when deleting a row", "Deletion anomaly: losing unrelated data because it's stored only in the deleted row."),
            ("In X → Y, X is called the:", ["Dependent", "Determinant", "Foreign key", "Candidate key"], "Determinant", "The left side of a functional dependency is the determinant."),
            ("Denormalization is:", ["Removing all redundancy", "Intentionally adding redundancy for performance", "Converting to 1NF", "Dropping tables"], "Intentionally adding redundancy for performance", "Denormalization adds controlled redundancy to improve read/query performance."),
            ("Which normal form is the strictest?", ["1NF", "2NF", "3NF", "BCNF"], "BCNF", "BCNF is stricter than 3NF — every determinant must be a superkey."),
            ("A trivial functional dependency is:", ["A → B where B is a subset of A", "A → B where A is a key", "A → B where B is a key", "Any dependency"], "A → B where B is a subset of A", "A trivial FD has the dependent as a subset of the determinant (always true)."),
            ("Lossless decomposition means:", ["Data is compressed", "Original relation can be reconstructed by joining", "Some data may be lost", "Tables are encrypted"], "Original relation can be reconstructed by joining", "Lossless decomposition guarantees no data is lost when tables are rejoined."),
            ("Armstrong's axiom of transitivity states:", ["If X→Y then Y→X", "If X→Y and Y→Z then X→Z", "If X→Y then XZ→YZ", "If Y⊆X then X→Y"], "If X→Y and Y→Z then X→Z", "Transitivity: if X determines Y, and Y determines Z, then X determines Z."),
            ("A repeating group violates:", ["2NF", "3NF", "1NF", "BCNF"], "1NF", "Repeating groups (non-atomic values) violate First Normal Form."),
            ("Which is true about a table in 3NF?", ["It's always in BCNF", "It's always in 2NF", "It may have partial dependencies", "It has no primary key"], "It's always in 2NF", "3NF implies 2NF which implies 1NF. But 3NF doesn't guarantee BCNF."),
            ("A prime attribute is:", ["Any attribute", "Part of a candidate key", "A foreign key", "A non-key attribute"], "Part of a candidate key", "A prime attribute participates in at least one candidate key."),
            ("4NF addresses:", ["Partial dependencies", "Transitive dependencies", "Multivalued dependencies", "Join dependencies"], "Multivalued dependencies", "4NF eliminates non-trivial multivalued dependencies."),
            ("Student(ID, Name, Major, AdvisorName, AdvisorOffice) — AdvisorOffice depends on AdvisorName. This violates:", ["1NF", "2NF", "3NF", "No violation"], "3NF", "AdvisorOffice transitively depends on ID through AdvisorName — a 3NF violation."),
            ("Normalization primarily reduces:", ["Query complexity", "Data redundancy", "Number of tables", "Storage space"], "Data redundancy", "The main goal of normalization is to eliminate data redundancy and anomalies."),
            ("A canonical cover is:", ["The largest set of FDs", "A minimal equivalent set of FDs", "All possible FDs", "Only trivial FDs"], "A minimal equivalent set of FDs", "A canonical cover is a minimal set of FDs equivalent to the original, with no redundancy."),
            ("Dependency preservation means:", ["All data is preserved", "All FDs can be checked without joining", "Keys are preserved", "Indexes are preserved"], "All FDs can be checked without joining", "Dependency preservation ensures all original FDs can be enforced on individual decomposed tables."),
            ("The closure X⁺ of attributes X is:", ["All attributes determined by X", "All superkeys", "All candidate keys", "All FDs"], "All attributes determined by X", "X⁺ is the set of all attributes functionally determined by X using the given FDs."),
            ("Which normal form addresses join dependencies?", ["3NF", "BCNF", "4NF", "5NF"], "5NF", "5NF (Project-Join Normal Form) addresses join dependencies."),
            ("Over-normalization can cause:", ["Data redundancy", "Too many joins hurting performance", "Anomalies", "NULL values"], "Too many joins hurting performance", "Excessive normalization creates many small tables requiring complex joins."),
        ]
        for q in normQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: normalization))
        }

        // --- DDL Quizzes (25+) ---
        let ddlQ: [(String, [String], String, String)] = [
            ("Which is a DDL command?", ["SELECT", "INSERT", "CREATE TABLE", "UPDATE"], "CREATE TABLE", "CREATE TABLE defines database structure — a Data Definition Language command."),
            ("DROP TABLE does what?", ["Removes all rows", "Removes the table and all data", "Removes indexes only", "Renames the table"], "Removes the table and all data", "DROP TABLE permanently deletes the table structure and all its data."),
            ("ALTER TABLE is used to:", ["Query data", "Modify table structure", "Insert data", "Delete rows"], "Modify table structure", "ALTER TABLE adds/drops/modifies columns and constraints on existing tables."),
            ("NOT NULL constraint ensures:", ["Unique values", "No NULL values in the column", "Values match a pattern", "Values are positive"], "No NULL values in the column", "NOT NULL prevents the column from containing NULL values."),
            ("How many PRIMARY KEY constraints per table?", ["Zero", "One", "Two", "Unlimited"], "One", "Each table can have exactly one PRIMARY KEY constraint (which may be composite)."),
            ("CHECK constraint does what?", ["Ensures uniqueness", "Validates values against a condition", "Creates an index", "Links tables"], "Validates values against a condition", "CHECK limits allowed values based on a Boolean expression."),
            ("DEFAULT constraint provides:", ["A unique value", "A value when none is specified", "An index", "A foreign key"], "A value when none is specified", "DEFAULT supplies a value when INSERT doesn't specify one for that column."),
            ("TRUNCATE TABLE vs DELETE:", ["TRUNCATE is DML", "TRUNCATE keeps table structure, removes all rows", "TRUNCATE uses WHERE", "TRUNCATE is slower"], "TRUNCATE keeps table structure, removes all rows", "TRUNCATE removes all data but preserves the table definition. Faster than DELETE."),
            ("VARCHAR(50) stores:", ["Exactly 50 characters", "Up to 50 variable-length characters", "50 integers", "50 bytes of binary data"], "Up to 50 variable-length characters", "VARCHAR stores variable-length strings up to the specified maximum."),
            ("DECIMAL(8,2) can store:", ["8 decimal places", "Up to 999999.99", "8 digits total, all decimals", "Only integers"], "Up to 999999.99", "DECIMAL(8,2) = 8 total digits, 2 after decimal point."),
            ("CREATE INDEX is used to:", ["Create a table", "Speed up data retrieval", "Add a constraint", "Create a view"], "Speed up data retrieval", "Indexes improve query performance by creating efficient access paths."),
            ("IF NOT EXISTS in CREATE TABLE:", ["Drops existing table first", "Prevents error if table exists", "Creates table only if data exists", "Forces table creation"], "Prevents error if table exists", "IF NOT EXISTS skips creation without error when the table already exists."),
            ("AUTO_INCREMENT/IDENTITY is used for:", ["Date columns", "Generating unique sequential IDs", "Encrypting data", "Creating indexes"], "Generating unique sequential IDs", "AUTO_INCREMENT automatically generates unique sequential numbers for new rows."),
            ("A table constraint is defined:", ["Inline with a column", "After all column definitions", "In a separate file", "In the WHERE clause"], "After all column definitions", "Table constraints are defined after all columns — required for composite keys."),
            ("CREATE VIEW creates:", ["A physical table", "A virtual table from a query", "An index", "A stored procedure"], "A virtual table from a query", "Views are virtual tables defined by SELECT queries."),
            ("Which data type is best for currency?", ["FLOAT", "DECIMAL", "VARCHAR", "INT"], "DECIMAL", "DECIMAL/NUMERIC avoids floating-point precision errors with monetary values."),
            ("FOREIGN KEY with REFERENCES:", ["Creates an index", "Links to another table's key", "Makes column unique", "Sets a default value"], "Links to another table's key", "REFERENCES specifies which table/column the foreign key points to."),
            ("A temporary table:", ["Persists forever", "Exists only for the session", "Cannot hold data", "Is always empty"], "Exists only for the session", "Temporary tables exist only for the duration of a session or transaction."),
            ("DROP vs TRUNCATE:", ["Both remove structure", "DROP removes structure, TRUNCATE keeps it", "TRUNCATE removes structure", "Both keep structure"], "DROP removes structure, TRUNCATE keeps it", "DROP deletes table + data. TRUNCATE deletes data only, keeping the table structure."),
            ("How to add a column to an existing table?", ["CREATE COLUMN", "ALTER TABLE ADD column", "INSERT COLUMN", "UPDATE TABLE ADD column"], "ALTER TABLE ADD column", "ALTER TABLE table_name ADD column_name datatype;"),
            ("How to remove a constraint?", ["DELETE CONSTRAINT", "ALTER TABLE DROP CONSTRAINT", "REMOVE CONSTRAINT", "TRUNCATE CONSTRAINT"], "ALTER TABLE DROP CONSTRAINT", "ALTER TABLE table_name DROP CONSTRAINT constraint_name;"),
            ("CHAR(10) vs VARCHAR(10):", ["CHAR is variable, VARCHAR is fixed", "CHAR is fixed-length, VARCHAR is variable", "Both are identical", "CHAR stores numbers only"], "CHAR is fixed-length, VARCHAR is variable", "CHAR always uses 10 characters (padded). VARCHAR uses only what's needed up to 10."),
            ("CREATE DATABASE:", ["Creates a table", "Creates a new database", "Creates a schema", "Creates an index"], "Creates a new database", "CREATE DATABASE creates a new database container."),
            ("A computed/generated column:", ["Must be manually updated", "Auto-calculates from other columns", "Cannot be queried", "Requires an index"], "Auto-calculates from other columns", "Generated columns derive their values automatically from expressions on other columns."),
            ("Which is valid for composite PK?", ["PRIMARY KEY (col1)", "PRIMARY KEY (col1, col2)", "PRIMARY KEY col1 col2", "KEY (col1, col2)"], "PRIMARY KEY (col1, col2)", "Composite PKs are defined as table constraints: PRIMARY KEY (col1, col2)."),
        ]
        for q in ddlQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: ddl))
        }

        // --- DML Quizzes (25+) ---
        let dmlQ: [(String, [String], String, String)] = [
            ("Which is a DML command?", ["CREATE", "ALTER", "SELECT", "DROP"], "SELECT", "SELECT retrieves data — a Data Manipulation Language command."),
            ("DELETE without WHERE:", ["Deletes one row", "Deletes all rows", "Causes an error", "Does nothing"], "Deletes all rows", "DELETE without WHERE removes every row from the table."),
            ("ORDER BY default sort order:", ["Descending", "Random", "Ascending", "By primary key"], "Ascending", "ORDER BY defaults to ASC (ascending) unless DESC is specified."),
            ("GROUP BY is used with:", ["DDL commands", "Aggregate functions", "ALTER TABLE", "CREATE INDEX"], "Aggregate functions", "GROUP BY groups rows for aggregate calculations (COUNT, SUM, AVG, etc.)."),
            ("HAVING filters:", ["Individual rows", "Columns", "Groups after GROUP BY", "Tables"], "Groups after GROUP BY", "HAVING filters groups created by GROUP BY, unlike WHERE which filters rows."),
            ("INNER JOIN returns:", ["All rows from both tables", "Only matching rows from both", "All from left, matched from right", "Cartesian product"], "Only matching rows from both", "INNER JOIN returns only rows with matches in both tables."),
            ("LEFT JOIN returns:", ["Only matching rows", "All left rows + matching right rows", "All right rows + matching left rows", "Cartesian product"], "All left rows + matching right rows", "LEFT JOIN preserves all left table rows, NULLs for unmatched right rows."),
            ("COUNT(*) vs COUNT(column):", ["They're identical", "COUNT(*) includes NULLs, COUNT(col) doesn't", "COUNT(col) is faster", "COUNT(*) counts columns"], "COUNT(*) includes NULLs, COUNT(col) doesn't", "COUNT(*) counts all rows. COUNT(column) counts only non-NULL values."),
            ("DISTINCT removes:", ["NULL values", "Duplicate rows", "Empty strings", "Foreign keys"], "Duplicate rows", "DISTINCT eliminates duplicate rows from the result set."),
            ("SQL execution order starts with:", ["SELECT", "FROM", "WHERE", "ORDER BY"], "FROM", "Logical execution: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT."),
            ("A subquery in WHERE is called:", ["An inline view", "A scalar subquery", "A nested subquery", "A derived table"], "A nested subquery", "Subqueries in the WHERE clause are commonly called nested subqueries."),
            ("A correlated subquery:", ["Runs once", "References the outer query", "Is always faster", "Cannot use WHERE"], "References the outer query", "A correlated subquery references columns from the outer query, running once per outer row."),
            ("UNION vs UNION ALL:", ["UNION keeps duplicates", "UNION ALL removes duplicates", "UNION removes duplicates, UNION ALL keeps them", "They're identical"], "UNION removes duplicates, UNION ALL keeps them", "UNION deduplicates results. UNION ALL is faster by keeping all rows."),
            ("LIKE '%son' matches:", ["Names starting with 'son'", "Names ending with 'son'", "Names containing 'son'", "Exact match 'son'"], "Names ending with 'son'", "% matches any sequence of characters. '%son' matches anything ending in 'son'."),
            ("BETWEEN 10 AND 20 is:", ["Exclusive on both ends", "Inclusive on both ends", "Inclusive start, exclusive end", "Exclusive start, inclusive end"], "Inclusive on both ends", "BETWEEN is inclusive: it includes both boundary values."),
            ("IS NULL is needed because:", ["NULL = NULL returns TRUE", "= NULL doesn't work correctly", "NULL is a string", "NULL equals zero"], "= NULL doesn't work correctly", "NULL comparisons with = return UNKNOWN, not TRUE. Must use IS NULL."),
            ("COALESCE(NULL, NULL, 'hello') returns:", ["NULL", "hello", "Error", "Empty string"], "hello", "COALESCE returns the first non-NULL value from its arguments."),
            ("INSERT INTO ... SELECT:", ["Creates a new table", "Inserts query results into a table", "Selects from an insert", "Is not valid SQL"], "Inserts query results into a table", "INSERT INTO ... SELECT copies rows from a query result into an existing table."),
            ("A CASE expression provides:", ["Looping", "Conditional logic (if-then-else)", "Table creation", "Transaction control"], "Conditional logic (if-then-else)", "CASE provides if-then-else logic within SQL queries."),
            ("CROSS JOIN produces:", ["Only matching rows", "Cartesian product of all rows", "Unique rows only", "NULL rows"], "Cartesian product of all rows", "CROSS JOIN combines every row from table A with every row from table B."),
            ("A derived table appears in:", ["WHERE clause", "FROM clause", "HAVING clause", "ORDER BY clause"], "FROM clause", "A derived table is a subquery in the FROM clause, acting as a temporary table."),
            ("EXCEPT/MINUS returns:", ["All rows from both queries", "Rows in first query but not second", "Rows in both queries", "Duplicate rows"], "Rows in first query but not second", "EXCEPT returns rows from the first result set that don't appear in the second."),
            ("Aggregate functions handle NULLs by:", ["Treating them as zero", "Ignoring them (except COUNT(*))", "Causing errors", "Converting to empty strings"], "Ignoring them (except COUNT(*))", "SUM, AVG, MIN, MAX all skip NULL values. COUNT(*) counts all rows."),
            ("FULL OUTER JOIN returns:", ["Only matching rows", "All rows from both tables", "All from left only", "All from right only"], "All rows from both tables", "FULL OUTER JOIN returns all rows from both tables, NULLs where no match."),
            ("What does EXISTS do?", ["Checks if a table exists", "Returns TRUE if subquery has results", "Creates a table if needed", "Checks column existence"], "Returns TRUE if subquery has results", "EXISTS returns TRUE if the subquery returns at least one row."),
        ]
        for q in dmlQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: dml))
        }

        // --- Models Quizzes (25+) ---
        let modelQ: [(String, [String], String, String)] = [
            ("The conceptual model focuses on:", ["Physical storage", "DBMS-specific details", "High-level entities and relationships", "Indexes and partitions"], "High-level entities and relationships", "Conceptual models capture business concepts without implementation details."),
            ("The logical model includes:", ["Storage details", "Attributes, keys, and normalized structure", "Disk partitions", "Buffer pool settings"], "Attributes, keys, and normalized structure", "Logical models detail the structure (attributes, keys, relationships) independently of any DBMS."),
            ("The physical model includes:", ["Business requirements only", "Entity names only", "DBMS-specific implementation details", "User stories"], "DBMS-specific implementation details", "Physical models specify data types, indexes, tablespaces for a specific DBMS."),
            ("The three-schema architecture has:", ["External, Conceptual, Internal", "User, Admin, System", "Table, View, Index", "Read, Write, Execute"], "External, Conceptual, Internal", "ANSI/SPARC: External (user views), Conceptual (community), Internal (physical)."),
            ("Physical data independence means:", ["Changing storage without affecting logical schema", "Changing tables without affecting queries", "Changing the DBMS", "Changing business rules"], "Changing storage without affecting logical schema", "Physical data independence: storage changes don't affect the conceptual/logical schema."),
            ("Logical data independence means:", ["Changing storage without affecting users", "Changing conceptual schema without affecting external views", "Changing the DBMS vendor", "Physical reorganization"], "Changing conceptual schema without affecting external views", "Logical data independence: conceptual schema changes don't affect external schemas/apps."),
            ("Which data independence is harder to achieve?", ["Physical", "Logical", "Both are equally hard", "Neither is hard"], "Logical", "Logical data independence is harder because schema changes more likely affect applications."),
            ("The external schema describes:", ["Physical storage", "The entire database", "A particular user's view", "System metadata"], "A particular user's view", "External schemas describe the relevant portion of the database for specific users/apps."),
            ("The internal schema describes:", ["User views", "Physical data storage", "Business rules", "Application logic"], "Physical data storage", "Internal schema details how data is physically stored — files, indexes, access paths."),
            ("OLTP systems are optimized for:", ["Complex analytical queries", "Many short transactions", "Data warehousing", "Batch processing"], "Many short transactions", "OLTP handles high volumes of short, fast transactions (inserts, updates, reads)."),
            ("OLAP systems are optimized for:", ["Fast inserts", "Complex analytical queries", "Transaction processing", "Data entry"], "Complex analytical queries", "OLAP supports complex queries for business intelligence and analysis."),
            ("A star schema has:", ["Normalized dimensions", "A central fact table with dimension tables", "No fact tables", "Only one table"], "A central fact table with dimension tables", "Star schema: central fact table surrounded by denormalized dimension tables."),
            ("A snowflake schema differs from star schema by:", ["Having no fact table", "Having normalized dimension tables", "Having no dimensions", "Being fully denormalized"], "Having normalized dimension tables", "Snowflake normalizes dimension tables into sub-dimensions."),
            ("A data dictionary stores:", ["User data", "Metadata about the database", "Backup files", "Query results"], "Metadata about the database", "Data dictionary: centralized repository of metadata (table/column info, constraints, etc.)."),
            ("Forward engineering means:", ["Creating a model from an existing DB", "Creating a DB from a model", "Reverse-engineering code", "Migrating data"], "Creating a DB from a model", "Forward engineering goes from design (model) to implementation (physical database)."),
            ("Reverse engineering means:", ["Creating a model from a design", "Creating a model from an existing DB", "Deleting a database", "Writing queries"], "Creating a model from an existing DB", "Reverse engineering extracts a logical/conceptual model from an existing physical database."),
            ("A fact table contains:", ["Only dimension keys", "Measurable quantities and FK to dimensions", "Only text descriptions", "User credentials"], "Measurable quantities and FK to dimensions", "Fact tables store metrics/measures (sales amount, quantity) and FK references to dimensions."),
            ("A dimension table contains:", ["Numeric measures", "Descriptive attributes for filtering/grouping", "Only foreign keys", "Transaction logs"], "Descriptive attributes for filtering/grouping", "Dimension tables have descriptive attributes (name, category, date) used to analyze facts."),
            ("Metadata is:", ["User-entered data", "Data about data", "Encrypted data", "Deleted data"], "Data about data", "Metadata describes the structure, format, and constraints of the actual data."),
            ("A domain constraint restricts:", ["Table relationships", "Allowable values for an attribute", "Number of tables", "Query speed"], "Allowable values for an attribute", "Domain constraints limit values based on data type, range, or valid set."),
            ("The hierarchical data model organizes data as:", ["Tables", "Trees with parent-child relationships", "Graphs", "Key-value pairs"], "Trees with parent-child relationships", "Hierarchical model: tree structure where each child has exactly one parent."),
            ("The network data model differs from hierarchical by:", ["Using tables", "Allowing multiple parents per child", "Having no relationships", "Using SQL"], "Allowing multiple parents per child", "Network model forms a graph — children can have multiple parents."),
            ("A schema diagram shows:", ["Query results", "Tables, columns, keys, and relationships", "Physical disk layout", "Network topology"], "Tables, columns, keys, and relationships", "Schema diagrams visually represent the database structure."),
            ("An instance of a database is:", ["Its structure definition", "The actual data at a point in time", "Its backup", "Its documentation"], "The actual data at a point in time", "Instance = the data content at a specific moment. Schema = the structure."),
            ("Business rules translate to:", ["Views only", "Database constraints and application logic", "Indexes only", "Storage settings"], "Database constraints and application logic", "Business rules become CHECK constraints, triggers, FK rules, and application code."),
        ]
        for q in modelQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: models))
        }

        // --- DBMS Architecture Quizzes (25+) ---
        let dbmsQ: [(String, [String], String, String)] = [
            ("ACID stands for:", ["Access, Control, Insert, Delete", "Atomicity, Consistency, Isolation, Durability", "Add, Create, Index, Drop", "Authorize, Commit, Isolate, Duplicate"], "Atomicity, Consistency, Isolation, Durability", "ACID properties ensure reliable database transactions."),
            ("Atomicity ensures:", ["Data is encrypted", "A transaction is all-or-nothing", "Data is consistent", "Transactions are fast"], "A transaction is all-or-nothing", "Atomicity: either all operations in a transaction succeed, or none do."),
            ("Durability ensures:", ["Fast queries", "Committed changes survive failures", "Transactions are isolated", "Data is normalized"], "Committed changes survive failures", "Durability: once committed, changes persist even after crashes."),
            ("COMMIT does what?", ["Undoes changes", "Makes transaction changes permanent", "Creates a savepoint", "Locks a table"], "Makes transaction changes permanent", "COMMIT finalizes all changes made during the current transaction."),
            ("ROLLBACK does what?", ["Saves changes", "Undoes uncommitted changes", "Commits automatically", "Creates a backup"], "Undoes uncommitted changes", "ROLLBACK reverts the database to the state before the transaction began."),
            ("A deadlock occurs when:", ["A query is slow", "Two transactions wait for each other's locks", "The database crashes", "A table is dropped"], "Two transactions wait for each other's locks", "Deadlock: circular wait where transactions block each other indefinitely."),
            ("A shared lock allows:", ["Only writes", "Multiple concurrent reads", "Only one reader", "No access"], "Multiple concurrent reads", "Shared (read) locks allow multiple transactions to read simultaneously."),
            ("An exclusive lock allows:", ["Multiple readers", "Only one transaction to read/write", "No transactions", "Unlimited writes"], "Only one transaction to read/write", "Exclusive (write) locks give sole access to one transaction."),
            ("The query optimizer:", ["Writes SQL for you", "Finds the most efficient execution plan", "Creates tables", "Manages users"], "Finds the most efficient execution plan", "The optimizer analyzes different strategies to find the cheapest execution plan."),
            ("A B-tree index is good for:", ["Only equality lookups", "Range and equality queries", "Only full table scans", "Storing BLOBs"], "Range and equality queries", "B-trees maintain sorted order, supporting both equality and range searches efficiently."),
            ("A hash index is best for:", ["Range queries", "Equality lookups", "Sorting", "Full-text search"], "Equality lookups", "Hash indexes map keys to locations — excellent for = but useless for < > ranges."),
            ("A clustered index:", ["Is separate from data", "Physically reorders data rows", "Can have many per table", "Is always a hash index"], "Physically reorders data rows", "Clustered indexes sort the actual data rows — only one per table."),
            ("Write-ahead log (WAL) ensures:", ["Faster queries", "Changes logged before applied to DB", "Automatic backups", "Index creation"], "Changes logged before applied to DB", "WAL writes changes to a log first, enabling recovery if a crash occurs."),
            ("A checkpoint:", ["Deletes old data", "Writes buffered changes to disk", "Creates a new database", "Drops indexes"], "Writes buffered changes to disk", "Checkpoints flush modified pages to disk and record progress in the log."),
            ("READ UNCOMMITTED isolation allows:", ["No reads", "Dirty reads", "Only committed reads", "Serializable access"], "Dirty reads", "READ UNCOMMITTED lets transactions read uncommitted data from others."),
            ("SERIALIZABLE isolation:", ["Is the fastest", "Provides the highest consistency", "Allows dirty reads", "Has no locking"], "Provides the highest consistency", "SERIALIZABLE provides the strongest isolation — equivalent to serial execution."),
            ("A dirty read is:", ["Reading corrupted data", "Reading uncommitted data", "Reading from a view", "Reading NULL values"], "Reading uncommitted data", "A dirty read accesses data modified by an uncommitted transaction."),
            ("A phantom read is:", ["Reading NULL", "Finding new rows in a re-executed query", "Reading deleted rows", "A dirty read"], "Finding new rows in a re-executed query", "Phantom reads occur when new rows appear between two executions of the same query."),
            ("A stored procedure is:", ["A temporary table", "A precompiled set of SQL statements", "An index type", "A constraint"], "A precompiled set of SQL statements", "Stored procedures are named, compiled SQL programs stored in the database."),
            ("A trigger executes:", ["Manually by user", "Automatically in response to table events", "Only at startup", "When the database is backed up"], "Automatically in response to table events", "Triggers fire automatically on INSERT, UPDATE, or DELETE events."),
            ("GRANT is used to:", ["Create tables", "Give permissions to users", "Delete users", "Create indexes"], "Give permissions to users", "GRANT assigns privileges (SELECT, INSERT, etc.) on objects to users/roles."),
            ("SQL injection is prevented by:", ["Using SELECT *", "Parameterized queries", "Disabling indexes", "Using views"], "Parameterized queries", "Parameterized queries separate SQL code from user input, preventing injection."),
            ("The buffer pool/manager:", ["Stores user passwords", "Caches database pages in memory", "Creates backups", "Manages user sessions"], "Caches database pages in memory", "Buffer manager caches frequently accessed pages in RAM to reduce disk I/O."),
            ("Two-phase locking has:", ["Lock and unlock phases", "Growing and shrinking phases", "Read and write phases", "Commit and rollback phases"], "Growing and shrinking phases", "2PL: growing phase (acquire locks), shrinking phase (release locks). Ensures serializability."),
            ("Advantages of a DBMS include:", ["More complexity and cost", "Data independence, integrity, concurrent access", "Slower than file systems", "Requires no training"], "Data independence, integrity, concurrent access", "DBMS provides centralized control, data integrity, concurrent access, security, and recovery."),
        ]
        for q in dbmsQ {
            context.insert(QuizQuestion(type: .multipleChoice, text: q.0, options: q.1, correctAnswer: q.2, explanation: q.3, topic: dbms))
        }
    }

    // MARK: - Glossary
    private static func seedGlossary(context: ModelContext) {
        let terms: [(String, String, String)] = [
            ("Relation", "A two-dimensional table of rows and columns in the relational model.", "Relational Model"),
            ("Tuple", "A single row in a relation representing one record.", "Relational Model"),
            ("Attribute", "A named column in a relation representing a property.", "Relational Model"),
            ("Domain", "The set of all allowable values for an attribute.", "Relational Model"),
            ("Degree", "The number of attributes (columns) in a relation.", "Relational Model"),
            ("Cardinality", "The number of tuples (rows) in a relation, or the max instances in a relationship.", "Relational Model"),
            ("Primary Key", "A column (or set of columns) that uniquely identifies each row in a table. Cannot be NULL.", "Keys"),
            ("Foreign Key", "A column that references the primary key of another table to establish a relationship.", "Keys"),
            ("Candidate Key", "A minimal superkey — a set of attributes that uniquely identifies rows with no redundancy.", "Keys"),
            ("Superkey", "Any set of attributes that uniquely identifies tuples in a relation.", "Keys"),
            ("Composite Key", "A key consisting of two or more attributes.", "Keys"),
            ("Surrogate Key", "A system-generated artificial key with no business meaning.", "Keys"),
            ("Natural Key", "A key derived from real-world data with inherent meaning (e.g., SSN).", "Keys"),
            ("Alternate Key", "A candidate key not chosen as the primary key.", "Keys"),
            ("Entity", "An object or concept about which data is stored, represented as a rectangle in ER diagrams.", "ER Diagrams"),
            ("Weak Entity", "An entity that depends on a strong entity for identification, shown with double borders.", "ER Diagrams"),
            ("Strong Entity", "An entity that exists independently with its own primary key.", "ER Diagrams"),
            ("Relationship", "An association between entities, shown as a diamond in Chen notation.", "ER Diagrams"),
            ("Crow's Foot Notation", "A popular ER notation using fork symbols for 'many' and lines for 'one'.", "ER Diagrams"),
            ("Chen Notation", "The original ER notation using rectangles, diamonds, and ovals.", "ER Diagrams"),
            ("Participation Constraint", "Whether entity participation is total (mandatory) or partial (optional).", "ER Diagrams"),
            ("Total Participation", "Every instance must participate in the relationship (double line).", "ER Diagrams"),
            ("Partial Participation", "Some instances may not participate (single line).", "ER Diagrams"),
            ("Associative Entity", "A junction table that resolves an M:N relationship.", "ER Diagrams"),
            ("Generalization", "Combining entity types with common attributes into a supertype.", "ER Diagrams"),
            ("Specialization", "Dividing a supertype entity into subtypes based on characteristics.", "ER Diagrams"),
            ("1NF (First Normal Form)", "All attribute values must be atomic — no repeating groups or multivalued attributes.", "Normalization"),
            ("2NF (Second Normal Form)", "In 1NF with no partial dependencies on the primary key.", "Normalization"),
            ("3NF (Third Normal Form)", "In 2NF with no transitive dependencies on the primary key.", "Normalization"),
            ("BCNF (Boyce-Codd Normal Form)", "Every determinant in the relation is a superkey.", "Normalization"),
            ("Functional Dependency", "A relationship where one attribute uniquely determines another (X → Y).", "Normalization"),
            ("Partial Dependency", "A non-key attribute depends on only part of a composite primary key.", "Normalization"),
            ("Transitive Dependency", "A non-key attribute depends on another non-key attribute.", "Normalization"),
            ("Insertion Anomaly", "Inability to add data because other required data is missing.", "Normalization"),
            ("Update Anomaly", "Inconsistency from updating redundant data in some but not all locations.", "Normalization"),
            ("Deletion Anomaly", "Unintended loss of data when a row containing the only copy is deleted.", "Normalization"),
            ("Denormalization", "Intentionally adding redundancy to improve read performance.", "Normalization"),
            ("Determinant", "The attribute(s) on the left side of a functional dependency.", "Normalization"),
            ("DDL (Data Definition Language)", "SQL commands that define structure: CREATE, ALTER, DROP, TRUNCATE.", "SQL"),
            ("DML (Data Manipulation Language)", "SQL commands that manipulate data: SELECT, INSERT, UPDATE, DELETE.", "SQL"),
            ("CREATE TABLE", "DDL command to create a new table with specified columns and constraints.", "SQL"),
            ("ALTER TABLE", "DDL command to modify an existing table's structure.", "SQL"),
            ("DROP TABLE", "DDL command to permanently remove a table and its data.", "SQL"),
            ("SELECT", "DML command to retrieve data from one or more tables.", "SQL"),
            ("INSERT", "DML command to add new rows to a table.", "SQL"),
            ("UPDATE", "DML command to modify existing data in a table.", "SQL"),
            ("DELETE", "DML command to remove rows from a table.", "SQL"),
            ("JOIN", "Combines rows from two or more tables based on a related column.", "SQL"),
            ("INNER JOIN", "Returns only rows with matching values in both tables.", "SQL"),
            ("LEFT JOIN", "Returns all rows from the left table plus matching right table rows.", "SQL"),
            ("Subquery", "A query nested inside another query.", "SQL"),
            ("Aggregate Function", "A function that performs a calculation on a set of values: COUNT, SUM, AVG, MIN, MAX.", "SQL"),
            ("GROUP BY", "Groups rows sharing values for aggregate calculations.", "SQL"),
            ("HAVING", "Filters groups created by GROUP BY based on aggregate conditions.", "SQL"),
            ("VIEW", "A virtual table defined by a SQL query over base tables.", "SQL"),
            ("INDEX", "A data structure that improves the speed of data retrieval.", "SQL"),
            ("CONSTRAINT", "A rule enforced on data: NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK, DEFAULT.", "SQL"),
            ("DBMS", "Database Management System — software for creating, managing, and querying databases.", "DBMS"),
            ("ACID Properties", "Atomicity, Consistency, Isolation, Durability — guarantees for reliable transactions.", "DBMS"),
            ("Transaction", "A logical unit of work consisting of one or more operations treated as atomic.", "DBMS"),
            ("COMMIT", "Makes all changes in the current transaction permanent.", "DBMS"),
            ("ROLLBACK", "Undoes all changes made in the current transaction.", "DBMS"),
            ("Deadlock", "A situation where two transactions wait for each other's locks indefinitely.", "DBMS"),
            ("Concurrency Control", "Mechanisms managing simultaneous access to prevent conflicts.", "DBMS"),
            ("Lock", "A mechanism restricting data access to prevent conflicts between transactions.", "DBMS"),
            ("Isolation Level", "Degree to which concurrent transactions are isolated: READ UNCOMMITTED to SERIALIZABLE.", "DBMS"),
            ("Query Optimizer", "DBMS component that determines the most efficient query execution plan.", "DBMS"),
            ("Buffer Pool", "Main memory area caching database pages to reduce disk I/O.", "DBMS"),
            ("Stored Procedure", "A precompiled set of SQL statements stored in the database.", "DBMS"),
            ("Trigger", "A stored procedure that executes automatically on INSERT, UPDATE, or DELETE events.", "DBMS"),
            ("Write-Ahead Log", "Recovery technique logging changes before applying them to the database.", "DBMS"),
            ("Conceptual Model", "High-level data model showing entities and relationships without implementation details.", "Data Models"),
            ("Logical Model", "Detailed data structure with attributes, keys, and normalization, DBMS-independent.", "Data Models"),
            ("Physical Model", "Implementation-specific design with data types, indexes, and storage settings.", "Data Models"),
            ("Three-Schema Architecture", "ANSI/SPARC architecture: External, Conceptual, and Internal schemas.", "Data Models"),
            ("Data Independence", "Ability to change one schema level without affecting others.", "Data Models"),
            ("Schema", "The structural definition of a database — tables, columns, types, constraints.", "Data Models"),
            ("Instance", "The actual data in a database at a particular point in time.", "Data Models"),
            ("Data Dictionary", "A repository of metadata describing database objects.", "Data Models"),
            ("OLTP", "Online Transaction Processing — optimized for many short transactions.", "Data Models"),
            ("OLAP", "Online Analytical Processing — optimized for complex analytical queries.", "Data Models"),
            ("Star Schema", "Data warehouse design with a central fact table surrounded by dimensions.", "Data Models"),
            ("Snowflake Schema", "Star schema variant with normalized dimension tables.", "Data Models"),
            ("Referential Integrity", "Rule that foreign key values must match existing primary keys or be NULL.", "Keys"),
            ("CASCADE", "Referential action that propagates deletes/updates to referencing rows.", "Keys"),
            ("Entity Integrity", "Rule that no primary key attribute may be NULL.", "Keys"),
            ("SQL Injection", "Security attack inserting malicious SQL through application inputs.", "DBMS"),
            ("B-Tree Index", "Balanced tree structure for efficient search, insert, and delete operations.", "DBMS"),
            ("Clustered Index", "An index that physically reorders table data — one per table.", "DBMS"),
            ("Normalization", "Process of organizing data to reduce redundancy and improve integrity.", "Normalization"),
            ("Lossless Decomposition", "Decomposition where the original relation can be perfectly reconstructed.", "Normalization"),
        ]
        for t in terms {
            context.insert(GlossaryTerm(term: t.0, definition: t.1, category: t.2))
        }
    }

    // MARK: - Sample Databases
    private static func seedSampleDatabases(context: ModelContext) {
        // 1. University Database
        context.insert(SampleDatabase(
            name: "University",
            description: "A university database with students, courses, enrollments, departments, and professors.",
            schemaSQL: """
            CREATE TABLE department (dept_id INTEGER PRIMARY KEY, dept_name TEXT NOT NULL, building TEXT, budget REAL);
            CREATE TABLE professor (prof_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, dept_id INTEGER REFERENCES department(dept_id), hire_date TEXT);
            CREATE TABLE student (student_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, email TEXT UNIQUE, gpa REAL, major_dept_id INTEGER REFERENCES department(dept_id), enrollment_year INTEGER);
            CREATE TABLE course (course_id INTEGER PRIMARY KEY, course_name TEXT NOT NULL, credits INTEGER, dept_id INTEGER REFERENCES department(dept_id), prof_id INTEGER REFERENCES professor(prof_id));
            CREATE TABLE enrollment (student_id INTEGER, course_id INTEGER, grade TEXT, semester TEXT, PRIMARY KEY(student_id, course_id), FOREIGN KEY(student_id) REFERENCES student(student_id), FOREIGN KEY(course_id) REFERENCES course(course_id));
            CREATE TABLE prerequisite (course_id INTEGER, prereq_id INTEGER, PRIMARY KEY(course_id, prereq_id), FOREIGN KEY(course_id) REFERENCES course(course_id), FOREIGN KEY(prereq_id) REFERENCES course(course_id));
            """,
            sampleDataSQL: """
            INSERT INTO department VALUES (1,'Computer Science','Tech Hall',500000),(2,'Mathematics','Science Bldg',300000),(3,'English','Liberal Arts',200000),(4,'Physics','Science Bldg',400000),(5,'Business','Commerce Hall',350000);
            INSERT INTO professor VALUES (1,'Alan','Turing',1,'2020-01-15'),(2,'Ada','Lovelace',1,'2019-08-20'),(3,'Isaac','Newton',4,'2018-03-10'),(4,'William','Shakespeare',3,'2021-06-01'),(5,'John','Nash',2,'2017-09-15'),(6,'Grace','Hopper',1,'2016-01-20'),(7,'Marie','Curie',4,'2019-11-05');
            INSERT INTO student VALUES (1,'Alice','Johnson','alice@uni.edu',3.8,1,2022),(2,'Bob','Smith','bob@uni.edu',3.2,1,2021),(3,'Carol','Williams','carol@uni.edu',3.9,2,2023),(4,'David','Brown','david@uni.edu',2.8,5,2022),(5,'Eve','Davis','eve@uni.edu',3.5,3,2021),(6,'Frank','Miller','frank@uni.edu',3.1,4,2023),(7,'Grace','Wilson','grace@uni.edu',3.7,2,2022),(8,'Hank','Taylor','hank@uni.edu',2.9,5,2021),(9,'Ivy','Anderson','ivy@uni.edu',3.6,1,2023),(10,'Jack','Thomas','jack@uni.edu',3.4,4,2022);
            INSERT INTO course VALUES (1,'Intro to Programming',3,1,1),(2,'Data Structures',4,1,2),(3,'Calculus I',4,2,5),(4,'Linear Algebra',3,2,5),(5,'English Composition',3,3,4),(6,'Physics I',4,4,3),(7,'Database Systems',3,1,6),(8,'Algorithms',4,1,2),(9,'Statistics',3,2,5),(10,'Business Ethics',3,5,NULL);
            INSERT INTO enrollment VALUES (1,1,'A','Fall 2022'),(1,2,'B+','Spring 2023'),(1,7,'A-','Fall 2023'),(2,1,'B','Fall 2021'),(2,3,'C+','Spring 2022'),(3,3,'A','Fall 2023'),(3,4,'A-','Fall 2023'),(4,10,'B','Fall 2022'),(4,5,'B+','Spring 2023'),(5,5,'A','Fall 2021'),(6,6,'B','Fall 2023'),(7,3,'A','Fall 2022'),(7,9,'B+','Spring 2023'),(8,10,'C','Fall 2021'),(9,1,'A','Fall 2023'),(9,7,'B+','Fall 2023'),(10,6,'A-','Fall 2022');
            INSERT INTO prerequisite VALUES (2,1),(8,2),(8,3),(4,3),(7,1);
            """,
            iconName: "graduationcap.fill"
        ))

        // 2. Sales Database
        context.insert(SampleDatabase(
            name: "Sales",
            description: "A retail sales database with customers, products, orders, and categories.",
            schemaSQL: """
            CREATE TABLE category (category_id INTEGER PRIMARY KEY, category_name TEXT NOT NULL, description TEXT);
            CREATE TABLE product (product_id INTEGER PRIMARY KEY, product_name TEXT NOT NULL, category_id INTEGER REFERENCES category(category_id), unit_price REAL NOT NULL, stock_quantity INTEGER DEFAULT 0);
            CREATE TABLE customer (customer_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, email TEXT UNIQUE, city TEXT, state TEXT, join_date TEXT);
            CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER REFERENCES customer(customer_id), order_date TEXT NOT NULL, total_amount REAL, status TEXT DEFAULT 'pending');
            CREATE TABLE order_item (order_id INTEGER, product_id INTEGER, quantity INTEGER NOT NULL, unit_price REAL NOT NULL, PRIMARY KEY(order_id, product_id), FOREIGN KEY(order_id) REFERENCES orders(order_id), FOREIGN KEY(product_id) REFERENCES product(product_id));
            CREATE TABLE supplier (supplier_id INTEGER PRIMARY KEY, supplier_name TEXT NOT NULL, contact_email TEXT, city TEXT);
            CREATE TABLE product_supplier (product_id INTEGER, supplier_id INTEGER, supply_price REAL, PRIMARY KEY(product_id, supplier_id), FOREIGN KEY(product_id) REFERENCES product(product_id), FOREIGN KEY(supplier_id) REFERENCES supplier(supplier_id));
            """,
            sampleDataSQL: """
            INSERT INTO category VALUES (1,'Electronics','Devices and gadgets'),(2,'Books','Physical and digital books'),(3,'Clothing','Apparel and accessories'),(4,'Home','Home and garden items'),(5,'Sports','Sports equipment');
            INSERT INTO product VALUES (1,'Laptop',1,999.99,50),(2,'Smartphone',1,699.99,120),(3,'Headphones',1,149.99,200),(4,'SQL Textbook',2,59.99,80),(5,'Database Design Guide',2,45.99,60),(6,'Running Shoes',5,89.99,150),(7,'Desk Lamp',4,34.99,90),(8,'T-Shirt',3,19.99,300),(9,'Tablet',1,449.99,75),(10,'Backpack',5,65.99,100);
            INSERT INTO customer VALUES (1,'John','Doe','john@email.com','New York','NY','2023-01-15'),(2,'Jane','Smith','jane@email.com','Los Angeles','CA','2023-02-20'),(3,'Mike','Johnson','mike@email.com','Chicago','IL','2023-03-10'),(4,'Sarah','Williams','sarah@email.com','Houston','TX','2023-04-05'),(5,'Tom','Brown','tom@email.com','Phoenix','AZ','2023-05-12'),(6,'Lisa','Davis','lisa@email.com','New York','NY','2023-06-18'),(7,'Chris','Miller','chris@email.com','Seattle','WA','2023-07-22'),(8,'Amy','Wilson','amy@email.com','Denver','CO','2023-08-30');
            INSERT INTO orders VALUES (1,1,'2024-01-15',1149.98,'completed'),(2,2,'2024-01-20',699.99,'completed'),(3,3,'2024-02-01',209.98,'completed'),(4,1,'2024-02-14',59.99,'completed'),(5,4,'2024-03-01',89.99,'shipped'),(6,5,'2024-03-10',1449.98,'shipped'),(7,6,'2024-03-15',19.99,'pending'),(8,7,'2024-03-20',514.98,'pending');
            INSERT INTO order_item VALUES (1,1,1,999.99),(1,3,1,149.99),(2,2,1,699.99),(3,3,1,149.99),(3,4,1,59.99),(4,4,1,59.99),(5,6,1,89.99),(6,1,1,999.99),(6,9,1,449.99),(7,8,1,19.99),(8,9,1,449.99),(8,10,1,65.99);
            INSERT INTO supplier VALUES (1,'TechCorp','tech@supply.com','Shenzhen'),(2,'BookWorld','books@supply.com','New York'),(3,'FashionHub','fashion@supply.com','Milan'),(4,'HomeGoods Inc','home@supply.com','Dallas');
            INSERT INTO product_supplier VALUES (1,1,750.00),(2,1,500.00),(3,1,80.00),(4,2,30.00),(5,2,25.00),(7,4,18.00),(8,3,8.00),(9,1,320.00);
            """,
            iconName: "cart.fill"
        ))

        // 3. Hospital Database
        context.insert(SampleDatabase(
            name: "Hospital",
            description: "A hospital database with patients, doctors, appointments, departments, and prescriptions.",
            schemaSQL: """
            CREATE TABLE department (dept_id INTEGER PRIMARY KEY, dept_name TEXT NOT NULL, floor_number INTEGER, phone TEXT);
            CREATE TABLE doctor (doctor_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, specialization TEXT, dept_id INTEGER REFERENCES department(dept_id), hire_date TEXT);
            CREATE TABLE patient (patient_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, date_of_birth TEXT, gender TEXT, phone TEXT, insurance_id TEXT);
            CREATE TABLE appointment (appt_id INTEGER PRIMARY KEY, patient_id INTEGER REFERENCES patient(patient_id), doctor_id INTEGER REFERENCES doctor(doctor_id), appt_date TEXT NOT NULL, appt_time TEXT, reason TEXT, status TEXT DEFAULT 'scheduled');
            CREATE TABLE prescription (rx_id INTEGER PRIMARY KEY, appt_id INTEGER REFERENCES appointment(appt_id), medication TEXT NOT NULL, dosage TEXT, duration_days INTEGER, instructions TEXT);
            CREATE TABLE room (room_id INTEGER PRIMARY KEY, room_number TEXT NOT NULL, dept_id INTEGER REFERENCES department(dept_id), room_type TEXT, is_occupied INTEGER DEFAULT 0);
            CREATE TABLE admission (admission_id INTEGER PRIMARY KEY, patient_id INTEGER REFERENCES patient(patient_id), room_id INTEGER REFERENCES room(room_id), admit_date TEXT, discharge_date TEXT, diagnosis TEXT);
            """,
            sampleDataSQL: """
            INSERT INTO department VALUES (1,'Emergency','1','555-0100'),(2,'Cardiology','3','555-0200'),(3,'Neurology','4','555-0300'),(4,'Pediatrics','2','555-0400'),(5,'Orthopedics','3','555-0500');
            INSERT INTO doctor VALUES (1,'Sarah','Chen','Emergency Medicine',1,'2018-06-15'),(2,'James','Park','Cardiologist',2,'2015-03-20'),(3,'Emily','Roberts','Neurologist',3,'2019-09-01'),(4,'Michael','Lee','Pediatrician',4,'2020-01-10'),(5,'Rachel','Kim','Orthopedic Surgeon',5,'2017-07-22'),(6,'David','Wang','Cardiologist',2,'2016-11-30');
            INSERT INTO patient VALUES (1,'Robert','Garcia','1985-03-15','M','555-1001','INS-001'),(2,'Maria','Lopez','1990-07-22','F','555-1002','INS-002'),(3,'James','Taylor','1978-11-30','M','555-1003','INS-003'),(4,'Linda','Martinez','2015-05-10','F','555-1004','INS-004'),(5,'William','Anderson','1965-09-18','M','555-1005','INS-005'),(6,'Jennifer','Thomas','1992-01-25','F','555-1006','INS-006'),(7,'Charles','Jackson','2010-08-14','M','555-1007','INS-007'),(8,'Patricia','White','1988-12-03','F','555-1008','INS-008');
            INSERT INTO appointment VALUES (1,1,1,'2024-03-15','09:00','Chest pain','completed'),(2,2,2,'2024-03-15','10:30','Heart checkup','completed'),(3,3,3,'2024-03-16','14:00','Headaches','completed'),(4,4,4,'2024-03-17','11:00','Annual checkup','scheduled'),(5,5,5,'2024-03-18','09:30','Knee pain','scheduled'),(6,6,2,'2024-03-18','15:00','Blood pressure','scheduled'),(7,1,1,'2024-03-20','08:00','Follow-up','scheduled'),(8,7,4,'2024-03-20','10:00','Vaccination','scheduled');
            INSERT INTO prescription VALUES (1,1,'Aspirin','81mg',30,'Take once daily'),(2,1,'Nitroglycerin','0.4mg',14,'As needed for chest pain'),(3,2,'Lisinopril','10mg',90,'Take once daily with food'),(4,3,'Sumatriptan','50mg',10,'Take at onset of headache'),(5,5,'Ibuprofen','400mg',14,'Take with food every 6 hours');
            INSERT INTO room VALUES (1,'101',1,'Emergency',1),(2,'102',1,'Emergency',0),(3,'301',2,'ICU',1),(4,'302',2,'Standard',0),(5,'401',3,'Standard',0),(6,'201',4,'Pediatric',0),(7,'303',5,'Recovery',0),(8,'304',5,'Standard',1);
            INSERT INTO admission VALUES (1,1,1,'2024-03-15',NULL,'Acute chest pain'),(2,3,3,'2024-03-16','2024-03-18','Migraine evaluation'),(3,5,8,'2024-03-18',NULL,'Knee surgery prep');
            """,
            iconName: "cross.case.fill"
        ))

        // 4. Employee Database
        context.insert(SampleDatabase(
            name: "Employee",
            description: "A corporate employee database with departments, employees, projects, and assignments.",
            schemaSQL: """
            CREATE TABLE department (dept_id INTEGER PRIMARY KEY, dept_name TEXT NOT NULL, location TEXT, manager_id INTEGER);
            CREATE TABLE employee (emp_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, email TEXT UNIQUE, hire_date TEXT, salary REAL, dept_id INTEGER REFERENCES department(dept_id), manager_id INTEGER REFERENCES employee(emp_id));
            CREATE TABLE project (project_id INTEGER PRIMARY KEY, project_name TEXT NOT NULL, start_date TEXT, end_date TEXT, budget REAL, dept_id INTEGER REFERENCES department(dept_id));
            CREATE TABLE assignment (emp_id INTEGER, project_id INTEGER, role TEXT, hours_per_week REAL, PRIMARY KEY(emp_id, project_id), FOREIGN KEY(emp_id) REFERENCES employee(emp_id), FOREIGN KEY(project_id) REFERENCES project(project_id));
            CREATE TABLE dependent (dependent_id INTEGER PRIMARY KEY, emp_id INTEGER REFERENCES employee(emp_id), first_name TEXT NOT NULL, relationship TEXT, date_of_birth TEXT);
            """,
            sampleDataSQL: """
            INSERT INTO department VALUES (1,'Engineering','Building A',1),(2,'Marketing','Building B',4),(3,'Human Resources','Building A',6),(4,'Finance','Building C',8),(5,'Research','Building D',10);
            INSERT INTO employee VALUES (1,'James','Kirk','kirk@corp.com','2015-01-10',120000,1,NULL),(2,'Spock','Vulcan','spock@corp.com','2016-03-15',110000,1,1),(3,'Uhura','Nyota','uhura@corp.com','2017-06-20',95000,1,1),(4,'Jean','Picard','picard@corp.com','2014-09-01',115000,2,NULL),(5,'Beverly','Crusher','crusher@corp.com','2018-02-14',90000,2,4),(6,'Deanna','Troi','troi@corp.com','2016-11-30',100000,3,NULL),(7,'Worf','Son','worf@corp.com','2019-04-22',85000,3,6),(8,'Data','Android','data@corp.com','2015-07-18',105000,4,NULL),(9,'Geordi','LaForge','laforge@corp.com','2017-10-05',92000,1,1),(10,'Wesley','Crusher','wcrusher@corp.com','2020-01-15',130000,5,NULL);
            INSERT INTO project VALUES (1,'Warp Drive v2',1,'2024-01-01','2024-12-31',500000,1),(2,'Marketing Campaign Q1','2024-01-01','2024-03-31',100000,2),(3,'HR Portal Redesign','2024-02-01','2024-08-31',200000,3),(4,'Financial Audit System','2024-03-01','2024-09-30',300000,4),(5,'Quantum Research','2024-01-01','2025-12-31',800000,5);
            INSERT INTO assignment VALUES (1,1,'Lead',20),(2,1,'Developer',35),(3,1,'Developer',30),(5,2,'Coordinator',25),(9,1,'Developer',35),(4,2,'Lead',30),(7,3,'Lead',25),(6,3,'Consultant',15),(8,4,'Lead',30),(10,5,'Lead',40),(2,5,'Researcher',10);
            INSERT INTO dependent VALUES (1,1,'George','Son','2010-05-20'),(2,1,'Winona','Daughter','2012-08-15'),(3,4,'Rene','Son','2008-03-10'),(4,5,'Wesley','Son','2005-07-22'),(5,6,'Kestra','Daughter','2015-11-30');
            """,
            iconName: "person.3.fill"
        ))

        // 5. Inventory Database
        context.insert(SampleDatabase(
            name: "Inventory",
            description: "A warehouse inventory database with products, warehouses, stock levels, and transfers.",
            schemaSQL: """
            CREATE TABLE warehouse (warehouse_id INTEGER PRIMARY KEY, warehouse_name TEXT NOT NULL, city TEXT, state TEXT, capacity INTEGER);
            CREATE TABLE category (category_id INTEGER PRIMARY KEY, category_name TEXT NOT NULL, parent_category_id INTEGER REFERENCES category(category_id));
            CREATE TABLE product (product_id INTEGER PRIMARY KEY, product_name TEXT NOT NULL, sku TEXT UNIQUE NOT NULL, category_id INTEGER REFERENCES category(category_id), weight_lbs REAL, unit_cost REAL);
            CREATE TABLE stock (warehouse_id INTEGER, product_id INTEGER, quantity INTEGER NOT NULL DEFAULT 0, min_quantity INTEGER DEFAULT 10, last_restocked TEXT, PRIMARY KEY(warehouse_id, product_id), FOREIGN KEY(warehouse_id) REFERENCES warehouse(warehouse_id), FOREIGN KEY(product_id) REFERENCES product(product_id));
            CREATE TABLE transfer (transfer_id INTEGER PRIMARY KEY, from_warehouse INTEGER REFERENCES warehouse(warehouse_id), to_warehouse INTEGER REFERENCES warehouse(warehouse_id), product_id INTEGER REFERENCES product(product_id), quantity INTEGER NOT NULL, transfer_date TEXT, status TEXT DEFAULT 'pending');
            CREATE TABLE vendor (vendor_id INTEGER PRIMARY KEY, vendor_name TEXT NOT NULL, contact_email TEXT, lead_time_days INTEGER);
            CREATE TABLE purchase_order (po_id INTEGER PRIMARY KEY, vendor_id INTEGER REFERENCES vendor(vendor_id), product_id INTEGER REFERENCES product(product_id), quantity INTEGER, order_date TEXT, expected_date TEXT, status TEXT DEFAULT 'ordered');
            """,
            sampleDataSQL: """
            INSERT INTO warehouse VALUES (1,'Main Warehouse','Dallas','TX',100000),(2,'East Coast Hub','Newark','NJ',75000),(3,'West Coast Hub','Oakland','CA',80000),(4,'Midwest Center','Chicago','IL',60000);
            INSERT INTO category VALUES (1,'Electronics',NULL),(2,'Computers',1),(3,'Phones',1),(4,'Accessories',1),(5,'Office Supplies',NULL),(6,'Paper Products',5),(7,'Writing',5);
            INSERT INTO product VALUES (1,'Laptop Pro 15','SKU-LP15',2,4.5,800.00),(2,'Desktop Tower','SKU-DT01',2,25.0,600.00),(3,'Smartphone X','SKU-SPX',3,0.4,400.00),(4,'USB-C Cable','SKU-USB',4,0.1,5.00),(5,'Wireless Mouse','SKU-WM01',4,0.2,15.00),(6,'Copy Paper','SKU-CP01',6,5.0,25.00),(7,'Printer Ink','SKU-PI01',5,0.5,30.00),(8,'Ballpoint Pens','SKU-BP12',7,0.3,8.00),(9,'Monitor 27in','SKU-M27',2,12.0,350.00),(10,'Phone Case','SKU-PC01',4,0.1,10.00);
            INSERT INTO stock VALUES (1,1,500,50,'2024-03-01'),(1,2,200,30,'2024-02-15'),(1,3,1000,100,'2024-03-10'),(1,4,5000,500,'2024-03-05'),(2,1,300,50,'2024-02-20'),(2,3,600,100,'2024-03-01'),(2,6,2000,200,'2024-02-28'),(3,1,400,50,'2024-03-05'),(3,3,800,100,'2024-03-08'),(3,5,1500,150,'2024-02-25'),(4,6,3000,300,'2024-03-01'),(4,7,800,80,'2024-02-20'),(4,8,2500,250,'2024-03-10');
            INSERT INTO transfer VALUES (1,1,2,1,50,'2024-03-15','completed'),(2,1,3,3,200,'2024-03-16','in_transit'),(3,2,4,6,500,'2024-03-17','pending'),(4,3,2,5,300,'2024-03-18','pending');
            INSERT INTO vendor VALUES (1,'TechSupply Co','orders@techsupply.com',7),(2,'Office Depot','bulk@officedepot.com',3),(3,'Global Electronics','sales@globalelec.com',14);
            INSERT INTO purchase_order VALUES (1,1,1,200,'2024-03-10','2024-03-17','received'),(2,1,3,500,'2024-03-12','2024-03-19','shipped'),(3,2,6,1000,'2024-03-14','2024-03-17','ordered'),(4,3,9,100,'2024-03-15','2024-03-29','ordered');
            """,
            iconName: "shippingbox.fill"
        ))
    }
}
