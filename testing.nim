import ./src/[WorldTree, Component, Entity]

type
  Existence = object of Component
    truth: bool = true

var tree = WorldTree()

tree.registerComponentType(Existence)

var e1 = tree.newEntity()
var e2 = tree.newEntity()
