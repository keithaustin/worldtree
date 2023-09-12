# WorldTree - An ECS framework for Nim

A framework for the Entity-Component-System architecture, written in Nim. This project is in active development so it's not really useful yet, but please feel free to reach out with issues and suggestions! I will try to fill out this readme more completely as I get more done on the project. 

## What works so far?

- Creating and destroying entities
- Adding and removing components from entities
- Reading and writing component data
- Registering systems
- Systems automatically check component sets against entities on add/remove component

## What doesn't work so far?

- The biggest thing by far right now is the way systems are run. Ideally the framework will decide automatically which systems to run and in which order, based on the components affected by each system, with the option to override this functionality. Currently, systems have to be run entirely manually.
