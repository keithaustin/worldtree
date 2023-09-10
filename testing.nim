import ./src/[WorldTree, Component]

type
  Existence = ref object of Component

var tree = WorldTree()

tree.registerComponentType(Existence)

var e1 = tree.newEntity()

tree.addComponent(Existence, e1, Existence())

echo hasComponent[Existence](tree, e1)

removeComponent[Existence](tree, e1)

echo hasComponent[Existence](tree, e1)