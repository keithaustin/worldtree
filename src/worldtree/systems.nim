import entity

type
  System* = ref object of RootObj
    entities*: seq[Entity]
    