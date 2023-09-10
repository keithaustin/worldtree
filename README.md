# WorldTree - An ECS framework for Nim

A framework for the Entity-Component-System architecture, written in Nim. This project is in active development so it's not really useful yet, but please feel free to reach out with issues and suggestions! I will try to fill out this readme more completely as I get more done on the project. 

## What works so far?

Currently, you can instantiate a registry, create entities, and attach or detach components. You can also get the data from a component.

## What doesn't work so far?

Almost everything, but in particular, the current behavior for removing an entity is to simply forget its existence. This means the entity still technically exists in memory, and so do its references to the components it had attached. I am still figuring out the best approach to this behavior, but just bear in mind that you can't really remove an entity once it exists, you can only remove access to it. 