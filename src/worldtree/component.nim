import entity
import tables

const max_components* = 32

type 
  Component* = ref object of RootObj
  ComponentType* = int16

  ComponentArray* = object
    componentArray: array[max_entities, Component]
    entityToIndexMap: Table[int, int]
    indexToEntityMap: Table[int, int]
    size: int

proc insertData*(self: var ComponentArray, entity: Entity, component: Component) = 
  assert(self.entityToIndexMap.hasKey(entity) == false, "Attempting to add a component that already exists")

  let newIndex = self.size
  self.entityToIndexMap[entity] = newIndex
  self.indexToEntityMap[newIndex] = entity
  self.componentArray[newIndex] = component

  self.size += 1

proc removeData*(self: var ComponentArray, entity: Entity) =
  assert(self.entityToIndexMap.hasKey(entity), "Attempting to remove a component that doesn't exist")

  let indexToRemove = self.entityToIndexMap[entity]
  let lastIndex = self.size - 1
  self.componentArray[indexToRemove] = self.componentArray[lastIndex]

  let entityAtLastIndex = self.indexToEntityMap[lastIndex]
  self.entityToIndexMap[entityAtLastIndex] = indexToRemove
  self.indexToEntityMap[indexToRemove] = entityAtLastIndex

  self.entityToIndexMap.del(entity)
  self.indexToEntityMap.del(lastIndex)

  self.size -= 1

proc entityRemoved*(self: var ComponentArray, entity: Entity) =
  if self.entityToIndexMap.hasKey(entity):
    self.removeData(entity)

proc getData*(self: ComponentArray, entity: Entity): Component =
  # Add bounds check here
  return self.componentArray[self.entityToIndexMap[entity]]

proc contains*(self: ComponentArray, entity: Entity): bool =
  return self.entityToIndexMap.contains(entity)