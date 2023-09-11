import Entity

type
  System* = ref object of RootObj
    entities*: seq[Entity]
    