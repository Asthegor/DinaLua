# Dina Lua

English below

__Description__

Facilitez vous la création de jeux vidéo !

"Dina Lua" est un moteur de jeu en Lua qui se repose sur le framework Löve2D.
Il offre de nombreuses fonctionnalités tout en laissant le contrôle au développeur.

Voici quelques unes des fonctionnalités qu'il intègre :

- la prise en charge de cartes issues de Tiled (voir "LevelManager" dans la section Outils)
- un gestionnaire de menus
- des éléments pour personnaliser l'interface utilisateur
- un gestionnaire de clavier et gamepads (avec possibilité de faire du multi-joueurs en local)
- un gestionnaire de traductions

Vous trouverez des tutoriels (avec leur code source) et des exemples d'utilisation à télécharger.

Alors, n'attendez plus et lancez-vous ! Vous garderez toujours le contrôle de votre création !

Suivez toute l'actualité de Dina :
- sur notre page Facebook : https://www.facebook.com/DinaLuaGameEngine
- sur le site du moteur : https://dina.lacombedominique.com


__Installation__

Télécharger le moteur à l'adresse suivante :
https://dina.lacombedominique.com/download.php?file=DinaLastVersion

Enregistrer l'archive et décompresser le contenu de l'archive dans le répertoire de votre jeu.

Vous devriez obtenir un répertoire nommé "Dina" dans le répertoire de votre jeu.

Créer un fichier main.lua dans le répertoire de votre jeu puis copier/coller le code ci-dessous dedans :

```lua
-- The lines below is used for debugging.
if arg[#arg] == "-debug" then require("mobdebug").start() end
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")


-- Dina Game Engine
local Dina = require('Dina')

function love.load()
  -- Ajouter les langues à l'aide de Dina:addLanguage

  -- Ajouter les états à l'aide de Dina:addState

  -- Définir l'état de démarrage à l'aide de Dina:setState
end
function love.update(dt)
  Dina:update(dt)
end
function love.draw()
  Dina:draw()
end
```

Pour plus d'explications, veuillez vous référer au tutoriel ci-dessous :
https://dina.lacombedominique.com/tutorials/



__Utilisation des composants__

Plusieurs tutoriels sont en cours de rédaction à l'adresse suivante :
https://dina.lacombedominique.com/tutorials/



__Exemples__

Vous trouverez plusieurs exemples sur https://dina.lacombedominique.com/examples/


----------------------------------------------------------------------------------------------------------

__Description__

Make it easy to create video games!

"Dina Lua" is a Lua game engine based on the Löve2D framework.
It offers many features while leaving the control to the developer.

Here are some of the features it includes:

- support for maps from Tiled (see "LevelManager" in the Tools section)
- a menu manager
- elements to customize the user interface
- a keyboard and gamepad manager (with the possibility of local multiplayer)
- a translation manager

You will find tutorials (with their source code) and examples of use to download.

So don't wait any longer and get started! You will always be in control of your creation!

Follow all the news about Dina :
- on our Facebook page: https://www.facebook.com/DinaLuaGameEngine (french only)
- on the engine's website : https://dina.lacombedominique.com

__Installation__

Download the engine at the following address:
https://dina.lacombedominique.com/download.php?file=DinaLastVersion

Save the archive and unzip the content of the archive in your game directory.

You should get a directory named "Dina" in your game directory.

Create a main.lua file in your game directory and copy/paste the code below into it:

```lua
-- The lines below is used for debugging.
if arg[#arg] == "-debug" then require("mobdebug").start() end
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")


-- Dina Game Engine
local Dina = require('Dina')

function love.load()
  -- Add languages using Dina:addLanguage

  -- Add states using Dina:addState

  -- Set startup state using Dina:setState
end
function love.update(dt)
  Dina:update(dt)
end
function love.draw()
  Dina:draw()
end
```

For more explanations, please refer to the tutorial below:
https://dina.lacombedominique.com/tutorials/


__Using the components__

Several tutorials are being written at the following address
https://dina.lacombedominique.com/tutorials/


__Examples__

You can find several examples on https://dina.lacombedominique.com/examples/

