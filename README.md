# [CWAPI] [Ability] Regen

## Описание
Способность оружия "Regen" (Регенерация) для Custom Weapons API.

Оружие с этой способностью постепенно восстанавливают здоровье и/или броню своего владельца, когда находится в руках.

## Требования
- [Custom Weapons API](https://github.com/ArKaNeMaN/amxx-CustomWeaponsAPI) 0.7.0 или новее

## Параметры способности

- `Delay`
    - Интервал между добавлением здоровья/брони. (сек)
    - По умолчанию: `1.0`
- `Health`
    - Кол-во восстанавливаемого здоровья за раз.
    - По умолчанию: `1`
- `HealthMax`
    - Лимит регенерации здоровья.
    - По умолчанию: `100`
- `Armor`
    - Кол-во восстанавливаемой брони за раз.
    - По умолчанию: `3`
- `ArmorMax`
    - Лимит регенерации брони.
    - По умолчанию: `100`
- `ArmorHelm`
    - Выдавать ли шлем, если его нет. (`0`/`1`)
    - По умолчанию: `1`

## Пример

Нож с регенерацией 1HP + 3AP в полторы секунды с лимитом в 100 HP и AP

```json
{
    "DefaultName": "knife",
    "Abilities": {
        "Regen": {
            "Delay": "1.5",
            "Health": "1",
            "Armor": "3"
        }
    }
}
```