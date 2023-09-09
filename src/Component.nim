import Entity
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
  # Add bounds check here
  let newIndex = self.size
  self.entityToIndexMap[entity] = newIndex
  self.indexToEntityMap[newIndex] = entity
  self.componentArray[newIndex] = component

proc getData*(self: ComponentArray, entity: Entity): Component =
  # Add bounds check here
  return self.componentArray[self.entityToIndexMap[entity]]

proc contains*(self: ComponentArray, entity: Entity): bool =
  return self.entityToIndexMap.contains(entity)