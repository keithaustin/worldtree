import worldtree

# Declare components and systems
type
  Position = ref object of Component
    x: int
    y: int

  Velocity = ref object of Component
    x: int
    y: int

  Movement = ref object of System

proc onTick(self: Movement, tree: var WorldTree) =
  for entity in self.entities:
    let xVelocity = tree.getComponent[:Velocity](entity).x
    let yVelocity = tree.getComponent[:Velocity](entity).y

    tree.getComponent[:Position](entity).x += xVelocity
    tree.getComponent[:Position](entity).y += yVelocity

# Instanstiate a WorldTree
var tree = WorldTree()

# Register Component types
tree.registerComponentType[:Position]()
tree.registerComponentType[:Velocity]()

# Register Systems
let moveSystem = tree.registerSystem[:Movement]()

# Set system signatures
var signature: set[ComponentType]
signature.incl(tree.getComponentType[:Position]())
signature.incl(tree.getComponentType[:Velocity]())
tree.setSystemSignature[:Movement](signature)

# Create an entity
var mover = tree.newEntity()

# Give it some components
tree.addComponent[:Position](mover, Position(x: 32, y: 64))
tree.addComponent[:Velocity](mover, Velocity(x: 3, y: 1))

# Run the main loop
while true:
  moveSystem.onTick(tree)
  echo "X: ", tree.getComponent[:Position](mover).x, ", Y: ", tree.getComponent[:Position](mover).y