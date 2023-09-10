import ./src/[WorldTree, Component]

# Test component, just a flag
type
  Existence = ref object of Component

# Instantiate a tree and register the Existence component
var tree = WorldTree()
tree.registerComponentType[:Existence]()

# Create a new entity and put an Existence flag on it
var e1 = tree.newEntity()
tree.addComponent[:Existence](e1, Existence())

echo tree.hasComponent[:Existence](e1)

tree.removeComponent[:Existence](e1)

echo tree.hasComponent[:Existence](e1)