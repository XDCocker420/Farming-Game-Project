# Guidelines
- [Guidelines](#guidelines)
- [Coding Guidlines](#coding-guidlines)
    - [Generelle Guidelines](#generelle-guidelines)
          - [Kommentare](#kommentare)
          - [Variablen](#variablen)
          - [Organisation](#organisation)
    - [Singeltons](#singeltons)
    - [Signals](#signals)
    - [Groups](#groups)
    - [Configuration](#configuration)
  - [Jedes Teammitglied muss alles machen](#jedes-teammitglied-muss-alles-machen)
- [Nice to know](#nice-to-know)


# Coding Guidlines
### Generelle Guidelines
###### Kommentare
So wenig wie möglich so viele wie nötig.

###### Variablen
Variablen müssen einen fixen typen haben wenn möglich.
Alle Variablen sollen mit Unterstrichen geschrieben werden z.B. foo_bar

###### Organisation
Keep it simple! Godot hat für fast alles sehr leichte Funktionen. Wenn es zu komplex wird sollte nachgelesen werden.

##### Tabs und Spaces
In unserem Projekt verwenden wir TABS!!! Das ist wichtig, weil ansonsten wird Godot ein fehler werfen. Also bei Änderungen immer Tabs verwenden!

### Singeltons
[Singeltons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) wenn möglich nur für die Datenverarbeitung verwenden.

### Signals
[Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) werden immer über Code definiert niemals im Editor.

### Groups
[Gruppen](https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html) werden immmer über den Editor definiert niemals im Code.

### Configuration
Für konfiguration von z.B. Timern oder anderen statischen Werten sollen [Config Files](https://docs.godotengine.org/en/stable/classes/class_configfile.html) verwendet werden. Daten welche nicht statisch sind wie z.B. Benutzerkonfiguration von der Lautstärke soll in user:// gespeichert werden. Alle statischen wie [üblich](https://docs.godotengine.org/en/stable/tutorials/scripting/filesystem.html) in res://

## Jedes Teammitglied muss alles machen

# Nice to know
- [Performance Profiler](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html)
- [Best practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)

