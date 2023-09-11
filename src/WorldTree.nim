import Component
import Entity
import Systems
import tables
import typetraits

type
  Signature = set[ComponentType]

  WorldTree* = object
    entityCount: int64 = 0
    entities: seq[Entity]
    signatures*: array[max_entities, Signature]
    nextComponentType: ComponentType
    componentTypes: Table[string, ComponentType]
    componentData*: Table[string, ComponentArray]
    systems*: Table[string, System]
    systemSignatures*: Table[string, Signature]

proc newEntity*(self: var WorldTree): Entity = 
  if self.entities.len >= max_entities:
    return -1

  let id = self.entityCount
  self.entityCount += 1

  return id

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

proc entitySignatureChanged(self: var WorldTree, entity: Entity, newSignature: Signature) =
  for systemType, system in self.systems:
    let systemSignature = self.systemSignatures[systemType]

    if systemSignature <= newSignature:
      if entity notin system.entities:
        self.systems[systemType].entities.insert(entity)
    else:
      if entity in system.entities:
        self.systems[systemType].entities.del(entity)

proc setComponentMask*(self: var WorldTree, entity: Entity, signature: Signature) =
  self.signatures[entity] = signature

proc getComponentMask*(self: WorldTree, entity: Entity): Signature =
  if self.entityCount < entity:
    return {}

  return self.signatures[entity]

proc getComponentArray(self: var WorldTree, T: typedesc): var ComponentArray =
  let typeName = $(T.typeof)
  return self.componentData[typeName]

proc registerComponentType*[T: Component](self: var WorldTree) =
  let typeName = $(T.name)
  # Add bounds check here

  self.componentTypes[typeName] = self.nextComponentType
  self.componentData[typeName] = ComponentArray()
  self.nextComponentType += 1

proc getComponentType*[T: Component](self: var WorldTree): ComponentType =
  let typeName = $(T.name)
  # Bounds check here

  return self.componentTypes[typeName]

proc hasComponent*[T: Component](self: var WorldTree, entity: Entity): bool = 
  return self.getComponentArray(T).contains(entity)

proc addComponent*[T: Component](self: var WorldTree, entity: Entity, component: Component) =
  self.getComponentArray(T).insertData(entity, component)

  var signature = self.signatures[entity]
  signature.incl(self.getComponentType[:T]())
  self.signatures[entity] = signature

  self.entitySignatureChanged(entity, signature)

proc getComponent*[T: Component](self: var WorldTree, entity: Entity): T = 
  return cast[T](self.getComponentArray(T).getData(entity))

proc removeComponent*[T: Component](self: var WorldTree, entity: Entity) =
  self.getComponentArray(T).removeData(entity)

  var signature = self.signatures[entity]
  signature.excl(self.getComponentType[:T]())
  self.signatures[entity] = signature

  self.entitySignatureChanged(entity, signature)

proc registerSystem*[T: System](self: var WorldTree): T =
  let typeName = $(T.name)
  # Bounds check goes here

  var system = T()
  self.systems[typeName] = system

  return system

proc setSystemSignature*[T: System](self: var WorldTree, signature: Signature) =
  let typeName = $(T.name)
  # Add bounds check here

  self.systemSignatures[typeName] = signature