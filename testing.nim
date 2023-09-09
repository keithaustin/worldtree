import ./src/[WorldTree, Component, Entity]

type
  Existence = ref object of Component
    truth: bool = true

var tree = WorldTree()

tree.registerComponentType(Existence)

var e1 = tree.newEntity()
var e2 = tree.newEntity()

tree.addComponent(Existence, e1, Existence(truth: false))

echo hasComponent[Existence](tree, e1)
echo hasComponent[Existence](tree, e2)