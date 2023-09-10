import ./src/[WorldTree, Component]
import terminal

# Test component, just a flag
type
  Existence = ref object of Component
  Age = ref object of Component
    ticks = 0

# Instantiate a tree and register the Existence component
var tree = WorldTree()
tree.registerComponentType[:Existence]()
tree.registerComponentType[:Age]()

# Create a new entity and put an Existence flag on it
var e1 = tree.newEntity()
tree.addComponent[:Existence](e1, Existence())
tree.addComponent[:Age](e1, Age())

var age = 0.0

while age < 100.0:
  tree.getComponent[:Age](e1).ticks += 1
  age = (tree.getComponent[:Age](e1).ticks / 10_000)
  eraseScreen()
  echo age