import Component
import Entity
import tables
import typetraits

type
  Signature = set[ComponentType]

  WorldTree* = object
    entityCount: int64 = 0
    entities: seq[Entity]
    signatures: array[max_entities, Signature]
    nextComponentType: ComponentType
    componentTypes: Table[string, ComponentType]
    componentData*: Table[string, ComponentArray]

proc newEntity*(self: var WorldTree): Entity = 
  if self.entities.len >= max_entities:
    return -1

  let id = self.entityCount
  self.entityCount += 1

  return id

proc destroyEntity*(self: var WorldTree, entity: Entity) =
  if self.entityCount < entity:
    return

  self.signatures[entity] = {}
  self.entityCount -= 1

#proc setComponentMask*(self: var WorldTree, entity: Entity, signature: Signature) =
#  self.signatures[entity] = signature

#proc getComponentMask*(self: WorldTree, entity: Entity): Signature =
#  if self.entityCount < entity:
#    return {}
#
#  return self.signatures[entity]

proc getComponentArray(self: var WorldTree, T: typedesc): var ComponentArray =
  let typeName = $(T.typeof)

  if typeName in self.componentTypes:
    return self.componentData[typeName]

  return

proc registerComponentType*(self: var WorldTree, T: typedesc) =
  let typeName = $(T.name)
  # Add bounds check here

  self.componentTypes[typeName] = self.nextComponentType
  self.componentData[typeName] = ComponentArray()
  self.nextComponentType += 1

proc addComponent*(self: var WorldTree, T: typedesc, entity: Entity, component: Component) =
  self.getComponentArray(T).insertData(entity, component)

proc getComponent*[T](self: var WorldTree, entity: Entity): T = 
  return cast[T](self.getComponentArray(T).getData(entity))
