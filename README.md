# 🚕 Taxi NPC Mission for [FiveM](https://fivem.net/) [![GitHub stars](https://img.shields.io/github/stars/PetrisGR/FiveM-TaxiNPCMission.svg)](https://github.com/PetrisGR/FiveM-TaxiNPCMission/stargazers) [![GitHub license](https://img.shields.io/github/license/PetrisGR/FiveM-TaxiNPCMission.svg)](https://github.com/PetrisGR/FiveM-TaxiNPCMission/blob/master/LICENSE)

---

![presentation-image](https://github.com/PetrisGR/FiveM-TaxiNPCMission/assets/121623120/f06a752f-c3d8-46c5-b302-f74eea4f3a1e)

---

## Description

"FiveM-TaxiNPCMission" is a script for FiveM, a multiplayer mod for GTA. This script brings dynamic taxi missions to your GTA V multiplayer server with engaging animations, anti-exploit measures, and a user-friendly interface. Explore a multitude of features, including fare per kilometer calculation, cancellation reasons, and customizable routes.

It is pre-configured with [ESX](https://github.com/esx-framework/esx_core) and [QBCore](https://github.com/qbcore-framework/qb-core) framework functionalities as they're the most used frameworks in FiveM. Feel free to modify the framework configuration to your needs.

## Features

- **Full Onesync Infinity Compatibility:** Seamless integration with the latest Onesync.
- **Anti-Exploit/Cheat Measures:** Ensures fair gameplay by preventing exploit attempts.
- **Well-Looking Animations:** Enjoy immersive and visually appealing in-game animations.
- **Helpful Subtitles:** Clear subtitles to enhance player understanding during missions.
- **GTA:O Bar for Fare Display:** A dedicated bar for displaying the fare during missions.
- **Fare Per Kilometer Calculation:** Realistic fare calculation based on distance traveled.
- **Well-Looking Blips:** Easy-to-spot blips for enhanced navigation.
- **Easy to Understand:** User-friendly design for straightforward implementation.
- **Many Cancellation Reasons:** Multiple reasons for mission cancellation, including manual, pedestrian damage, vehicle flip, undriveable vehicle, taxi driver death, and customer npc death.
- **Fully Configurable:** Customize every aspect of the taxi missions to fit your server.
    - Ped Models: Define a list of possible pedestrian models for NPC passengers.
    - Vehicle Model: Set the model of the taxi used for missions.
    - Vehicle Spawn Point: Define the spawn point for the taxi vehicle.
    - Vehicle Plate: Customize the license plate of the taxi.
    - Fare Per Kilometer: Configure the fare amount per kilometer traveled.
    - Cooldown: Set the cooldown period between missions.
    - Routes (Pickup, Destination): Create dynamic routes for pick-up and destination points.
    - Translation: Customize in-game text and messages for internationalization.


## Usage

2. Download the [latest version](https://github.com/PetrisGR/FiveM-TaxiNPCMission/releases/latest/download/petris-taxinpcmission.zip).
3. Drag & Drop the zip file into your `resources` folder.
4. Un-zip the folder of the script.
5. Start the script via your server.cfg by typing `ensure petris-taxinpcmission` in a new code line.  
6. Make sure you configure the resource with your framework functions. (Ignore this if you use ESX Legacy or QBCore)
7. Launch your FiveM server and enjoy the taxi missions.

⚠️ To initiate or stop a taxi mission, use the following server-sided export functions:

```lua
exports["petris-taxinpcmission"]:StartTaxiMission(playerId)
exports["petris-taxinpcmission"]:StopTaxiMission(playerId)
```

## Credits

Special thanks to @Daudeuf for his [clm_ProgressBar](https://github.com/Daudeuf/clm_ProgressBar) script which is a pre-installed dependency on this script in order to provide the best quality.

## Contributing

Contributions are welcome! Please submit a pull request if you have any ideas, suggestions, or improvements. For significant changes, please open an issue to discuss the proposed changes.

## Support

If you encounter any issues or have any questions or suggestions, please feel free to [open an issue](https://github.com/PetrisGR/FiveM-TaxiNPCMission/issues).
