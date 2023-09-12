import ../src/worldtree
import terminal
import times
import std/monotimes

# Declare components and systems
type
  # Stores the age of an entity in seconds
  Age = ref object of Component
    seconds = 0.0

  # Keeps a consistent time between ticks (in seconds)
  Clock = ref object of Component
    lastTickTime: MonoTime
    currTickTime: MonoTime
    deltaTime: float

  # Increments the age of affected entities each tick
  Time = ref object of System

  # Performs the required logic to keep a Clock component consistent
  ClockSystem = ref object of System

# Increases affected entities' ages in seconds
proc onTick(self: Time, tree: var WorldTree, deltaTime: float64) =
 for entity in self.entities:
  tree.getComponent[:Age](entity).seconds += (1 * deltaTime)

# Calculates the time between each tick to keep a consistent clock
proc onTick(self: ClockSystem, tree: var WorldTree) =
  for entity in self.entities:
    let currTime = getMonoTime()
    let lastTime = tree.getComponent[:Clock](entity).lastTickTime
    let microseconds = (currTime - lastTime).inMicroseconds

    tree.getComponent[:Clock](entity).deltaTime = microseconds / 1_000_000
    tree.getComponent[:Clock](entity).lastTickTime = currTime

# Instantiate a tree and register the Existence component
var tree = WorldTree()
tree.registerComponentType[:Age]()
tree.registerComponentType[:Clock]()

# Register the Time and Clock systems
var time = tree.registerSystem[:Time]()
var clockSystem = tree.registerSystem[:ClockSystem]()

# Set the Time system's signature
var signature: set[ComponentType]
signature.incl(tree.getComponentType[:Age]())
tree.setSystemSignature[:Time](signature)

# Set the Clock system's signature
signature.excl(tree.getComponentType[:Age])
signature.incl(tree.getComponentType[:Clock])
tree.setSystemSignature[:ClockSystem](signature)

# Create a new entity and put an Age component on it
var e1 = tree.newEntity()
tree.addComponent[:Age](e1, Age())

# Create a new entity to carry the Clock component
var clock = tree.newEntity()
tree.addComponent[:Clock](clock, Clock(lastTickTime: getMonoTime()))

# Continously run the Clock and Time systems until e1 is 10 seconds old, 
# printing its age each frame
while tree.getComponent[:Age](e1).seconds < 10.0:
  clockSystem.onTick(tree)
  time.onTick(tree, tree.getComponent[:Clock](clock).deltaTime)
  eraseScreen()
  let age = tree.getComponent[:Age](e1).seconds.toInt()
  echo "Entity is ", age, " seconds old"