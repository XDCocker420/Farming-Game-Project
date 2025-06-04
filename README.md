# FarmingGame 
GitHub repository for our SYP-Projekt.

## Getting started
```bash
git clone https://github.com/XDCocker420/Farming-Game-Project.git
```

## [Our GameConcept](game_concept.md)

## Contributing
Please read the [coding guidelines](guidelines.md) for our projekt.

##### [Spielehalle Prototyp](https://github.com/HuskyRun366/godot-gambling)

Before you make changes, please pull the newest version of this projekt. After you finished your work, please commit and push immediatly.
This is to avoid merge conflicts.

## Test Setup
Run `./setup_environment.sh` to install the tools required for linting and running the project in headless mode. The script installs:
- [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) providing `gdlint`
- Godot 4.4 engine (`godot4` command)

After running the script you can execute:
```bash
# Run lint checks
gdlint scripts/.../file.gd

# Ensure project scripts load without errors
godot4 --headless --path . --quit
```
