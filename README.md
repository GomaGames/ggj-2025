# ggj-2025

Theme: bubble

# Getting Started

Download and install [Godot 4.3](https://godotengine.org/download)

Open the project.godot file in Godot.

# Resources

## Gamepad Tester

[https://hardwaretester.com/gamepad](https://hardwaretester.com/gamepad)

# MVP

Character:
  - Movement: left, right, jump
  - Fire bubble: press fire button to create a bubble projectile
  - Bubble meter: if hit by a certain number of bubbles enter into encapsulated state
  - Melee: close range attack that will push anything hit away from the player; bubbles and captured characters are pushed farther away than free characters

System:
  - Life: shared within each team; when character trapped in a bubble hits a environmental hazard remove one life from their team
  - Win/lose condition: when a team is out of lives and loses another one they lose and the opposing team wins
  - Screen wraping: when reaching one end of the screen if there are no obstacles, character will appear on the opposite side

Bubbles:
  - Propreties: float upwards at set rate,
  - Propreties when holding character: float upwards, has a timer which will free the character when it expires
  - When fired: travel a set distance when fired then start to float upwards
  - Collision with any character: projectile attaches itself and increases bubble meter on character (bubbles size changes the increase value)
  - Collision with other bubble: combine bubbles into larger one
  - Collision with environment: bubbles are blocked and nothing happens to them
