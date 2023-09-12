import worldtree/[entity, component, systems]
import tables
import typetraits
export component, entity, systems

type
  # Entities' and Systems' signatures are used to keep entities
  # assigned to systems without queries 
  Signature = set[ComponentType]

  # Keeps a registry of all entities, components, and systems and
  # coordinates between them
  WorldTree* = object
    entityCount: int64 = 0
    entities: seq[Entity]
    signatures*: array[max_entities, Signature]
    nextComponentType: ComponentType
    componentTypes: Table[string, ComponentType]
    componentData*: Table[string, ComponentArray]
    systems*: Table[string, System]
    systemSignatures*: Table[string, Signature]

# Creates a new entity
proc newEntity*(self: var WorldTree): Entity = 
  if self.entities.len >= max_entities:
    return -1

  let id = self.entityCount
  self.entityCount += 1

  return id

# Destroys an existing entity, if it exists
proc destroyEntity*(self: var WorldTree, entity: Entity) =
  if self.entityCount < entity:
    return

  for componentType, componentArray in self.componentData:
    self.componentData[componentType].entityRemoved(entity)
    
  for systemType, system in self.systems:
    if entity in system.entities:
      self.systems[systemType].entities.del(entity)

  self.signatures[entity] = {}
  self.entityCount -= 1

# Ensures that entities are affected by the proper systems upon adding/removing components
proc entitySignatureChanged(self: var WorldTree, entity: Entity, newSignature: Signature) =
  for systemType, system in self.systems:
    let systemSignature = self.systemSignatures[systemType]

    if systemSignature <= newSignature:
      if entity notin system.entities:
        self.systems[systemType].entities.insert(entity)
    else:
      if entity in system.entities:
        self.systems[systemType].entities.del(entity)

# Gets the component array for a specified component type
proc getComponentArray(self: var WorldTree, T: typedesc): var ComponentArray =
  let typeName = $(T.typeof)
  return self.componentData[typeName]

# Registers a new component type
proc registerComponentType*[T: Component](self: var WorldTree) =
  let typeName = $(T.name)
  assert(self.componentTypes.hasKey(typeName) == false, "Attempting to register a component twice")

  self.componentTypes[typeName] = self.nextComponentType
  self.componentData[typeName] = ComponentArray()
  self.nextComponentType += 1

# Returns the id of a component type in the registry
proc getComponentType*[T: Component](self: var WorldTree): ComponentType =
  let typeName = $(T.name)
  assert(self.componentTypes.hasKey(typeName), "Attempting to find a component type that isn't registered")

  return self.componentTypes[typeName]

# Checks for a component on an entity
proc hasComponent*[T: Component](self: var WorldTree, entity: Entity): bool = 
  return self.getComponentArray(T).contains(entity)

# Adds a new component to an entity
proc addComponent*[T: Component](self: var WorldTree, entity: Entity, component: Component) =
  self.getComponentArray(T).insertData(entity, component)

  var signature = self.signatures[entity]
  signature.incl(self.getComponentType[:T]())
  self.signatures[entity] = signature

  self.entitySignatureChanged(entity, signature)

# Returns a component of the specified type from an entity
proc getComponent*[T: Component](self: var WorldTree, entity: Entity): T = 
  return cast[T](self.getComponentArray(T).getData(entity))

# Removes a component from an entity
proc removeComponent*[T: Component](self: var WorldTree, entity: Entity) =
  self.getComponentArray(T).removeData(entity)

  var signature = self.signatures[entity]
  signature.excl(self.getComponentType[:T]())
  self.signatures[entity] = signature

  self.entitySignatureChanged(entity, signature)

# Registers a new system
proc registerSystem*[T: System](self: var WorldTree): T =
  let typeName = $(T.name)
  assert(self.systems.hasKey(typeName) == false, "Cannot register a duplicate system.")

  var system = T()
  self.systems[typeName] = system

  return system

# Sets a system's signature
proc setSystemSignature*[T: System](self: var WorldTree, signature: Signature) =
  let typeName = $(T.name)

  if self.systems.hasKey(typeName):
    self.systemSignatures[typeName] = signature
