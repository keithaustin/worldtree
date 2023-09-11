import ./src/[WorldTree, Component, Systems]
import terminal

# Test component, just a flag
type
  Existence = ref object of Component
  Age = ref object of Component
    ticks = 0

  Time = ref object of System

proc onTick(self: Time, tree: var WorldTree) =
 for entity in self.entities:
   tree.getComponent[:Age](entity).ticks += 1

# Instantiate a tree and register the Existence component
var tree = WorldTree()
tree.registerComponentType[:Existence]()
tree.registerComponentType[:Age]()

# Register the Time system
var time = tree.registerSystem[:Time]()

var signature: set[ComponentType]
signature.incl(tree.getComponentType[:Age]())
tree.setSystemSignature[:Time](signature)

# Create a new entity and put an Existence flag on it
var e1 = tree.newEntity()
tree.addComponent[:Existence](e1, Existence())
tree.addComponent[:Age](e1, Age())

var age = 0.0

while age < 100.0:
  time.onTick(tree)
  echo " "
  age = (tree.getComponent[:Age](e1).ticks / 10_000)
  eraseScreen()
  echo age