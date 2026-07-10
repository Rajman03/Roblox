# Roblox Admin System

Lekki system administracyjny dla Roblox Studio, w którym cały interfejs graficzny (UI) jest budowany po stronie serwera, a klient jedynie go renderuje.

## Funkcje

- Serwer tworzy UI na podstawie modułów w `ServerScriptService/AdminSystem/Modules/Tabs`
- Klient renderuje GUI za pomocą `UIRenderer.lua`
- Obsługa:
  - `Fly`
  - `Noclip`
  - `InfiniteJump`
  - `WalkSpeed`
  - `JumpPower`
  - `Vanish`
  - `ClickTeleport`
  - teleport do gracza
  - kick/kill gracza
  - zmiana motywu UI

## Architektura

- `AdminCore.server.lua` (`ServerScriptService/AdminSystem`)
  - tworzy folder `AdminRemotes` w `ReplicatedStorage`
  - inicjalizuje moduły serwerowe i taby
  - odpowiada za przesyłanie instrukcji UI do klienta

- `Modules/Tabs/*.lua`
  - definiują strukturę panelu administracyjnego
  - każda zakładka tworzy polecenia UI wysyłane do klienta

- `Modules/Server/*.lua`
  - zawierają logikę gry/akcje serwerowe
  - reagują na polecenia wysłane przez klienta

- `UIRenderer.lua` (`ReplicatedStorage`)
  - odbiera komendy `BuildUI`
  - buduje i odświeża GUI
  - wysyła akcje do serwera przez `AdminAction`

- `AdminClient.client.lua` (`StarterPlayerScripts`)
  - sprawdza uprawnienia admina
  - inicjalizuje renderera UI

- `ClientEffects.client.lua` (`StarterPlayerScripts`)
  - wykonuje efekty client-side, takie jak noclip, infinite jump, vanish, zmiana prędkości
  - dodaje tagi `ADMIN` / `OWNER` w czacie i nad głowami, widoczne tylko dla innych adminów/ownerów

## Konfiguracja

- `Config.lua` w `ReplicatedStorage` zawiera:
  - białą listę adminów (`Whitelist`)
  - limity `WalkSpeed` i `JumpPower`
  - domyślny motyw UI
  - klawisz skrótu dla panelu

## Jak edytować

- Nową zakładkę dodawaj w `Modules/Tabs/` jako moduł z funkcją `build(send, AdminAction, Config, player, extra)`.
- Nową logikę administracyjną dodawaj w `Modules/Server/` jako moduł z funkcją `init(deps)`.
- UI po stronie klienta nie powinien zawierać logiki gry — tylko renderowanie i obsługę wejścia.

## Instalacja

1. Otwórz projekt w Roblox Studio lub narzędziu obsługującym `default.project.json`.
2. Upewnij się, że `AdminClient.client.lua` i `ClientEffects.client.lua` znajdują się w `StarterPlayer/StarterPlayerScripts`.
3. Upewnij się, że `Config.lua`, `UIRenderer.lua` i `UILibrary` znajdują się w `ReplicatedStorage`.
4. Uruchom grę i zaloguj się jako gracz znajdujący się w `Whitelist`.

## Uwagi

- UI jest generowane tylko dla graczy z listy adminów.
- Klient otrzymuje tylko instrukcje do rysowania UI; wszystkie dane i akcje są kierowane przez serwer.
- `default.project.json` zawiera manifest elementów w modelu Roblox.
